# Subversion (SVN) Reference

## Sync Before Operations
```
svn update
```

## Change Logs

### By Time Range
```
svn log -r {<start>}:{<end>}
```

## Between Branches
```
svn log <repo_url>/<source_branch> ^/<target_branch>
```
(Note: Requires repository URL-based comparison.)

## Unified Diff Between Branches
```
svn diff <repo_url>/<base_branch> <repo_url>/<compare_branch>
```

## Check Working State
```
svn status
```