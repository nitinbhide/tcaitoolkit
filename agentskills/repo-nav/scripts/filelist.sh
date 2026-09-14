#!/usr/bin/env bash
# Generates a Markdown table listing repository files and their sizes.
#
# Usage:
#   ./filelist.sh [path] [output-file] [baseline-file]
#
# Workflow:
#   1. Use rg --files as the authoritative repository inventory.
#   2. Let ripgrep honor repository ignore rules automatically.
#   3. Use shell/file metadata commands to measure file sizes.
#   4. Emit the results as a Markdown table.
#   5. If a baseline file is supplied, detect added/modified/deleted files
#      using size deltas for repo-nav incremental update checks.

set -u

path="${1:-.}"
output_file="${2:-}"
baseline_file="${3:-}"

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
mapfile -t files < <(rg --files "$resolved_path")

filtered=()
for file in "${files[@]}"; do
  base="${file##*/}"
  if [[ "$base" != "AGENTS.md" && "$base" != "CLAUDE.md" ]]; then
    filtered+=("$file")
  fi
done

if ((${#filtered[@]} == 0)); then
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
for file in "${filtered[@]}"; do
  if [[ -f "$file" ]]; then
    size=$(wc -c < "$file" | tr -d '[:space:]')
    rows+=("${file}|${size}")
  fi
done

if [[ -n "$baseline_file" && -f "$baseline_file" ]]; then
  declare -A baseline_map=()
  while IFS='|' read -r file_name size_value; do
    if [[ "$file_name" =~ ^[[:space:]]*\| ]]; then
      continue
    fi
    if [[ "$line" =~ ^\|[[:space:]]* ]]; then
      continue
    fi
  done < <(grep -E '^\| ' "$baseline_file" || true)

  while IFS= read -r line; do
    if [[ "$line" =~ '^\| ' ]]; then
      continue
    fi
    if [[ "$line" =~ ^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[0-9]+[[:space:]]*\|$ ]]; then
      line="${line#|}"
      line="${line%|}"
      IFS='|' read -r file_name size_value <<< "$line"
      file_name="${file_name//[[:space:]]/}"
      baseline_map["$file_name"]="${size_value//[[:space:]]/}"
    fi
  done < "$baseline_file"

  declare -A current_map=()
  for row in "${rows[@]}"; do
    IFS='|' read -r file_name size_value <<< "$row"
    current_map["$file_name"]="$size_value"
  done

  changed_rows=()
  for row in "${rows[@]}"; do
    IFS='|' read -r file_name size_value <<< "$row"
    if [[ -z "${baseline_map[$file_name]+x}" ]]; then
      changed_rows+=("| ${file_name//|/\\|} | ${size_value} | ADDED |")
    elif [[ "${baseline_map[$file_name]}" != "$size_value" ]]; then
      changed_rows+=("| ${file_name//|/\\|} | ${size_value} | MODIFIED |")
    fi
  done

  for file_name in "${!baseline_map[@]}"; do
    if [[ -z "${current_map[$file_name]+x}" ]]; then
      changed_rows+=("| ${file_name//|/\\|} | ${baseline_map[$file_name]} | DELETED |")
    fi
  done

  if ((${#changed_rows[@]} == 0)); then
    table='| File | Size (bytes) | Change |
| --- | ---: | --- |'
  else
    sorted_changed=$(printf '%s\n' "${changed_rows[@]}" | LC_ALL=C sort)
    table="| File | Size (bytes) | Change |
| --- | ---: | --- |
$sorted_changed"
  fi

  if [[ -n "$output_file" ]]; then
    printf '%s\n' "$table" > "$output_file"
  else
    printf '%s\n' "$table"
  fi
  exit 0
fi

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
