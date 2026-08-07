# Publish ORBIT

This package is ready to publish as `emmanuelsystems/orbit`.

From Ubuntu / WSL:

```sh
cd orbit
gh auth status
gh repo create emmanuelsystems/orbit --private --source=. --remote=origin --push
```

Use `--public` later when the alpha is ready for outside users.

After publishing:

```sh
git remote -v
git status
./tests/smoke.sh
```
