---
title: "Private Network + Traefik + Keycloak + Gatekeeper Overview (diagram)"
published: false
public_article: [true]
description: "A high level network overview of Traefik, Keycloak, and Gatekeeper working together"
categories: [dev.to,admin,network,web]
tags: [keycloak,traefik,gatekeeper,diagram]
canonical_url: https://github.com/karlredman/My-Articles/wiki/
published_url: https://dev.to/karlredman/private-network-traefik-keycloak-gatekeeper-overview-diagram-1nmn

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-04-28T12:37:00-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-06-23T12:37:00-05:00"

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

A high level network overview of Traefik, Keycloak, and Gatekeeper working together

This is yet another artifact [although ugly] from a project I'm working on. This diagram depicts a basic lab infrastructure with Traefik, Keyclaok, and Keycloak Gatekeeper working together behind a local DNS (dnsmasq). Details for how all of this actually fits together are forthcomming. For now, hopefully, it will be helpful for those who are wondering what the layout looks like when configuring these various components to work together. Note the `whoami` that is a service illustrated in a [previous post](https://dev.to/karlredman/keycloak-v5-gatekeeper-v5-flowcharts-easily-create-and-restrict-an-isolated-iodc-client-service-by-group-role-53h4).

* Original PlantUML source + Image File: [here](https://github.com/karlredman/My-Articles/tree/master/Artifacts/network-diagrams)
* Original source edited with:
  * vim [iamcco/markdown-preview.nvim: markdown preview plugin for (neo)vim](https://github.com/iamcco/markdown-preview.nvim)
  * VSCode [PlantUML - Visual Studio extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml)

![kc-kcgc-traefik_overview-1.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/network-diagrams/kc-kcgc-traefik_overview-1.png)
