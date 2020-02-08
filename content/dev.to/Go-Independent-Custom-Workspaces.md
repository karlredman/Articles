---
title: "Golang: Independent Custom Workspaces"
published: true
description: "Customizing Go workspaces with symlinks."
categories: [dev.to,programming,devops,administration]
tags: [go,workspace,mentalhealth,development]
canonical_url: https://github.com/karlredman/My-Articles/wiki/
published_url: https://dev.to/karlredman/go-independent-custom-workspaces-5d27

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: 2020-02-08T02:53:15-06:00


lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: 2020-02-08T02:53:33-06:00

type: "page"
#theme: "league"

weight: 5
---


Up to and including `go1.13.7`, `$GOPATH`, `$GOBIN` and the `Go toolchain` make it very difficult to isolate the `Go Workspace` for any *development* / *production* / *runtime* environments outside of the `Go Contributers'` agenda and scope of ideology.

This article attempts to illustrate how one might go about working around these *severe* `Go` environment limitations. Also, I'm a big fan of `golang` and I want to use it in a more wide ranging and versatile real-world environment.

* I'll start by trying to describe the problems while offering generic solutions. As this document progresses the workarounds will be more specific.

## What's the problem(s)?

### But it's `Go`, we're special!

No, Go is is not special. It's a top notch development platform but forcing programmers and administrators to treat it special is not just annoying, it makes people hate it. Administrators  and developers don't need special, they need to be able to implement and use Go without retooling their entire workflows and environments.

### Features of this hack

* Ability to set a custom workspace root (i.e. proper dependency resolution from a custom path)
* `go build` and `go build <package/module name>` works from the *custom workspace root*
* `go test` and `go test -v --bench . --banchmem <package/module name>` works from the *custom workspace root*
* `go install` will install a built binary in the *custom workspace root* `bin/` directory
  * to create a properly named binary I recommend that you use

  ```sh
  go build [-i] -o bin/<binary name>
  ```

* Dependencies will be installed in the `pkg/` subdirectory of the *custom workspace root*

### Impediments of Current Go Workspaces:

* Production coding disasters *do* happen -The `Go` workspace enforcement by the tool chain increases the complexity (and thereby delays) of performing real-time `hot fixes` on production systems
  * Wrangling with the environment of your development tools is the last thing you want to do when you just need to drop a file somewhere in the heat of the moment.
* Collaborative containersized environments become broken unless developers, testers, and admins all agree on the build/development layout
  * Specifically containerized work environments like [Singularity](https://en.wikipedia.org/wiki/Singularity_(software)) are affected because of the nomadic nature of their workflows
  * Inflexible workspace layouts like `Go` forces upon developers and testers and admins increased *time to product* during collaborative endeavors
* CI/CD operations are forced to keep separate file paths for various development, product, and testing artifacts -again increasing complexity and possible *tech debt*
* Development, testing, production, and administration *one offs* are overly complex and require too much knowledge about the environment to be effective
  * See below for my 'Ugly Real World Example' where I manage to just add a `main.go` in a flat directory structure in order to take `Go` code challenges
  * In cases where full blown environments aren't shared `Go` becomes very cumbersome to work with when trying to just test out some code
  * Not everyone has the time or patience to learn every aspect of how `Go's` *special* environment needs can be dealt with properly -cheap workarounds had to be found ...

### Details of issues with enforced Go workspace environments:

* `$GOPATH` and `$GOBIN` are required to be set up manually for isolated project roots
  * **Fix/Hack**: use an environment script for this (**execute from the project root**)

    ```sh
    # build_env
    # from project root run: `source <this file>`
    # only use this from the project root !!!!
    THIS_PROJECT_PATH=$(pwd)

    export GOPATH=$GOPATH:$THIS_PROJECT_PATH
    mkdir -k $THIS_PROJECT_PATH/bin
    export GOBIN=$THIS_PROJECT_PATH/bin
    ```

* *Packages* require(ish) the directory name to be the same as the name of the package
  * While it's [possible](https://stackoverflow.com/a/43580332/1725771) to use custom paths for Packages and Modules -It's a `PITA`.
  * **Hack**: solved with symlinks if needed
* *Packages* and modules are hard coded in the `Go` tool chain to be under `$GOPATH/src`
  * You can read about the various opinions and examples of this obtrusive behavior [here](https://github.com/go-lang-plugin-org/go-lang-idea-plugin/issues/215)
  * Basically you see a lot of similar ["get used to it"](https://stackoverflow.com/a/39534720/1725771) kind of attitude thrown about in this regard
  * **Hack**: solved with symlinks if needed
* `import` paths for *modules* **require** a `.` (dot) in the top most directory
  ```go
  // REQUIRED '.' notation
  import "example.com/myuser/myproject/platform"
  ```

  * There are no settings that alter this behavior
    * see: [The Go Programming Language - Module configuration for non-public modules](https://golang.org/cmd/go/#hdr-Module_configuration_for_non_public_modules)
  * This standard may change soon
    * [cmd/go: confusing error "missing dot in first path element" when importing missing package  Issue #35273](https://github.com/golang/go/issues/35273)


  * **Hack**:solved with symlinks if needed


* `$GOBIN` is a single path for *where to put executable build artifacts*
  * This forces executables from a project to either:
    * all reside in a custom `$GOBIN`
    * be installed in `$GOROOT/bin`
  * `$GOBIN` **does not have a workaround** when it comes to `go install`. Effectively making `go install` useless
    * the only way to keep `$GOROOT/bin` from becoming polluted is to use a single custom "user space wide" `$GOBIN`
  * Binaries **can** be built with any target path however
    ```sh
    go build [-i] -o <path/binary_file>
    ```

## EEEP! Using Symlinks to Solve Path Issues:

This whole article started out as personal notes on how I could get the flat structure used by [exercism.io](https://exercism.io) to work as a `git` backed workspace for `Go` and the other languages I plan to practice on at that site. I'd been struggling on and off with workspace environment issues/annoyances for a while so I finally decided to just see what it would take to completely customize the `Go` workspace in as few steps as possible.

The answer was, ugh, symbolic links. Any other fixes I came up with were just too complex (IMHO) or invasive. This was a way to *`just get it over with`*.

* In the below example it's important to note that `exercism` is a self contained binary that downloads a code challenge from [exercism.io](https://exercism.io) into an non-configurable directory path (`~/exercism`) and imposes a directory structure as shown (minus the symlinks I created).
* This is one program that imposes these kinds of things that makes `Go` very difficult to use or experiment with overall. This is only one scenario.

### Ugly Real World Example:

* Packages and Modules requiring a `<workspace>/src/<package-module>` directory structure can be worked around by using symlinks.
  * we use symlinks to satisfy both module and package requirements
* In the directory tree below we see that the `exercism` binary forces a directory structure for `go` based code challenges.
* In order to stay compatible with `exercism` and the `go` tool chain we use symlinks to make it appear that go modules and packages are found under the `src/` directory.
* Also we've added a link, `greeting` to satisfy the naming convention go uses for packages and their respective directory names.
* The `main.go` file is intended to be used to execute the code challenges as desired

```sh
~/exercism:
├── go
│   ├── .git                        # the git repo dir
│   ├── bin
│   ├── greeting -> hello-world     # package name link to satisfy `greeting`
│   ├── hello-world                 # A project (package/module `greeting`)
│   │   ├── go.mod                  # `greeting` module file
│   │   ├── hello_world.go          # `greeting` package file
│   │   ├── hello_world_test.go     # `greeting` module test file
│   │   └── README.md
│   ├── local.localhost -> .        # `greeting` module path
│   ├── main.go                     # project main
│   ├── README.md
│   ├── src -> .                    # link to satisfy packages and modules are under `$GOPATH/src/`
│   └── util
│       └── build_env               # script to set environment variables
└── README.md
```

* In this case a package `import` will look like this

  ```go
  package main

  import (
      "fmt"
      "greeting"
  )

  func main() {
      fmt.Println(greeting.HelloWorld())
  }
  ```

* a module `import` will look like this

  ```go
  package main

  import (
      "fmt"

      "local.localhost/greeting"
  )

  func main() {
      fmt.Println(greeting.HelloWorld())
  }
  ```

* for reference here are the package and module files under `hellow-world` directory
  * note that `hello-world` is linked as `greeting` and that we've created a link for `src/` as well -all under the same "workspace tree"
  * `hello-world/go.mod`

    ```go
    module greeting

    go 1.13

    ```

  * `hello-world/hello_world.go`

    ```go
    package greeting

    func HelloWorld() string {
        return "Hello, World!"
    }
    ```

[ Originally published 20200207 [Go: Independent Custom Workspaces - DEV Community 👩‍💻👨‍💻](https://dev.to/karlredman/go-independent-custom-workspaces-5d27) ]

