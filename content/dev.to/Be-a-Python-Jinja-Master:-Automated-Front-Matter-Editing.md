---
title: "Be a Python Jinja Master: Automated Front Matter Editing"
published: true
description: "EditFrontMatter: A python module for editing markdown front matter using Jinja2 Templates."
categories: [dev.to,programming, utility]
tags: [python3,jinja2,markdown,front-matter]
canonical_url: https://github.com/karlredman/My-Articles/wiki/
published_url: https://dev.to/karlredman/be-a-python-jinja-master-automated-front-matter-editing-1b8a

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-06-11T23:13:35-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-06-10T23:13:35-05:00"

type: "page"
#theme: "league"

draft: false
weight: 5
---

I'm pleased to announce the initial release of EditFrontMatter: A python module for editing markdown front matter using Jinja2 Templates.

* See: [EditFrontMatter Project Homepage](https://karlredman.github.io/EditFrontMatter/index.html)
* Several examples are included in the documentation
  1. [Basic usage](https://karlredman.github.io/EditFrontMatter/examples/example1/readme.html)
  2. [Advanced mulit-pass processor](https://karlredman.github.io/EditFrontMatter/examples/example2/readme.html)
  3. [Recursive directory walker that uses multi-threading to edit files](https://karlredman.github.io/EditFrontMatter/examples/example3/readme.html)


## The Pitch:

Imagine that you could retain all of your various article and documentation content in markdown. And then cater that content to whichever static site generator[^1], and theme thereof, without manually editing each and every file. With [EditFrontMatter](https://karlredman.github.io/EditFrontMatter/index.html) you can write simple scripts, leveraging the power of [Jinja2](http://jinja.pocoo.org/), to add / edit / delete the front matter of your markdown files easily.

## A demonstration:

This is a simple example that you will also find in the documentation as [Example 1](https://karlredman.github.io/EditFrontMatter/examples/example1/readme.html). Here, we to use a Jinja2 Template to edit the front matter of a markdown file. All fields which are *not* included in the template will be ignored during editing. Furthermore, while white-space and comments will be eliminated[^2], the order of the original front matter is preserved[^3] -new fields will be appended.

* Original markdown file with yaml front matter ([example1.md](https://github.com/karlredman/EditFrontMatter/blob/master/examples/data/example1.md))

```md
---
title: "EditFrontMatter Class Example 1"
description: "Edit some fields in this front matter"
catagories: [programming, python, markdown]

deleteme: this will be deleted

tags: [front matter, administration, testing]

# comments and spaces will be eliminated (see docs)

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@example.com"
date: 2019-05-23T17:43:45-05:00
lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: 2019-05-23T17:43:45-05:00
toc: false
type: "page"
hasMath: false
draft: false
weight: 5
---

# EditFontMatter Class Example 1

Edit several fields of front matter.

## Fields affected in this example:

* toc
  * note: uses local template variable
  * pre: false
  * post: true
* draft:
  * note: uses jinja2 filter (callback)
  * pre: false
  * post: true
* hasMath
  * note: uses program variable
  * pre: true
  * post: false
* stuff:
  * note: uses program variable to create field
  * pre: did not exist
  * post: (list) ['one', 'two', 'three']
* deleteme:
  * note: removed from final result
  * pre: this will be deleted
  * post: N/A
```

* Jinja2 template that will update the front matter data of the source markdown file ([template1.j2](https://github.com/karlredman/EditFrontMatter/blob/master/examples/data/template1.j2)). Note that the `toc` field processing is overridden by the template. All local `set` Jinja variables take precedence over other processing methods.

```jinja
{% set toc = "true" %}

toc: {{ toc }}
draft: {{ false | canPublish }}
hasMath: {{ hasMath }}
stuff: {{ addedVariable }}
```

* A python program to edit the markdown file with the Jinja2 template ([example1.py](https://karlredman.github.io/EditFrontMatter/examples/example1/example1.html):

This program/script uses a [Jinja2 template filter](http://jinja.pocoo.org/docs/2.10/templates/#filters) and a callback function, specified by a call to [EditFrontMatter.add_JinjaFilter()](https://karlredman.github.io/EditFrontMatter/editfrontmatter/editfrontmatter.EditFrontMatter.EditFrontMatter.add_JinjaFilter.html) to provide data for the `draft` field. In addition, specific `key, value` variable pairs are provided when [EditFrontMatter.run()](https://karlredman.github.io/EditFrontMatter/editfrontmatter/editfrontmatter.EditFrontMatter.EditFrontMatter.run.html#editfrontmatter.EditFrontMatter.EditFrontMatter.run) is called. The values from `run()` will be used to add or edit the `key, value` pairs. Lastly the instance (list) variable `EditFrontMatter().keys_toDelete` specifies which keys to delete in the front matter.

```py
#!/usr/bin/env python3
# -*- coding: utf-8 -*-


from editfrontmatter import EditFrontMatter
import os


def canPublish_func(val):
    # do some processing....
    return True


def main():

    # generic path - overridden by env var `TEST_DATA_DIR`
    DATA_PATH = "../data/"

    if "TEST_DATA_DIR" in os.environ:
        DATA_PATH = os.path.abspath(os.environ.get("TEST_DATA_DIR")) + "/"

    # set path to input file
    file_path = os.path.abspath(DATA_PATH + "example1.md")

    # initialize `template_str` with template file content
    template_str = ''.join(open(os.path.abspath(DATA_PATH + "template1.j2"), "r").readlines())
    print(template_str)

    # instantiate the processor
    proc = EditFrontMatter(file_path=file_path, template_str=template_str)

    # set fields to delete from yaml
    proc.keys_toDelete = ['deleteme']

    # add a filter and callback function
    proc.add_JinjaFilter('canPublish', canPublish_func)

    # populate variables and run processor
    proc.run({'toc': 'no effect', 'hasMath': "false",
              'addedVariable': ['one', 'two', 'three']})

    # dump file
    print(proc.dumpFileData())


if __name__ == '__main__':
    main()

```


* Final Output:

```md
---
title: EditFrontMatter Class Example 1
description: Edit some fields in this front matter
catagories:
- programming
- python
- markdown
tags:
- front matter
- administration
- testing
author: Karl N. Redman
creatordisplayname: Karl N. Redman
creatoremail: karl.redman@example.com
date: 2019-05-23 22:43:45
lastmodifierdisplayname: Karl N. Redman
lastmodifieremail: karl.redman@gmail.com
lastmod: 2019-05-23 22:43:45
toc: true
type: page
hasMath: false
draft: true
weight: 5
stuff:
- one
- two
- three
---

# EditFontMatter Class Example 1

Edit several fields of front matter.

## Fields affected in this example:

* toc
  * note: uses local template variable
  * pre: false
  * post: true
* draft:
  * note: uses jinja2 filter (callback)
  * pre: false
  * post: true
* hasMath
  * note: uses program variable
  * pre: true
  * post: false
* stuff:
  * note: uses program variable to create field
  * pre: did not exist
  * post: (list) ['one', 'two', 'three']
* deleteme:
  * note: removed from final result
  * pre: this will be deleted
  * post: N/A
```

# My Personal Use Case:

Allow me paint a picture of my workflow: I maintain a group of repositories of exclusively markdown content. This content is split up between topics ranging form a personal journal to various projects and articles in various states of completion. The number of documents I've written in the last several years is now over 1000. In order to facilitate my workflow, I want all the content to be accessible in one place while having the ability to preview these documents and, ultimately, publish them using various methods. To that end, all of my markdown files do contain a minimal about of front matter. As I publish these content files I needed some way to batch process the content files and modify their metadata.

I use [vimwiki](https://vimwiki.github.io/) for editing all of my markdown content. Vimwiki allows me to easily index various topics, keep topic related diaries, and otherwise edit content using [Vim](https://www.vim.org/): my 'go to' editor of choice. All of my various projects and topic related content are tracked in individual [git](https://git-scm.com/) repositories and imported to a 'working tree' as [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules). This makes adding, archiving, and modifying topics very simple.

My personal development ecosystem uses a static site generated by [Hugo](https://gohugo.io/) to host content (my knowledge base - I use [docdock theme](https://themes.gohugo.io/docdock/) by the way). This static site is plugged into my ecosystem's build system ([drone](https://drone.io/)). When I edit any document within the `working three`, and push that content to my git repository, my [Gitea](https://gitea.io) instance picks up the change and triggers a drone build.

In turn, drone builds my searchable knowledge base and publishes it to be hosted by my ecosystem's web server. From a `git push` to the content showing up through my web services, the total time is `< 1 minute`. And that includes the processing [EditFrontMatter](https://karlredman.github.io/EditFrontMatter) does to set the front matter fields needed for any number of specific themes and other purposes (i.e. like changing the 'edit this page' link in front matter to point to the corresponding content's Gitea `edit page` of the document itself: online editing of the content is a built in bonus!).

With the help of EditFrontmatter, I can easily change the 'edit this page' URL pragmatically when I decide to move, for instance, a project from my personal knowledge base to a publishing entity (such as Github). I no longer worry about having to manually edit a bunch of content files in order to change the Hugo theme, or change the static site generator being used.

The scripts that I have in place use a set of Jinja Templates that perform these actions for me. And it takes mere seconds to produce accurate results instead minutes of error prone tedious editing. While this all might seem complicated, it really isn't. Most of, if not all, of these steps are things we do as developers anyway. This is my attempt at streamlining the process since it's a well defined workflow.

# Conclusion:

In previous articles I've mentioned that many of the, said, articles are interrelated. I've also eluded to the fact that I am working on a much larger, and more complicated, set of documentation for a project that I'm working on -building a complete development ecosystem you can use anywhere. While EditFrontmatter is a small class/module (less than 150 lines of code), the documentation is 1000's of lines of text. And that is the nature of documentation -the product is always much shorter than the documentation relative to lines of code.

The power of markdown is that I can continue writing the content of my project's documentation without having to necessarily worry about how I will eventually publish it -or where I will publish it. In fact, because EditFrontMatter provides the ability to easily manipulate the metadata of the content I create, I can review changes in near real-time in a variety of publishing entities. I'm not 'vendor locked' and neither is my project. Furthermore, depending on the build system I use, I can easily include content from one document to the next within the markdown itself -promoting the 'write it once' concept.

Lastly, if you are curious about how I generated the [Sphinx Read The Docs Theme](https://sphinx-rtd-theme.readthedocs.io/en/stable/) documentation to be hosted via [Github Pages](https://help.github.com/en/articles/configuring-a-publishing-source-for-github-pages) check out the [About Theme](https://karlredman.github.io/EditFrontMatter/about_theme/about_theme.html) section on the EditFrontMatter home page. And if you would like to read about why I'm using `reST` and `python` to to build static pages for `Hugo`, check out the [FAQ](https://karlredman.github.io/EditFrontMatter/faq.html).

Now go be a Python Jinja Master!


[^1]: Popular site generators that support markdown front matter: Directly - [Gatsby](https://www.gatsbyjs.org/docs/adding-markdown-pages/#add-a-markdown-file), [Hexo](https://hexo.io/docs/front-matter), [Hugo](https://gohugo.io/content-management/front-matter), [Jeykyll](https://jekyllrb.com/docs/front-matter/). Indirectly - [Netlify CMS](https://www.netlifycms.org/docs/nextjs/), [Next.js](https://jaketrent.com/post/serve-markdown-nextjs-server/), [Nuxt](https://dzone.com/articles/including-markdown-content-in-a-vue-or-nuxt-spa). [And Many more ...](https://www.staticgen.com/)

[^2]: Future versions of this module may provide extra functionality, like preserving comments, via [ruamel.yaml](https://yaml.readthedocs.io/en/latest/overview.html); depending upon frequency of requests for such features.

[^3]: EditFrontMatter uses [oyaml](https://github.com/wimglenn/oyaml) to preserve the order front matter. (see footnote `2`)


