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

set -u

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

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep ('rg') is required but was not found on PATH." >&2
  exit 1
fi

if ! cd "$path" 2>/dev/null; then
  echo "Path not found: $path" >&2
  exit 1
fi

resolved_path="$(pwd)"

# Use rg --files as the authoritative repository inventory.
# ripgrep already honors .gitignore and VCS metadata directories such as .git,
# .hg, and .svn, so no extra ignore globs are needed for those folders.
rg_args=(--files)
if [[ "$recurse" != "true" ]]; then
  rg_args+=(--max-depth 1)
fi
if [[ -n "$glob" ]]; then
  rg_args+=(--glob "$glob")
fi
rg_args+=(
  --glob '!.*'
  --glob '!**/.*'
  --glob '!**/.*/**'
  --glob '!AGENTS.md'
  --glob '!**/AGENTS.md'
  --glob '!CLAUDE.md'
  --glob '!**/CLAUDE.md'
  --glob '!DOCMAP.md'
  --glob '!**/DOCMAP.md'
  --glob '!docmap.md'
  --glob '!**/docmap.md'
  --glob '!*_MAP.md'
  --glob '!**/*_MAP.md'
)
rg_args+=("$resolved_path")

mapfile -t files < <(rg "${rg_args[@]}")

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
    rows+=("${file}|${size}")
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
