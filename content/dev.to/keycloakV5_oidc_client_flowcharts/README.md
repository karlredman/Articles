## Keycloak v5 + Gatekeeper v5: Flowcharts - Easily Create and Restrict an Isolated (IODC) Client Service by Group-Role.

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

keycloak-client-group-auth.plantuml

![Flowchart-Legend.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group/Flowchart-Legend.png)

![keycloak-create-client-proxy.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group/keycloak-create-client-proxy.png)

![keycloak-gatekeeper-group-auth.png](https://raw.githubusercontent.com/karlredman/My-Articles/master/Artifacts/keycloak-flowcharts/simple-isolated-iodc-proxied-group/keycloak-gatekeeper-group-auth.png)

