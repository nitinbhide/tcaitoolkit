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

resolved_docmap_path="$(realpath "$docmap_path")"
folder_root="$(dirname "$resolved_docmap_path")"

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep ('rg') is required but was not found on PATH." >&2
  exit 1
fi

# Parse the docmap with rg in a single pass: capture file entry + size entry blocks.
# The file names in the docmap are resolved relative to the directory containing docmap.md.
mapfile -t raw_matches < <(
  rg --pcre2 -U -N -o -P '^\s*-\s*`[^`]+`.*?^\s*-\s*Size\s*:\s*\d+\s+bytes' "$resolved_docmap_path" || true
)

declare -A recorded_files=()
declare -a docmap_entries=()

for match in "${raw_matches[@]}"; do
  file_name=""
  size=""

  if [[ "$match" =~ ^[[:space:]]*-[[:space:]]*\`([^\`]+)\` ]]; then
    file_name="${BASH_REMATCH[1]}"
  fi

  if [[ "$match" =~ [[:space:]]*-[[:space:]]*Size[[:space:]]*:[[:space:]]*([0-9]+)[[:space:]]+bytes ]]; then
    size="${BASH_REMATCH[1]}"
  fi

  if [[ -n "$file_name" && -n "$size" ]]; then
    normalized="${file_name//\\//}"
    recorded_files["$normalized"]="$size"
    docmap_entries+=("$normalized:$size")
  fi
done

declare -A live_files=()
while IFS= read -r -d '' file; do
  rel_path="${file#$folder_root/}"
  rel_path="${rel_path//\\//}"

  if [[ "$rel_path" != "docmap.md" ]]; then
    live_files["$rel_path"]="$(stat -c %s -- "$file")"
  fi
done < <(find "$folder_root" -type f -not -path "$resolved_docmap_path" -print0)

declare -a changes=()

for file in "${!recorded_files[@]}"; do
  expected_size="${recorded_files[$file]}"
  full_path="$folder_root/$file"
  full_path="${full_path//\//\/}"

  if [[ ! -f "$full_path" ]]; then
    changes+=("$file|$expected_size|0|DELETED")
    continue
  fi

  actual_size="${live_files[$file]:-$(stat -c %s -- "$full_path")}" 
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
