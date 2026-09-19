#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--debug] [docmap.md]" >&2
  exit 1
}

debug=false
docmap_path="docmap.md"

if [[ $# -gt 2 ]]; then
  usage
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug|-d)
      debug=true
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ "$docmap_path" == "docmap.md" && "$1" != "docmap.md" ]]; then
        docmap_path="$1"
      else
        usage
      fi
      ;;
  esac
  shift
done

if [[ ! -f "$docmap_path" ]]; then
  echo "DocMap file not found: $docmap_path" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep ('rg') is required but was not found on PATH." >&2
  exit 1
fi

resolved_docmap_path="$(realpath "$docmap_path")"
folder_root="$(dirname "$resolved_docmap_path")"

# Parse file-name and size lines in one pass, preserving their document order so
# each size is associated with the file entry immediately before it. File names
# inside the docmap are relative to the directory containing docmap.md.
declare -A recorded_files=()
declare -a docmap_entries=()
pending_file=""

docmap_pattern='^\s*-\s*(?:`(?<file>(?![^`]+/docmap\.md`)(?![^`/]+_MAP\.md`)[^`]+)`|Size\s*:\s*(?<size>[0-9]+)\s+bytes)'

while IFS= read -r match; do
  [[ -z "$match" ]] && continue

  if [[ "$match" =~ ^[[:space:]]*-[[:space:]]*\`([^\`]+)\` ]]; then
    file_name="${BASH_REMATCH[1]}"
    pending_file="${file_name//\\//}"
  elif [[ "$match" =~ ^[[:space:]]*-[[:space:]]*Size[[:space:]]*:[[:space:]]*([0-9]+)[[:space:]]+bytes ]] && [[ -n "$pending_file" ]]; then
    size="${BASH_REMATCH[1]}"
    recorded_files["$pending_file"]="$size"
    docmap_entries+=("$pending_file:$size")
    pending_file=""
  fi
done < <(rg --pcre2 -N -o "$docmap_pattern" "$resolved_docmap_path")

declare -A live_files=()
mapfile -t inventory_files < <(
  rg --files \
    --glob '!\.*' \
    --glob '!**/\.*' \
    --glob '!**/\.*/*' \
    --glob '!AGENTS.md' \
    --glob '!**/AGENTS.md' \
    --glob '!CLAUDE.md' \
    --glob '!**/CLAUDE.md' \
    --glob '!DOCMAP.md' \
    --glob '!**/DOCMAP.md' \
    --glob '!docmap.md' \
    --glob '!**/docmap.md' \
    --glob '!*_MAP.md' \
    --glob '!**/*_MAP.md' \
    "$folder_root"
)

for file in "${inventory_files[@]}"; do
  rel_path="${file#$folder_root/}"
  rel_path="${rel_path//\\//}"

  if [[ -n "$rel_path" && "$rel_path" != "docmap.md" && -f "$file" ]]; then
    live_files["$rel_path"]="$(wc -c < "$file" | tr -d '[:space:]')"
  fi
done

declare -a changes=()

for file in "${!recorded_files[@]}"; do
  expected_size="${recorded_files[$file]}"
  full_path="$folder_root/$file"

  if [[ ! -f "$full_path" ]]; then
    changes+=("$file|$expected_size|0|DELETED")
    continue
  fi

  actual_size="${live_files[$file]:-$(wc -c < "$full_path" | tr -d '[:space:]')}"
  if [[ "$actual_size" != "$expected_size" ]]; then
    changes+=("$file|$expected_size|$actual_size|MODIFIED")
  fi
done

for file in "${!live_files[@]}"; do
  if [[ -z "${recorded_files[$file]:-}" ]]; then
    changes+=("$file|0|${live_files[$file]}|ADDED")
  fi
done

if [[ "$debug" == true ]]; then
  echo "Detected files from docmap:"
  if (( ${#docmap_entries[@]} > 0 )); then
    printf '%s\n' "${docmap_entries[@]}" | sort -t: -k1,1 | while IFS=: read -r file size; do
      printf '  %s : %s bytes\n' "$file" "$size"
    done
  else
    echo "  (none)"
  fi
  echo
fi

if (( ${#changes[@]} == 0 )); then
  echo "No changed files detected for $resolved_docmap_path"
  exit 0
fi

echo "| Filename | Size in DocMap | Actual Size | Status |"
echo "| --- | ---: | ---: | --- |"
printf '%s\n' "${changes[@]}" | sort -t'|' -k1,1 | while IFS='|' read -r file docmap_size actual_size status; do
  printf '| %s | %s | %s | %s |\n' "$file" "$docmap_size" "$actual_size" "$status"
done
