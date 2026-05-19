# Git Reference

## Sync Before Operations
```
git fetch --all
git pull --rebase
```

## Change Logs

### By Time Range
```
git log --since="<start>" --until="<end>" --pretty=format:"%h | %an | %ad%n%s"
```

## Between Branches
```
git log <target>..<source> --pretty=format:"%h | %an | %ad%n%s"
```

## Unified Diff Between Branches

```
git diff --unified=5 -w <base>...<compare>
```

## Check Working State
```
git status --porcelain
```

