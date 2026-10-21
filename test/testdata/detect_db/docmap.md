---
folder: "test/testdata/detect_db"
generated_on: "2026-10-21T22:30:00+05:30"
num_files: 9
semantic_tags: [database, test-data]
todos_present: false
dependencies: []
---

# Folder Overview

## Purpose

Sample docmap used to test `detect_db.ps1` and `detect_db.sh`. The file entries below are fictional.

# Folder Navigation

## Files
- `schema.sql` (Size : 1200 bytes): Defines the users and posts tables, an index and a view.
    - Tags: [database, ddl, sql]
    - Database: [users, posts, idx_posts_user_id, user_posts_view]
    - TODO/FIXME/NOTE: Line 42 NOTE: view joins users and posts

- `models.py` (Size : 900 bytes): ORM models declaring the orders table and its index.
    - Tags: [orm, python]
    - Database: [`orders`, `ix_orders_customer`]

- `repository.py` (Size : 700 bytes): Queries the users table but defines nothing.
    - Tags: [data-access, python]

- `audit.sql` (Size : 300 bytes): Defines a table whose name contains a space, with duplicates and a semicolon separator.
    - Tags: [sql]
    - Database: [Audit Events; Audit Events, ix_audit_events_ts]

- `empty_db.py` (Size : 100 bytes): Database section present but nothing is defined.
    - Tags: [python]
    - Database: []

- `placeholder.py` (Size : 100 bytes): Unfilled template placeholder that must be ignored.
    - Tags: [python]
    - Database: [<include only when this file defines tables, views, or indexes>]

- `after_placeholder.sql` (Size : 250 bytes): Follows a file without a Database section; must not inherit any names.
    - Tags: [sql]
    - Database: [settings]

- `README.md` (Size : 400 bytes): Documentation with no database definitions.
    - Tags: [documentation]

- `migrations.sql` (Size : 800 bytes): Last entry in the docmap.
    - Database: [accounts, ix_accounts_email]
