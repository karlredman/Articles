---
title: "Keycloak v5 + Gatekeeper v5: Flowcharts - Easily Create and Restrict an Isolated (IODC) Client Service by Group-Role"
published: true
public_article: true
description: "Flowcharts for easily creating Keycloak clients and restricting authorization to user groups."
categories: [admin,web,auth]
tags: [keycloak,administration,flowchart,gatekeeper]
canonical_url: null
published_url: https://dev.to/karlredman/keycloak-v5-gatekeeper-v5-flowcharts-easily-create-and-restrict-an-isolated-iodc-client-service-by-group-role-53h4
is_public: true

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: 2019-04-28T13:12:51-05:00

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: 2019-06-23T13:12:51-05:00

slug: null

hide: false
alwaysopen: false

toc: true
type: "page"
#theme: "league"
hasMath: false

revealOptions:
  - transition: 'concave'
  - controls: true
  - progress: true
  - history: true
  - center: true

draft: false
weight: 5
---


This is another artifact from an upcoming series of articles that I'm writing for creating a home/laptop development laboratory ecosystem. I'm sharing these artifacts now because the series that I'm writing won't be released for at least a month (It's a huge undertaking -for me).

These flow charts demonstrate the simplest form (IMHO) of creating Keycloak client services behind an authentication/authorization proxy (Keycloak Gatekeeper). I imagine that if you are reading this article you are already frustrated with just creating a simple client in Keycloak and/or trying to figure out how to restrict authorization so that only specific users of a group are allowed to log in via Keycloak. Hopefully this is enough of a clue to help people until I am able to publish the article series as a whole.

### Artifact Specifics:

* Keycloak v5
* Keycloak Gatekeeper v5
* Original PlantUML source + Image Files: [here](https://github.com/karlredman/My-Articles/tree/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group)
* Original source edited with:
  * vim [iamcco/markdown-preview.nvim: markdown preview plugin for (neo)vim](https://github.com/iamcco/markdown-preview.nvim)
  * VSCode [PlantUML - Visual Studio extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml)
* *NOTE:* While current (v6.0.0) Keycloak documentation specifies that groups can be used directly in `Keycloak Gatekeeper` only role based authorization is available in V5.0.0.



### Flowchart Caveates:

* whoami: The example client service being created
* auth_user: A User created to log in the whoami service
* whoami_group: A User Group mapped to a client role for authorization by Keycloak Gatekeeper
* https://whoami.example.com: The URL of our client service

### Relevant Documentation References:

  * [Securing Applications and Services Guide](https://www.keycloak.org/docs/latest/securing_apps/index.html#_keycloak_generic_adapter)

![Flowchart-Legend.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group/Flowchart-Legend.png)

![keycloak-create-client-proxy.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group/keycloak-create-client-proxy.png)

![keycloak-gatekeeper-group-auth.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group/keycloak-gatekeeper-group-auth.png)


