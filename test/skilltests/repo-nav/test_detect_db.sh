#!/usr/bin/env bash
# Tests detect_db.sh against test/testdata/detect_db/docmap.md.
#
# Usage:
#   ./test_detect_db.sh

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../../.." && pwd)"
detect_db="$repo_root/agentskills/repo-nav/scripts/detect_db.sh"
test_data="$repo_root/test/testdata/detect_db"

# Files must be listed in sorted order. Entries without a Database section, with
# an empty one, or with an unfilled placeholder must not appear.
expected="after_placeholder.sql|settings
audit.sql|Audit Events, ix_audit_events_ts
migrations.sql|accounts, ix_accounts_email
models.py|orders, ix_orders_customer
schema.sql|users, posts, idx_posts_user_id, user_posts_view"

output="$(bash "$detect_db" "$test_data")"

header="$(printf '%s\n' "$output" | sed -n '1p' | tr -s ' ' | sed 's/ $//')"
if [[ "$header" != "Filename DatabaseObjects" ]]; then
  echo "FAIL: expected a 'Filename DatabaseObjects' header, got: '$header'"
  exit 1
fi

# Skip the two header lines and turn "file   objects" into "file|objects".
actual="$(printf '%s\n' "$output" | tail -n +3 | sed -E 's/[[:space:]]+$//; s/^([^[:space:]]+)[[:space:]]+(.*)$/\1|\2/')"

if [[ "$actual" != "$expected" ]]; then
  echo "FAIL: detect_db.sh output differs from expected."
  diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") || true
  exit 1
fi

echo "detect_db.sh test PASSED ($(printf '%s\n' "$expected" | wc -l | tr -d ' ') files verified)."
