---
title: "Navigate your vscode like it's 1999 (the vim way)"
public_article: [true]
description: "Navigate your vscode like it's 1999 (the vim way)"
categories: [admin,shortcuts,vscode]
tags: [vscode,navigation,vim,shortcuts]
canonical_url: https://github.com/karlredman/My-Articles/wiki/
published_url:

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-03-15T07:44:19-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-06-23T07:44:19-05:00"

slug: null

hide: false
alwaysopen: false

toc: true
type: "page"
#theme: "league"
hasMath: false

draft: false
weight: 5
---

If you are a vim person it can be frustraiting to work in vscode without vim keystrokes. The fantastic plugin [vscodevim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) only goes so far. If you, like me, are used to `M-h,M-j,M-k,M-l` (where `M` == 'Alt key') and vim-like tab movements things get freaking nuts. Note that these keys in default vim are the same as pressing `escape` [I HATE ever having to hit the `esc` key -ever].

This configuration demonstrates how to switch to vscode easily from vim. In addition a method for you to switch tabs in a vim-like way.Lastly, these settings allow you to navigate `vscode` with bookmarks in a way you would use `marks` in regular vim.

Wait there's more! Read though the code (below) and find many vim-like jems that will make vscode feel a bit closer to home.

* Tested with:
    * vscode v1.32.1
    * vim 8.1 [how to compile](https://dev.to/karlredman/compile-and-install-vim-v81-from-source-with-pyenv-5cjc)
    * MX Linux 18.1
    * Debian Stretch 9.8

## Vim configuration (at your discretion)

### Open you current vim document in vcode

* Add this following line to your `~/.vimrc`
* This (default) means `\ov` will open the current file in vscode from vim

```vim
nnoremap <leader>ov :exe ':silent !code %'<CR>:redraw!<CR>
```

### Use `ctrl+j` and `ctrl+k` to change tabs in vim (I prefer up/down -adjust as needed)

```vim
" switch tabs (same as gt & gT)
nnoremap <C-j> :tabprevious<CR>
nnoremap <C-k> :tabnext<CR>
"
" (bonus) move tabls right or left
map <C-h> :execute "tabmove" tabpagenr() - 2 <CR>
map <C-l> :execute "tabmove" tabpagenr() + 1 <CR>
```

## VS Code changes

This get's really complicated to explain. I'm going to list the functions with examples here and then the code -edit as needed. I had to configure `keybindings.json` and `settings.json` -I haven't tried combining the configurations.

* install plugin [Vim - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim)
* install plugin [Numbered Bookmarks - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=alefragnani.numbered-bookmarks)
* config: `~/.config/Code/User/keybindings.json`
* config: `~/.config/Code/User/settings.json`

### features from `keybindings.json` (+noted settings.json)

* focus active editor (vim windows)

    * i.e. (similar to vim `C-w` shortcuts)

```json
    {
        "key": "ctrl+w j",
        "command": "workbench.action.focusBelowGroup",
    },
```

* focus window groups

    * (similar to tmux panes)

```json
{
    "key": "ctrl+w down",
    "command": "workbench.action.moveActiveEditorGroupDown",
},
```

* do nothing for `<ALT>`+`h`,`j`,`k`,`l`

    * be sure to disable menu keys in vscode settings: `Uncheck`  "Settings->Window->Enable Menubar Mneumonics"

    * Same as default vim behavior

```json
   {
    "key": "alt+h",
    "command": "extension.vim_escape",
    "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
},
```

 * create `mark`

     * see file (`/.conf/Code/User/settings.json`)

 ```json
     "vim.normalModeKeyBindingsNonRecursive": [
        {
            "before": ["m","a"],
            "commands": [
                "numberedBookmarks.toggleBookmark1"
            ]
        }
    ]
 ```

 * jump to `mark`

     * i.e. jump to `mark a`

```json
{
    "key": "' a",
    "command": "numberedBookmarks.jumpToBookmark1",
    "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
},
```

## The files / configs

At this point I think you get the idea. There are several other vim-like settins I've added into the config files but, like Vim, you'll have to read the code to find the gems.

* `~/.config/Code/User/keybindings.json`

```json
{
    "vim.easymotion": true,
    "vim.sneak": true,
    "vim.incsearch": true,
    "vim.useSystemClipboard": true,
    "vim.useCtrlKeys": true,
    "vim.hlsearch": true,
    "vim.leader": "\\",
    "vim.handleKeys": {
        "<C-a>": false,
        "<C-f>": false
    },
    "vim.normalModeKeyBindingsNonRecursive": [
        {
            "before": ["<C-n>"],
            "commands": [":nohl"]
        },
        {
            "before": ["m","a"],
            "commands": [
                "numberedBookmarks.toggleBookmark1"
            ]
        },
        {
            "before": ["m","b"],
            "commands": [
                "numberedBookmarks.toggleBookmark2"
            ]
        },
        {
            "before": ["m","c"],
            "commands": [
                "numberedBookmarks.toggleBookmark3"
            ]
        },
        {
            "before": ["m","d"],
            "commands": [
                "numberedBookmarks.toggleBookmark4"
            ]
        },
        {
            "before": ["m","e"],
            "commands": [
                "numberedBookmarks.toggleBookmark5"
            ]
        },
        {
            "before": ["m","f"],
            "commands": [
                "numberedBookmarks.toggleBookmark6"
            ]
        },
        {
            "before": ["m","g"],
            "commands": [
                "numberedBookmarks.toggleBookmark7"
            ]
        },
        {
            "before": ["m","h"],
            "commands": [
                "numberedBookmarks.toggleBookmark8"
            ]
        },
        {
            "before": ["m","i"],
            "commands": [
                "numberedBookmarks.toggleBookmark9"
            ]
        },
        {
            "before": ["m","j"],
            "commands": [
                "numberedBookmarks.toggleBookmark0"
            ]
        },
    ],
    "breadcrumbs.enabled": true,
    "workbench.activityBar.visible": true,
    "workbench.statusBar.visible": true,
    "workbench.sideBar.location": "left",
    "zenMode.hideStatusBar": false,
    "zenMode.hideTabs": false,
    "window.enableMenuBarMnemonics": false,
    "window.menuBarVisibility": "default",
    "window.zoomLevel": 1,
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false
}

```

* `~/.config/Code/User/settings.json`

```json
// Place your key bindings in this file to override the defaults
[
    {
        "key": "ctrl+w j",
        "command": "workbench.action.focusBelowGroup",
    },
    {
        "key": "ctrl+w k",
        "command": "workbench.action.focusAboveGroup",
    },
    {
        "key": "ctrl+w h",
        "command": "workbench.action.focusLeftGroup",
    },
    {
        "key": "ctrl+w l",
        "command": "workbench.action.focusRightGroup",
    },
    {
        "key": "ctrl+w down",
        "command": "workbench.action.moveActiveEditorGroupDown",
    },
    {
        "key": "ctrl+w up",
        "command": "workbench.action.moveActiveEditorGroupUp",
    },
    {
        "key": "ctrl+w left",
        "command": "workbench.action.moveActiveEditorGroupLeft",
    },
    {
        "key": "ctrl+w right",
        "command": "workbench.action.moveActiveEditorGroupRight",
    },
    {
        "key": "alt+h",
        "command": "extension.vim_escape",
        "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
    },
    {
        "key": "alt+j",
        "command": "extension.vim_escape",
        "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
    },
    {
        "key": "alt+k",
        "command": "extension.vim_escape",
        "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
    },
    {
        "key": "alt+l",
        "command": "extension.vim_escape",
        "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
    },
    {
        "key": "' a",
        "command": "numberedBookmarks.jumpToBookmark1",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' b",
        "command": "numberedBookmarks.jumpToBookmark2",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' c",
        "command": "numberedBookmarks.jumpToBookmark3",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' d",
        "command": "numberedBookmarks.jumpToBookmark4",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' e",
        "command": "numberedBookmarks.jumpToBookmark5",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' f",
        "command": "numberedBookmarks.jumpToBookmark6",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' g",
        "command": "numberedBookmarks.jumpToBookmark7",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' h",
        "command": "numberedBookmarks.jumpToBookmark8",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' i",
        "command": "numberedBookmarks.jumpToBookmark9",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "' j",
        "command": "numberedBookmarks.jumpToBookmark0",
        "when": "editorTextFocus && vim.active && vim.mode == 'Normal'"
    },
    {
        "key": "ctrl+1",
        "command": "-numberedBookmarks.jumpToBookmark1",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+2",
        "command": "-numberedBookmarks.jumpToBookmark2",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+3",
        "command": "-numberedBookmarks.jumpToBookmark3",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+4",
        "command": "-numberedBookmarks.jumpToBookmark4",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+5",
        "command": "-numberedBookmarks.jumpToBookmark5",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+6",
        "command": "-numberedBookmarks.jumpToBookmark6",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+7",
        "command": "-numberedBookmarks.jumpToBookmark7",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+8",
        "command": "-numberedBookmarks.jumpToBookmark8",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+9",
        "command": "-numberedBookmarks.jumpToBookmark9",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+shift+tab",
        "command": "workbench.action.focusNextGroup"
    },
    {
        "key": "ctrl+j",
        "command": "workbench.action.previousEditorInGroup"
    },
    {
        "key": "ctrl+pagedown",
        "command": "workbench.action.nextEditorInGroup"
    },
    {
        "key": "ctrl+w shift+-",
        "command": "workbench.action.minimizeOtherEditors"
    },
    {
        "key": "ctrl+w =",
        "command": "workbench.action.evenEditorWidths"
    },
    {
        "key": "ctrl+w v",
        "command": "workbench.action.splitEditorRight"
    },
    {
        "key": "ctrl+w s",
        "command": "workbench.action.splitEditorDown"
    },
    {
        "key": "ctrl+w c",
        "command": "workbench.action.closeActiveEditor"
    },
    {
        "key": "ctrl+w shift+k",
        "command": "workbench.action.moveEditorToAboveGroup"
    },
    {
        "key": "ctrl+w shift+j",
        "command": "workbench.action.moveEditorToBelowGroup"
    },
    {
        "key": "ctrl+w shift+h",
        "command": "workbench.action.moveEditorToLeftGroup"
    },
    {
        "key": "ctrl+w shift+l",
        "command": "workbench.action.moveEditorToRightGroup"
    },
    {
        "key": "ctrl+b",
        "command": "-extension.vim_ctrl+b",
        "when": "editorTextFocus && vim.active && vim.use<C-b> && !inDebugRepl && vim.mode != 'Insert'"
    },
    {
        "key": "ctrl+k",
        "command": "-extension.vim_ctrl+k",
        "when": "editorTextFocus && vim.active && vim.use<C-k> && !inDebugRepl"
    },
    {
        "key": "ctrl+b b",
        "command": "workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "ctrl+b",
        "command": "-workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "ctrl+b a",
        "command": "workbench.action.toggleActivityBarVisibility"
    },
    {
        "key": "ctrl+b f",
        "command": "workbench.files.action.showActiveFileInExplorer"
    },
    {
        "key": "ctrl+b n",
        "command": "workbench.action.nextSideBarView"
    },
    {
        "key": "ctrl+b p",
        "command": "workbench.action.previousSideBarView"
    },
    {
        "key": "ctrl+b m",
        "command": "workbench.action.toggleMenuBar"
    },
    {
        "key": "ctrl+b s",
        "command": "workbench.action.toggleStatusbarVisibility"
    },
    {
        "key": "ctrl+b l",
        "command": "workbench.action.toggleSidebarPosition"
    },
    {
        "key": "ctrl+b o",
        "command": "outline.focus"
    },
    {
        "key": "ctrl+b e",
        "command": "workbench.files.action.focusFilesExplorer"
    },
    {
        "key": "ctrl+b r",
        "command": "search.action.focusSearchList"
    },
    {
        "key": "ctrl+' l",
        "command": "workbench.action.togglePanelPosition"
    },
    {
        "key": "ctrl+' '",
        "command": "workbench.action.togglePanel"
    },
    {
        "key": "ctrl+j",
        "command": "-workbench.action.togglePanel"
    },
    {
        "key": "ctrl+' c",
        "command": "workbench.debug.panel.action.clearReplAction",
        "when": "inDebugRepl"
    },
    {
        "key": "meta+l",
        "command": "-workbench.debug.panel.action.clearReplAction",
        "when": "inDebugRepl"
    },
    {
        "key": "ctrl+' c",
        "command": "workbench.action.closePanel"
    },
    {
        "key": "ctrl+' space",
        "command": "workbench.action.focusPanel"
    },
    {
        "key": "ctrl+' n",
        "command": "workbench.action.nextPanelView"
    },
    {
        "key": "ctrl+' p",
        "command": "workbench.action.previousPanelView"
    },
    {
        "key": "ctrl+' shift+-",
        "command": "workbench.action.toggleMaximizedPanel"
    }
]
```
