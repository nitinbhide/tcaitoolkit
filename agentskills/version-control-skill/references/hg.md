# Mercurial (hg) Reference

## Sync Before Operations
```
hg pull
hg update
```


## Change Logs

### By Time Range
```
hg log -d "<start> to <end>" --template "{node|short} | {author} | {date}\n{desc}\n"
```


## Between Branches
```
hg log -r "ancestors(<source>) - ancestors(<target>)" --template "{node|short} | {author} | {date}\n{desc}\n"
```


## Unified Diff Between Branches
```
hg diff -r <base> -r <compare>
```

## Check Working State
```
hg status
```