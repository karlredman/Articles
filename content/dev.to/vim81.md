---
title: "Compile and install vim 8.1 from source (debian / MX Linux) with pyenv"
public_article: true
description: "Compile and install vim 8.1 from source (debian / MX Linux) with pyenv"
categories: [dev.to,admin,linux,howto]
tags: [vim,debian,howto,compile]
canonical_url: https://github.com/karlredman/Articles/blob/master/content/dev.to/vim81.md
published_url: https://dev.to/karlredman/compile-and-install-vim-v81-from-source-with-pyenv-5cjc
published: true

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-03-15T07:41:28-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-06-23T07:41:28-05:00"

slug: null

hide: false
alwaysopen: false

toc: true
type: "page"
#theme: "league"
hasMath: false

weight: 5
---

* The purpose of this article is to aid those who want to run cutting edge vim things.

* Vim 8.1 provides `:terminal`. This is **BIG NEWS** and has opened some pretty cool plugins such as [markdown preview plugin for (neo)vim](https://github.com/iamcco/markdown-preview.nvim). Additionally, if you want [deoplete.nvim](https://github.com/Shougo/deoplete.nvim) to work properly you'll need to compile vim against python3 anyway. The most single/main user way I've found to make these plugins work is to compile Vim from source. This is a method that I feel is least obtrusive to a single systerm.

* This HowTo will add vim v8.1 to your system under '/usr/local' and set it as default (with python 3.7.2 and other common necessities -adjust as needed)

* This method follows the 'don't break debian' mantra as close as possible IMHO.

* Disclaimer: !! Test in a VM or otherwise at your own risk !!!

* Tested with:
    * MX Linux v18.1
    * Debian Stretch v9.8


* references:
    * [Building Vim from source · Valloric/YouCompleteMe Wiki](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source)
	* [Building Vim 8 from source.](https://gist.github.com/Pompeu/c711b6e35f3ae5deb5e81a938c3cc507)
    * [Home · pyenv/pyenv Wiki · GitHub](https://github.com/pyenv/pyenv/wiki#how-to-build-cpython-with---enable-shared)
    * [How to install ipython qtconsole with pyenv (Python version 3.4.2) - Stack Overflow](https://stackoverflow.com/questions/28165637/how-to-install-ipython-qtconsole-with-pyenv-python-version-3-4-2)
    * [c - Compiling vim with statically linked python support in a non-standard path configuration - Stack Overflow](https://stackoverflow.com/questions/40311073/compiling-vim-with-statically-linked-python-support-in-a-non-standard-path-confi)

### Install and setup pyenv

`pyenv` provides a localized python, versioned, installation at the user level.

* reference: [pyenv/pyenv-installer: This tool is used to install `pyenv` and friends.](https://github.com/pyenv/pyenv-installer)

```sh
curl https://pyenv.run | bash
```

* config: add to your `~/.bashrc` file and relogin (terminal or desktop env)

```sh
# Load pyenv automatically by adding
# the following to ~/.bashrc:

export PATH="/home/karl/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

* install a python version

```sh
# list available versions
pyenv install -l |less
# insta a version
pyenv install 3.7.2
```

* set a python version for global

```sh
pyenv global 3.7.2
```

### Script for vim compile and installation

```bash
#! /usr/bin/env bash

# Install vim from source on a debian based system where pyenv is used at thhe user level.
## The python version must already be installed via pyenv
## `pyenv install 3.7.2`
## It is not necessary remove debian installed vim packages


# fail on any error (fix things as needed)
set -e

# Convenience variables
FULL_VERSION="3.7.2"
MM_VERSION="3.7"
VIM_CONENSED_VER="81"
VIM_TAG="v8.1"
BUILT_BY="Karl N. Redman <karl.redman@gmail.com>"

# Install dependencies (note no python-dev here)
sudo apt install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev \
ruby-dev lua5.1 liblua5.1-dev libperl-dev git

# Checkout vim
git clone https://github.com/vim/vim.git
cd vim

# make sure the repo is clean
make distclean

# (optional) Checkout the specific desired version
## umcomment to use specific tagged version
# git pull --tags
# git checkout tags/${VIM_TAG}

# Run `Configure`
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --with-x \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local \
            --with-compiledby="${BUILT_BY}" \
            --enable-python3interp=yes \
            --with-python3-config-dir=$HOME/.pyenv/versions/${FULL_VERSION}/lib/python${MM_VERSION}/config-${MM_VERSION}m-x86_64-linux-gnu \
            --includedir=$HOME/.pyenv/versions/${FULL_VERSION}/include/

# Make and set the runtime directory (non default to avoid conflicts)
make VIMRUNTIMEDIR=/usr/local/share/vim/vim${VIM_CONDENSED_VER}

## (optional) uncomment to remove current vim if desired
# sudo apt remove -y vim vim-runtime gvim vim-tiny vim-common vim-gui-common vim-nox

# install (to usr local)
sudo make install

# update alternatives to set our new build as default
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

echo "done."
```

## That's it!

* relogin (if necessary) and `vim --version` should report `v8.1`! Now you can try out `:terminal` to make sure it's working ... and take advantage of the new plugins that are a comming!
