---
title: "Go: GVM and Portable-ish Workspaces (Part 1: Setup)"
published: true
description: "Customizing Go workspaces with gvm (setup)."
categories: [dev.to,programming,devops,administration]
tags: [go,administration,mentalhealth,development]
canonical_url: https://github.com/karlredman/My-Articles/wiki/
published_url:

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: 2020-02-11T06:10:31-06:00


lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: 2020-02-11T06:10:41-06:00

type: "page"
#theme: "league"

weight: 5
---

This is an article about getting (linux based) `gvm` up and running and how to manage portable workspaces. `gvm` is geared for use with `bash` shell but should work with most other shells -millage may vary.

Admittedly, this is a long post with a lot of specific information that is important to running `gvm` efficiently. I promis you that, while the content here seems arduious, tasks outlined here will save you a lot of time and frustration in the future. Also, honestly, it's not really as bad as it looks :D

* Side Note: I've found this page to be very helpful/interesting: [An Overview of Go's Tooling - Alex Edwards](https://www.alexedwards.net/blog/an-overview-of-go-tooling)

* A "distilled" (short) version of this article can be found here: [Go: GVM and Portable-ish Workspaces (Part 1: Setup DISTILLED) | Articles](https://karlredman.github.io/Articles/dev.to/go_gvm_and_portable-ish_workspaces_part_1_setup_distilled/)
* This article was originally published on [dev.to](https://dev.to/karlredman/go-gvm-and-portable-ish-workspaces-part-1-setup-2nko)

## Drawbacks of native Go installations

* Do read over the native install documents: [Getting Started - The Go Programming Language](https://golang.org/doc/install?download=go1.13.7.linux-amd64.tar.gz)
* Additional versions of `go` require an additional directory `$HOME/sdk`
* No concept of isolated packages or package groups
* No ability to collaborate via packaged workspaces (i.e. tarballing a directory structure, et al.)

## Why GVM?

From my perspective, the purpose behind using `gvm` is not so much about managing different versions of `go` but, rather, managing package and module dependencies. My development practices require that I'm able to 'clean' my workspace at any time and start fresh with new downloads of dependencies -as needed.

Likewise, `gvm` offers the ability to switch between dependency groups quickly with the use of 'package sets'.

Lastly, IMHO `gvm` leaves a lot to be desired. But I don't have the time/energy to try to make it better or replace it so, this is the best that I have to work with. Again, my primary focus is on environmental package and module management. GVM is the only system that acknowledges that this is an important part of development in `go`.

* It's all we got! (for now)
* Ease of installation
* Multiple go versions and environments
* Isolation of packages and modules via `pkgsets`
* Go `module mode` is not fully universally accepted (yet) so package management is still needed
* Ability to collaborate workspace environments in any way you choose (that is not intrusive to people you share your code with -or their environments)

## Drawbacks of GVM

* The `go` environment is global to the user environment
  * this means that whatever actions you take, i.e. `gvm use go1.13.7` will be the version of `go` for all terminals (unless manually changed per terminal)
* `gvm` sets package and module files and directories to `read only` for all package sets -i.e. `$HOME/.gvm/pkgsets`
  * this renders `gvm pkgset [delete || empty]` useless unless permissions are set correctly
  * The fix for this is as follows:
    * reset permissions for package sets

      ```sh
      # set pkgset directories to be accessible to the user
      find $HOME/.gvm/pkgsets -type d -exec chmod 770 {} \;
      #
      # set pkgset files to be accessable to the user
      find $HOME/.gvm/pkgsets -type f -exec chmod 660 {} \;
      ```

  * A bash alias for setting the `pkgset` directories and files is useful here
    * Must be run every time before `pkgset [delete || empty]`
    * This is an annoying bug/feature of `gvm` unfortunately
    * Reference: [ERROR: Couldn't remove pkgsets · Issue #319 · moovweb/gvm](https://github.com/moovweb/gvm/issues/319)

    ```sh
    # This will run for a few seconds....
    alias "gvm_pkgset_perms"="find $HOME/.gvm/pkgsets -type d -exec chmod 770 {} \; && find $HOME/.gvm/pkgsets -type f -exec chmod 660 {} \;"
    ```
  * Go `module mode` is a generally more opaque and troublesome environment for gvm
    * [How can i use my own GOPATH default? · Issue #277 · moovweb/gvm](https://github.com/moovweb/gvm/issues/277)

* Package sets **Do NOT** have `defaults`
  * You **MUST** set the `package set` **every time** you create a new terminal
    * I use `tmux/tmuxinator` so I rarely ever have to worry about this... a terminal-ish is always running with my environment active
    * Reference: [How to set my pkgset as default · Issue #304 · moovweb/gvm](https://github.com/moovweb/gvm/issues/304)

## Setting up `gvm`

### uninstall `gvm` (if installed)

In order to have a clean `gvm` environment I suggest first uninstalling `gvm` if it is already installed. While using `gvm` seems straightforward, there are some nuances that can cause `gvm` to set incorrect permissions and may cause problems if you are not aware of them -or how to navigate a proper `gvm` workflow

* Uninstall

```sh
cd
gvm implode
```

  * Note: if gvm doesn't uninstall properly nuke the entire `$HOME/.gvm` directory
    * One reason `gvm implode` may fail is if file permisions were set to `read only` when using `gvm` improperly

    ```sh
    cd
    [sudo] rm -rf $HOME/.gvm
    ```

### Installing `gvm`

* Review the install instructions of the `gvm` project repository: [moovweb/gvm: Go Version Manager](https://github.com/moovweb/gvm#installing)
* Here's a link for `fish` shell users: [Fish shell support · Issue #137 · moovweb/gvm](https://github.com/moovweb/gvm/issues/137#issuecomment-543942520), also try this if needed: [oh-my-fish/plugin-gvm](https://github.com/oh-my-fish/plugin-gvm)
* Install gvm via the `bash` script
  * This will install the latest version from `master` branch

```sh
# install curl if needed (ubuntu/debian: `sudo apt install curl`)
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
```

* Follow the instructions from the output of the script.
  * Use `source` to include `gvm` to initialization script from command line to use the current terminal

    ```sh
    source /home/karl/.gvm/scripts/gvm
    ```

  * Ensure that the `bashrc` equivalent file will source the script. Mine appears as follows:

    ```sh
    # .bashrc
    [[ -s "/home/karl/.gvm/scripts/gvm" ]] && source "/home/karl/.gvm/scripts/gvm"
    ```

* Install `go version 1.4` to allow for compiling newer versions of go
  * `go version 1.5+` are pure go implementations and can not be compiled using a `c compiler`
  * In order to compile go language from scratch you will either need to download the desired binary version or build from scratch after downlading `v1.4`
  * You can choose to use a newer version of go over `1.4` but *do not* binary install the version you intend to develop with -you will want the development files for development later

```sh
# download a binary only bootstrap version of go
gvm install go1.4 -B
```

* Set the bootstrap version as current

```sh
gvm use go1.4
```

* Select and download the version of go that you want to compile and install

```sh
# show available versions
gvm listall
# compile/install the version you want/need
gvm install go1.13.7
```

* Select the go version to use as default

```sh
gvm use go1.13.7 --default
```

### Reopen your terminal. I **HIGHLY** advise this!!!!

Closing out your terminal and reopening (even with tmux/screen shut it all down) and opening a new terminal session will ensure that your environment is working properly.

* Things to check after opening a new terminal

  * Go version (output)

    ```sh
    $ gvm list

    gvm gos (installed)

    => go1.13.7
       go1.4
       system
    ```

### Install global level packages

This section is *optional*. Use the `gvm` `global` package set to install modules and packages that you want to be part of all other package sets.


* A note about `gvm` package sets:
  * Package sets in GVM are a way for you to isolate your dependencies so you can work independently among different projects and be assured that you are importing packages and dependencies without worry of 'grabbing the wrong one'

#### Install `vim-go` go packages in global package set (optional)

I use [fatih/vim-go: Go development plugin for Vim](https://github.com/fatih/vim-go) and will be installing the required packages for that `vim plugin` in the *`gvm` global package set*. A tutorial for Plug can be found here: [tutorial · junegunn/vim-plug Wiki](https://github.com/junegunn/vim-plug/wiki/tutorial)

* Make sure you are using the global package set
```sh
gvm pkgset list
```

* Expected output from `gvm pkgset list`

```sh
gvm go package sets (go1.13.7)

=>  global

```

* Be sure that your `.vimrc` equivalent file installs `faith/vim-go` (I use Plug)

```sh
Plug 'fatih/vim-go'                         "needs :GoInstallBinaries or :GoUpdateBinaries
```

* Install the plugin from the command line

```sh
vim +PlugInstall +qall
```

* Install go dependencies for the `vim-go` plugin

```sh
vim +GoInstallBinaries +qall
```

* Install missing `gopls`
  * Go package `gopls` is needed for `vim-go` but the `:GoInstallBinaries` fails to download and install it properly -so we do it manually

```sh
go get golang.org/x/tools/gopls
```

### **IMPORTANT:** Create a Package Set other than `global`

* Do **not** use the `global` package set for anything other than packages and modules you will need for overall development work

    ```sh
    gvm pkgset create NONE      # used for a default -see ### Cleaning Up Your `global` Package Set
    gvm pkgset create Scratch
    gvm pkgset use Scratch
    ```

* output

  ```sh
  Now using version go1.13.7@Scratch
  ```

### Cleaning Up Your `global` Package Set - Keep `global` pure!

Basically, if you polute your `global` package set you are **screwed**. Never, ever, polute the global package set!

**Add this to your `.bashrc` equivalent:**

```sh
# add after sourcing gvm
gvm pkgset create NONE >/dev/null 2>&1
gvm pkgset use NONE
```

The **only** way to clean up your *package set* is to just *delete* the entire version of `go` that the set is associated with. This can be a PITA and, in the case of having `vim-go` default packages in global space, time consuming -up to 30 min of active terminal time.

Don't bother trying to delete packages from global package sets (i.e. `$HOME/.gvm/pkgsets/go1.13.7/global/pkg/[...]`). The way `gvm` works is that everything ends up in the global folders in one way or another. Obviously this is a *huge* flaw in `gvm`.

## Listing your currently installed Go Packages and Modules

* Reference 1: [How to list installed go packages - Stack Overflow](https://stackoverflow.com/a/28166550/1725771)
* Reference 2: [Can I list all standard Go packages? - Stack Overflow](https://stackoverflow.com/questions/55807322/can-i-list-all-standard-go-packages)
  * Drama regarding this question: [Tired of Stack Overflow](https://www.arp242.net/stackoverflow.html)

### various `go list` options (from least output to most)

The dependencies shown are from the example code found here: [Using Go Modules - The Go Blog](https://blog.golang.org/using-go-modules) which is a basic `hello world` module with dependencies.


* list local high level packages in this directory structure

```sh
$ go list ./...
example.com/hello
```

* list packages imported by project in this directory

```sh
$ go list -f "{{.ImportPath}} {{.Imports}}" ./...
example.com/hello [rsc.io/quote]
```

* list all dependencies of the project directory that you are in

```sh
$ go list -m all
example.com/hello
golang.org/x/crypto v0.0.0-20191011191535-87dc89f01550
golang.org/x/mod v0.1.1-0.20191105210325-c90efee705ee
golang.org/x/net v0.0.0-20190620200207-3b0461eec859
golang.org/x/sync v0.0.0-20190423024810-112230192c58
golang.org/x/sys v0.0.0-20190412213103-97732733099d
golang.org/x/text v0.3.0
golang.org/x/tools v0.0.0-20200211045251-2de505fc5306
golang.org/x/xerrors v0.0.0-20191011141410-1b5146add898
rsc.io/quote v1.5.2
rsc.io/sampler v1.3.0
```

* list all packages (recursively) used by project in this directory

```sh
$ go list -f "{{.ImportPath}} {{.Deps}}" ./...
example.com/hello [bytes errors fmt golang.org/x/text/internal/tag golang.org/x/text/language internal/bytealg internal/cpu internal/fmtsort internal/oserror internal/poll internal/race internal/reflectlite internal/syscall/unix internal/testlog io math math/bits os reflect rsc.io/quote rsc.io/sampler runtime runtime/internal/atomic runtime/internal/math runtime/internal/sys sort strconv strings sync sync/atomic syscall time unicode unicode/utf8 unsafe]
```

  * better looking output

    ```sh
    $ go list -f "{{.ImportPath}} {{.Deps}}" ./... | sed  's/ /\n/g'
    example.com/hello
    [bytes
    errors
    fmt
    golang.org/x/text/internal/tag
    golang.org/x/text/language
    internal/bytealg
    internal/cpu
    internal/fmtsort
    internal/oserror
    internal/poll
    internal/race
    internal/reflectlite
    internal/syscall/unix
    internal/testlog
    io
    math
    math/bits
    os
    reflect
    rsc.io/quote
    rsc.io/sampler
    runtime
    runtime/internal/atomic
    runtime/internal/math
    runtime/internal/sys
    sort
    strconv
    strings
    sync
    sync/atomic
    syscall
    time
    unicode
    unicode/utf8
    unsafe]
    ```

* list all *standard* packages that are installed

```sh
$ go list std
<VERY LONG LIST HERE>
```

* list all (flat) packages that are installed

```sh
$ go list all
<VERY, VERY LONG LIST HERE>
```

* list all (recursive) packages managed by this instance of go

```sh
$ go list ...
<VERY, VERY, VERY LONG LIST HERE>
```

# Part 1 Conclusion:

You now have a fully functioning `gvm` setup that provides a global space for required packages and modules. This setup automatically sets that `gvm pkgset` to `NONE` so you don't pollute your `global` package/module space more than necessary. And you can work within `gvm pkgset` workspaces independent from one another.

Part 2 of this article will demonstrate an example workflow to bring everything together. Hopefully you will see how working through Part 1 was worth the effort.

Reminder: a 'distilled' version of this article can be found here: [Go: GVM and Portable-ish Workspaces (Part 1: Setup DISTILLED) | Articles](https://karlredman.github.io/Articles/dev.to/go_gvm_and_portable-ish_workspaces_part_1_setup_distilled/)
