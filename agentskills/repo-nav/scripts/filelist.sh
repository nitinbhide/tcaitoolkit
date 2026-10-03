#!/usr/bin/env bash
# Generates a Markdown table listing repository files and their sizes.
#
# Usage:
#   ./filelist.sh [path] [output-file] [-Glob glob] [-Recurse]
#
# Workflow:
#   1. Use rg --files as the authoritative repository inventory.
#   2. Let ripgrep honor repository ignore rules automatically.
#   3. Use shell/file metadata commands to measure file sizes.
#   4. Emit the results as a Markdown table.

set -euo pipefail

export LC_ALL=C.UTF-8

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/fileinventory.sh"

path="${1:-.}"
output_file="${2:-}"
glob=""
recurse="false"

shift $(( $# >= 2 ? 2 : $# ))
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
      echo "Unexpected argument: $1" >&2
      exit 1
      ;;
  esac
done

assert_ripgrep_available

if ! cd "$path" 2>/dev/null; then
  echo "Path not found: $path" >&2
  exit 1
fi

resolved_path="$(pwd)"

mapfile -t files < <(get_repo_nav_file_inventory "$resolved_path" "$glob" "$recurse")

if ((${#files[@]} == 0)); then
  table='| File | Size (bytes) |
| --- | ---: |'
  if [[ -n "$output_file" ]]; then
    printf '%s\n' "$table" > "$output_file"
  else
    printf '%s\n' "$table"
  fi
  exit 0
fi

rows=()
for file in "${files[@]}"; do
  if [[ -f "$file" ]]; then
    size=$(wc -c < "$file" | tr -d '[:space:]')
    if ((size > 0)); then
      rows+=("${file}|${size}")
    fi
  fi
done

if ((${#rows[@]} == 0)); then
  table='| File | Size (bytes) |
| --- | ---: |'
  if [[ -n "$output_file" ]]; then
    printf '%s\n' "$table" > "$output_file"
  else
    printf '%s\n' "$table"
  fi
  exit 0
fi

header='| File | Size (bytes) |
| --- | ---: |'

sorted_rows=$(printf '%s\n' "${rows[@]}" | LC_ALL=C sort | awk -F'|' '{print "| " $1 " | " $2 " |"}')
markdown="$header
$sorted_rows"

if [[ -n "$output_file" ]]; then
  printf '%s\n' "$markdown" > "$output_file"
else
  printf '%s\n' "$markdown"
fi
