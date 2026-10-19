#!/usr/bin/env bash
# Lists files with database definitions recorded in docmaps.
#
# Usage:
#   ./detect_db.sh [directory|docmap.md]
#
# A directory is searched recursively for docmap.md and DOCMAP.md files. A
# single docmap may also be provided. Only names listed in each file entry's
# Database section are reported.

set -euo pipefail

export LC_ALL=C.UTF-8

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/fileinventory.sh"
assert_ripgrep_available

usage() {
  echo "Usage: $0 [directory|docmap.md]" >&2
  exit 1
}

if (($# > 1)); then
  usage
fi

path="${1:-.}"
if [[ -d "$path" ]]; then
  root_path="$(cd -- "$path" && pwd -P)"
  set +e
  docmap_output="$(rg --files --glob 'docmap.md' --glob 'DOCMAP.md' -- "$root_path")"
  rg_status=$?
  set -e
  if ((rg_status > 1)); then
    echo "ripgrep failed while searching for docmaps under '$root_path'." >&2
    exit "$rg_status"
  fi
  docmap_paths=()
  while IFS= read -r docmap; do
    [[ -n "$docmap" ]] && docmap_paths+=("$docmap")
  done <<< "$docmap_output"
elif [[ -f "$path" && ( "${path##*/}" == "docmap.md" || "${path##*/}" == "DOCMAP.md" ) ]]; then
  resolved_docmap="$(realpath -- "$path")"
  root_path="$(dirname -- "$resolved_docmap")"
  docmap_paths=("$resolved_docmap")
else
  echo "Path must be a directory or a docmap.md/DOCMAP.md file." >&2
  exit 1
fi

declare -A database_objects_by_file=()
declare -A seen_objects=()

for docmap in "${docmap_paths[@]}"; do
  resolved_docmap="$(realpath -- "$docmap")"
  docmap_relative="${resolved_docmap#"$root_path"/}"
  docmap_directory="${docmap_relative%/*}"
  if [[ "$docmap_directory" == "$docmap_relative" ]]; then
    docmap_directory=""
  fi

  parsed_entries="$(
    awk '
      function trim(value) {
        sub(/^[[:space:]]+/, "", value)
        sub(/[[:space:]]+$/, "", value)
        return value
      }

      /^[[:space:]]*-[[:space:]]*`/ {
        start = index($0, "`")
        remainder = substr($0, start + 1)
        end = index(remainder, "`")
        if (end > 0) {
          current_file = trim(substr(remainder, 1, end - 1))
        }
        next
      }

      /^[[:space:]]*-[[:space:]]*Database[[:space:]]*:/ {
        if (current_file == "" || !match($0, /\[[^]]*\]/)) {
          next
        }
        contents = substr($0, RSTART + 1, RLENGTH - 2)
        count = split(contents, parts, /[,;]/)
        names = ""
        for (i = 1; i <= count; i++) {
          name = trim(parts[i])
          gsub(/`/, "", name)
          if (name == "" || name ~ /[<>]/) {
            continue
          }
          duplicate = 0
          split(names, existing, /, /)
          for (j in existing) {
            if (existing[j] == name) {
              duplicate = 1
              break
            }
          }
          if (!duplicate) {
            names = names (names == "" ? "" : ", ") name
          }
        }
        if (names != "") {
          printf "%s\t%s\n", current_file, names
        }
      }
    ' "$resolved_docmap"
  )"

  while IFS=$'\t' read -r file_name object_names; do
    [[ -z "$file_name" || -z "$object_names" ]] && continue
    if [[ -n "$docmap_directory" ]]; then
      relative_file="$docmap_directory/$file_name"
    else
      relative_file="$file_name"
    fi
    relative_file="${relative_file//\\//}"

    IFS=',' read -r -a names <<< "$object_names"
    for name in "${names[@]}"; do
      name="${name#"${name%%[![:space:]]*}"}"
      name="${name%"${name##*[![:space:]]}"}"
      [[ -z "$name" ]] && continue
      object_key="$relative_file"$'\034'"$name"
      if [[ -z "${seen_objects[$object_key]:-}" ]]; then
        seen_objects["$object_key"]=1
        if [[ -n "${database_objects_by_file[$relative_file]:-}" ]]; then
          database_objects_by_file["$relative_file"]+=", $name"
        else
          database_objects_by_file["$relative_file"]="$name"
        fi
      fi
    done
  done <<< "$parsed_entries"
done

if ((${#database_objects_by_file[@]} == 0)); then
  echo "No database definitions found."
  exit 0
fi

{
  printf 'Filename\tDatabaseObjects\n'
  while IFS= read -r file_name; do
    printf '%s\t%s\n' "$file_name" "${database_objects_by_file[$file_name]}"
  done < <(printf '%s\n' "${!database_objects_by_file[@]}" | sort)
} | awk -F '\t' '
  {
    rows[NR] = $0
    if (length($1) > filename_width) {
      filename_width = length($1)
    }
    if (length($2) > objects_width) {
      objects_width = length($2)
    }
  }
  END {
    printf "%-*s  %-*s\n", filename_width, "Filename", objects_width, "DatabaseObjects"
    printf "%-*s  %-*s\n", filename_width, "--------", objects_width, "---------------"
    for (i = 2; i <= NR; i++) {
      split(rows[i], columns, "\t")
      printf "%-*s  %-*s\n", filename_width, columns[1], objects_width, columns[2]
    }
  }
'
