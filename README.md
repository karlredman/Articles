[![Build Status](https://drone-github.parasynthetic.dev/api/badges/karlredman/Articles/status.svg)](https://drone-github.parasynthetic.dev/karlredman/Articles)

# Articles by Karl N. Redman

This project is intended to ba a centralized repository for various public articles I've written for various media. The articles here will be the canonical reference for wherever they are replicated and posted otherwise. Additionally there is a showcase for a subset of these writings hosted on my [github.io page](https://karlredman.github.io/Articles/).

## checkout

```
git clone --recursive <project>
```

## building

```
cd <project root>
rm -rf site/*
hugo --gc --baseURL="https://karlredman.github.io/Articles" --config="config.toml" -d site
```

## Publishing: checkin `gh-pages` branch/submodule

```
cd <project root>/site
git add -A
git commit -am "<message>"
git push origin HEAD:gh-pages
```

## Content: check in root proj

```
cd <project root>
git add -A
git commit -am "<message>"
git push
```
