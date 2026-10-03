#!/usr/bin/env bash

# Check that ripgrep is available before a repo-nav script tries to use it.
#
# Parameters: none.
# Output: none. Returns 0 when `rg` is on PATH; otherwise prints an error to
# stderr and returns 1.
assert_ripgrep_available() {
  if ! command -v rg >/dev/null 2>&1; then
    echo "ripgrep ('rg') is required but was not found on PATH." >&2
    return 1
  fi
}

# Print the repo-nav file inventory for a directory using `rg --files`.
# Ripgrep supplies repository-aware discovery and honors ignore rules. The
# shared exclusions omit hidden paths, zero-size files, agent instruction files, docmaps, and
# generated map documents so callers get the same inventory consistently.
#
# Parameters (positional):
#   $1 - Required directory to inventory.
#   $2 - Optional ripgrep glob to further filter the results; defaults to none.
#   $3 - Optional recursion flag. Set to "true" to include descendants;
#        otherwise only files directly inside the directory are returned.
#
# Output: one matching file path per line on stdout. Ripgrep's nonzero status
# is preserved when it cannot complete the inventory.
get_repo_nav_file_inventory() {
  local path="${1:?A path is required.}"
  local glob="${2:-}"
  local recurse="${3:-false}"
  local rg_args=(--files)

  if [[ "$recurse" != "true" ]]; then
    rg_args+=(--max-depth 1)
  fi
  if [[ -n "$glob" ]]; then
    rg_args+=(--glob "$glob")
  fi
  rg_args+=(
    --glob '!.\*'
    --glob '!**/\.\*'
    --glob '!**/\.\*/*'
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
  rg_args+=("$path")

  local files rc=0 file
  files="$(rg "${rg_args[@]}")" || rc=$?
  while IFS= read -r file; do
    if [[ -n "$file" && -s "$file" ]]; then
      printf '%s\n' "$file"
    fi
  done <<< "$files"
  return "$rc"
}