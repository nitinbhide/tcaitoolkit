# Bash Operations

Use this reference for Bash operations on Unix-like systems that supplement the authoritative `rg --files` inventory. Bash is for filesystem operations and comparisons that ripgrep cannot express, not for replacing repository discovery.

## Path Handling

- Treat repository-relative paths as strings using `/` separators. Do not convert them to absolute paths until a filesystem operation requires it.
- Build filesystem paths from the repository root with `root/$relative_path`; quote every expansion so spaces and other path characters are preserved.
- Check for empty directory values before calling `test`, `cd`, or constructing paths from them.
- Calculate depth only from normalized `/`-separated repository-relative paths.
- Exclude folders already merged into a parent from subsequent candidate selection.

## Allowed Operations

Use Bash and standard Unix utilities for:

- byte-size checks with `stat` or `wc -c`;
- array comparison and ordering with shell arrays, `sort`, and `comm`;
- filesystem existence checks with `test` or `[[ ... ]]`;
- immediate-directory checks with `find "$directory" -mindepth 1 -maxdepth 1` after the inventory has been established;
- merge bookkeeping and relative-path rewriting that `rg` cannot express.

Do not use recursive `find` enumeration as the initial repository scan. Do not create Python, Node.js, or other helper scripts for discovery or validation.

## Validation Recovery

Run validation for the edited folder immediately after generation or merge. If a Bash validator reports a parsing, path, timeout, or empty-value error, treat the result as inconclusive, simplify or repair the validator, and rerun the same focused check. Do not regenerate the docmap until the validator can discriminate pass from failure.