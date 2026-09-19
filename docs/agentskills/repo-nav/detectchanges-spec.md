# Specification document for "detect changes" script 

# Overview
"detectchanges" script (`detectchanges.ps1` and `detectchanges.sh`) is used to extract the source and documentatino files and their sizes from a docmap file (`docmap.md` and `DOCMAP.md`) and compare with the files on the disk. Then identify which files are modified, new files added or deleted. This list of changed files is then used by the repo-nav skill to update the docmaps.

# Specifications

## Output format
The output is in markdown format

```markdown
"| Filename | Size in DocMap | Actual Size | Status |"
"| --- | ---: | ---: | --- |"
```
If the Debug flag is True, then the script also outputs debug information on files

## Detecting filenames and sizes
There are two ways file name and sizes are recorded in the docmaps.

**Example 1**
```markdown
- `<relative filepath>` : <short description>
    - Size : <size in bytes> bytes
- `<child folder/filename.ext>` : <short description>
    - Size : <size in bytes> bytes
```

**Example 2**
```markdown
- `<relative filepath of "filename1">` (Size : <file size in bytes>): <one short paragraph summary of content of "filename1">
- `<child folder/filename2.ext>` (Size : <file size in bytes>): <one short paragraph summary of content of "filename2.ext">
```

**Important**
- "relative filepaths" are relative to parent folder of input `docmap.md` file.

# Implementation

## Implementation Guidance
- Use `rg` (ripgrep) to filter the files. 
- Do not add additional bash or powershell regex filters. Especially do not add for-loop-if-check filters
- Along with standard `rg` filter, filter following files
    - "docmap.md" and "DOCMAP.md"
    - "AGENTS.md"
    - "CLAUDE.md"
    - Other cross nagivagation maps "*_MAP.md"
- Keep the filtering logic same as in "filelist.ps1"
- Always implement new changes in the `detectchanges.ps1`
- Make sure to keep the `detectchanges.sh` in sync with `detectchanges.ps1`

