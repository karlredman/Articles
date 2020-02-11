---
title: "Go: GVM and Portable-ish Workspaces (Part 1: Setup DISTILLED)"
published: true
description: "Customizing Go workspaces with gvm (setup)."
categories: [dev.to,programming,devops,administration]
tags: [go,administration,mentalhealth,development]
canonical_url: https://github.com/karlredman/My-Articles/wiki/
published_url:

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: 2020-02-11T05:56:37-06:00


lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: 2020-02-11T05:56:50-06:00

type: "page"
#theme: "league"

weight: 5
---

This is a distilled version of [Go: GVM and Portable-ish Workspaces (Part 1: Setup)](https://karlredman.github.io/Articles/dev.to/go_gvm_and_portable-ish_workspaces_part_1_setup/)

* GVM repo: [moovweb/gvm: Go Version Manager](https://github.com/moovweb/gvm)


1. Add this to toward the bottom of your `.bashrc` so `.gvm` can function

```sh
[[ -s "/home/karl/.gvm/scripts/gvm" ]] && source "/home/karl/.gvm/scripts/gvm"
```

2. Add this alias to your `.bashrc` (after the preceding entry)
  * You will need this to reset permissions for `gvm` managed `pkgset` directories -because `gvm` is flaky like that

```sh
alias "gvm_pkgset_perms"="find $HOME/.gvm/pkgsets -type d -exec chmod 770 {} \; && find $HOME/.gvm/pkgsets -type f -exec chmod 660 {} \;"
```

3. Add this to your `.bashrc` so you don't polute your `global` `gvm pkgset`
  * Add after the previous 2 lines above
  * Polluting your *gvm global pkgset* is **VERY BAD**

```sh
gvm pkgset create NONE >/dev/null 2>&1
gvm pkgset use NONE
```

4. Sanity check `.bashrc`. Your file should look like this:

```sh
# ...
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
alias "gvm_pkgset_perms"="find $HOME/.gvm/pkgsets -type d -exec chmod 770 {} \; && find $HOME/.gvm/pkgsets -type f -exec chmod 660 {} \;"
gvm pkgset create NONE >/dev/null 2>&1
gvm pkgset use NONE
# ...
```

5. Install GVM (uninstall first if already installed)

```sh
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
```

6. Open a **NEW** terminal - just do it and don't argue
  * You should be able to access `gvm` functions -try `gvm pkgset list`
    * You should see `=> NONE`

7. Set the `gvm pkgset` to `global`

```sh
gvm pkgset use global
```

8. Install go *binary* version `1.4` via gvm

```sh
gvm install go1.4 -B
```

9. set the current version of to to `1.4`

```sh
gvm use go1.4
```

10. Install/compile a newer version of `go`

```sh
gvm install go1.13.7
```

11. Set the new current version of `go` as default

```sh
gvm use go1.13.7 --default
```

12. Install global level packages (i.e. for vim)
  * see original document for this information

13. **IMPORTANT** set `gvm pkgset` to `NONE`

```sh
gvm pkgset use NONE
```

I advise you to restart your terminal sessions at this time only so you don't accidentally pollute your global package set workspace. Otherwise, that's it!



