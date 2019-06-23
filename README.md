# Articles by Karl N. Redman

## checkout

```
git clone --recursive <project>
```

## building

```
rm -rf site/*
hugo --gc --baseURL="https://karlredman.github.io/Articles" --config="config.toml" -d site
```

## checkin `gh-pages` branch/submodule

```
cd site
git add -A
git commit -am "hugo build"
git push origin HEAD:gh-pages
```

## (devel) check in root proj

```
cd <project root>
git add -A
git commit -am "hugo build"
git push
```
