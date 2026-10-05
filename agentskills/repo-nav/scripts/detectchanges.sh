#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C.UTF-8

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/fileinventory.sh"

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

docmap_missing=false
# Docmap generation may have been interrupted; a missing docmap is not an error.
if [[ ! -f "$docmap_path" ]]; then
  docmap_missing=true
  docmap_dir="$(dirname "$docmap_path")"
  if [[ ! -d "$docmap_dir" ]]; then
    echo "DocMap folder not found: $docmap_dir" >&2
    exit 1
  fi
fi

assert_ripgrep_available

if [[ "$docmap_missing" == true ]]; then
  resolved_docmap_path="$(realpath "$docmap_dir")/$(basename "$docmap_path")"
else
  resolved_docmap_path="$(realpath "$docmap_path")"
fi
folder_root="$(dirname "$resolved_docmap_path")"

# Parse each file entry and its size as one multiline rg match. The two size
# locations cover both documented forms; the boundary prevents crossing into
# another backtick file entry.
declare -A recorded_files=()
declare -a docmap_entries=()
docmap_pattern='(?ms)^\s*-\s*`(?<file>(?![^`]+/docmap\.md`)(?![^`/]+_MAP\.md`)[^`]+)`(?:(?:[^\r\n]*?\(\s*Size\s*:\s*)|(?:(?!^\s*-\s*`).)*?^\s*-\s*Size\s*:\s*)(?<size>[0-9][0-9,]*)\s+bytes'
docmap_replacement='${file}'$'\t''${size}'

while IFS=$'\t' read -r normalized size; do
  [[ -z "$normalized" ]] && continue
  normalized="${normalized//\\//}"
  size="${size//,/}"
  recorded_files["$normalized"]="$size"
  docmap_entries+=("$normalized:$size")
done < <(if [[ "$docmap_missing" == true ]]; then :; else rg --pcre2 -U -N -o --replace "$docmap_replacement" "$docmap_pattern" "$resolved_docmap_path"; fi)

declare -A live_files=()

# NOTE: All file filtering logic must live in get_repo_nav_file_inventory
# (fileinventory.sh). Do not add filters (size, name, type) in this script.
declare -a inventory_files=()
declare -a changes=()
if [[ "$docmap_missing" == true ]]; then
  # Case 1: no docmap here, so every file in the tree is ADDED.
  mapfile -t inventory_files < <(get_repo_nav_file_inventory "$folder_root" "" true)
else
  mapfile -t inventory_files < <(get_repo_nav_file_inventory "$folder_root")
fi

declare -A merged_folders=()
for file in "${!recorded_files[@]}"; do
  if [[ "$file" == */* ]]; then
    merged_folders["${file%/*}"]=1
  fi
done

for merged_folder in "${!merged_folders[@]}"; do
  merged_folder_path="$folder_root/${merged_folder//\//\/}"
  while IFS= read -r file; do
    [[ -n "$file" ]] && inventory_files+=("$file")
  done < <(get_repo_nav_file_inventory "$merged_folder_path")
done

# Case 2: immediate child folders not covered by this docmap and with no docmap
# of their own are new folders; report the folder and all its files.
if [[ "$docmap_missing" != true ]]; then
  while IFS= read -r dir; do
    dir_name="${dir##*/}"
    [[ "$dir_name" == .* ]] && continue
    covered=false
    for merged_folder in "${!merged_folders[@]}"; do
      if [[ "$merged_folder" == "$dir_name" || "$merged_folder" == "$dir_name"/* ]]; then
        covered=true
        break
      fi
    done
    [[ "$covered" == true ]] && continue
    [[ -e "$dir/docmap.md" || -e "$dir/DOCMAP.md" ]] && continue

    new_folder_files=()
    while IFS= read -r file; do
      [[ -n "$file" ]] && new_folder_files+=("$file")
    done < <(get_repo_nav_file_inventory "$dir" "" true)
    (( ${#new_folder_files[@]} == 0 )) && continue
    inventory_files+=("${new_folder_files[@]}")
    changes+=("$dir_name/|||ADDED")
  done < <(find "$folder_root" -mindepth 1 -maxdepth 1 -type d | sort)
fi

for file in "${inventory_files[@]}"; do
  rel_path="${file#$folder_root/}"
  rel_path="${rel_path//\\//}"

  if [[ -n "$rel_path" ]]; then
    live_files["$rel_path"]="$(wc -c < "$file" | tr -d '[:space:]')"
  fi
done

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
