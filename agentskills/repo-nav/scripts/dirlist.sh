#!/usr/bin/env bash
# Lists directories containing repository files in a Markdown table.
#
# Usage:
#   ./dirlist.sh [path] [output-file] [-Glob glob] [-Recurse]
#
# Uses the shared repo-nav inventory so hidden paths, documentation files, and
# empty files are excluded consistently with filelist.sh. Rows are ordered by
# depth descending, then folder path lexicographically.

set -euo pipefail

export LC_ALL=C.UTF-8

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/fileinventory.sh"

path="${1:-.}"
output_file=""
glob=""
recurse="false"

if (($# > 0)); then
  shift
fi
while (($# > 0)); do
  case "$1" in
    -Glob|--glob)
      if (($# < 2)); then
        echo "Missing value for $1." >&2
        exit 1
      fi
      glob="$2"
      shift 2
      ;;
    -Recurse|--recurse)
      recurse="true"
      shift
      ;;
    *)
      if [[ -z "$output_file" ]]; then
        output_file="$1"
        shift
      else
        echo "Unexpected argument: $1" >&2
        exit 1
      fi
      ;;
  esac
done

assert_ripgrep_available

if ! resolved_path="$(cd -- "$path" 2>/dev/null && pwd)"; then
  echo "Path not found: $path" >&2
  exit 1
fi

inventory_status=0
files="$(get_repo_nav_file_inventory "$resolved_path" "$glob" "$recurse")" || inventory_status=$?
if ((inventory_status > 1)); then
  exit "$inventory_status"
fi

declare -A folder_counts=()
if [[ -n "$files" ]]; then
  while IFS= read -r file; do
    if [[ -n "$file" ]]; then
      folder="$(dirname -- "$file")"
      folder_counts["$folder"]=$(( ${folder_counts["$folder"]:-0} + 1 ))
    fi
  done <<< "$files"
fi

folder_counts["$resolved_path"]="${folder_counts["$resolved_path"]:-0}"

records=()
for folder in "${!folder_counts[@]}"; do
  if [[ "$folder" == "$resolved_path" ]]; then
    depth=0
  else
    if [[ "$resolved_path" == "/" ]]; then
      relative_folder="${folder#/}"
    else
      relative_folder="${folder#"$resolved_path"/}"
    fi
    IFS='/' read -r -a path_parts <<< "$relative_folder"
    depth="${#path_parts[@]}"
  fi
  records+=("$depth"$'\t'"$folder")
done

table='| Depth | Folder Path | Direct Files Count |
| ---: | --- | ---: |'
if ((${#records[@]} > 0)); then
  sorted_records="$(printf '%s\n' "${records[@]}" | sort -t $'\t' -k1,1nr -k2,2)"
  while IFS=$'\t' read -r depth folder; do
    escaped_folder="${folder//|/\\|}"
    table+=$'\n'"| $depth | $escaped_folder | ${folder_counts["$folder"]} |"
  done <<< "$sorted_records"
fi

if [[ -n "$output_file" ]]; then
  printf '%s\n' "$table" > "$output_file"
else
  printf '%s\n' "$table"
fi
