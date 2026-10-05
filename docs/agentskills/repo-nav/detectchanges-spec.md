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

Status must of the `DELETED`, `MODIFIED`, `ADDED`. 
Unmodified files are not reported.

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

**Important Hints**
- "relative filepaths" are relative to parent folder of input `docmap.md` file.
- Use combined regex pattern to detect filename and size ("filename and size regex pattern") with `rg`. 
- Do not use powershell or bash regex patterns for this check.

## Interrupted docmap generation
Navigation documentation generation may be interrupted, so docmaps may not exist yet for some folders. "detectchanges" must handle this.

### Case 1: No docmap or root docmap in the folder hierarchy
If there is no `docmap.md`/`DOCMAP.md` in a folder, or no root docmap at all, and no ancestor docmap covers that folder (i.e. it is not a "merged folder" of any docmap), then every file in that folder tree (after the standard filtering) is reported with status `ADDED`. "Size in DocMap" is empty for these files.

### Case 2: New folder added in an existing folder tree
If a folder exists on disk under a folder covered by a docmap, but is neither mentioned in that docmap nor a "merged folder" and has no docmap of its own (e.g. a new folder, or a child whose docmap was not generated), treat it as a newly added folder:
- Report the folder itself as a row with status `ADDED`, filename ending with `/` (e.g. `newfolder/`), and empty sizes.
- Then report every file in that folder tree (after the standard filtering) as `ADDED`, with paths relative to the docmap's parent folder.
- Case 1 is the special case where the whole hierarchy (including the root) lacks docmaps.

# Implementation

## Implementation Guidance
- DO NOT Modify the input "docmap" files for any reason.
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
- To check if the file is modified, file sizes are to be compared. Assume that file is modified it the size is changed. If the file size in bytes in same, then treat the file is "unmodified"
- **CAVEAT in using `rg`**.
    - Remember `rg` will list all the files recursively in the current folder and the child folders. However, the docmap.md contains files from the parent folder of docmap.md and the child folders where the child docmap.md is merged with parent docmap.md.
    - Hence naive use of `rg` will result in many files as 'added'. These files will be potentially in other child docmap.md files
    - This will require some pre-processing to understand which child docmaps are merged with parent docmaps. 
    - The files in those merged folders are to be analyzed for modification detection. Remaining folders must be ignored. - Use the "filename and size regex pattern" to detect the "merged folder names" whose child docmaps are merged with this docmap file. 
    - Then modify the "filename and size regex pattern" and include the only files with no parent folder mentioned or the folders mentioned the ""merged folder names".
    - Remember to analyze only the immediate children of "merged folders" are to be analyzed and not all the recursive childerens.