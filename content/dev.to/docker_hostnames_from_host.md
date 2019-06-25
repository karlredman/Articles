---
title: "Resolve docker hostnames from host with DNS Proxy Server"
public_article: [true]
description: "Resolve docker hostnames from host with DNS Proxy Server"
categories: [network,docker,ecosystem]
tags: [network,docker,ecosystem,development]
canonical_url: https://github.com/karlredman/Articles/blob/master/content/dev.to/docker_hostnames_from_host.md
published_url: https://dev.to/karlredman/resolve-docker-hostnames-from-host-with-dns-proxy-server-1d08

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-03-03T07:35:35-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-03-03T07:35:35-05:00"

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

This article is a continuation of my previous HowTo: [Dnsmasq + NetworkManager + Private Network Setup](https://dev.to/karlredman/dnsmasq--networkmanager--private-network-setup-258l). With just a few configuration changes we will add the capability to interact with docker containers by their respective hostnames. Even though the [dns-proxy-server project](https://github.com/mageddo/dns-proxy-server) affords us this new functionality I recommend that `dns-proxy-server` only be used for development purposes.

While it's awesome to have the ability to reference individual containers by hostname during development efforts the concept doesn't scale well. In addition the [dns-proxy-server](https://github.com/mageddo/dns-proxy-server) (DPS) suffers from some performance issues that should be taken into consideration before using it as a docker service.

## Additional Features added to the [previous HowTo](https://dev.to/karlredman/dnsmasq--networkmanager--private-network-setup-258l):

* Reference FQDN-like container hostnames from the docker host
* Reference FQDN-like container hostnames from other containers
* Reference FQDN-like container hostnames via the browser without port specifications
* Consistent behavior whether your host system is online or offline
* Works with both `docker run` and `docker-compose` containers in a mixed environment
* NetworkManager functionality remains viable and effective
* Set-it-and-forget-it configuration

## Tested systems:

* MX Linux v18.1
* Ubuntu v18.10
* Debian v9.8

## Disclaimer:

* I **strongly urge** that you initially test this procedure with a virtual machine. I am not responsible if you mess up your system, data, etc.. This information is provided as is -use at your own risk.
* This article assumes that you have configured your target system as outlined in the article [Dnsmasq + NetworkManager + Private Network Setup](https://dev.to/karlredman/dnsmasq--networkmanager--private-network-setup-258l).
* Note: The use of `all-servers` setting for `dnsmasq` may produce undesirable behavior or could be considered a security risk -depending on your standards. See: [Man page of DNSMASQ](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for more information if you are concerned.

## How To:

### Allow for async nameserver lookups

* directive `all-servers` to `/etc/dnsmasq.conf`
* also sanity check the settings

```txt
all-servers         # async call to all nameservers
bind-dynamic        # could use bind-interfaces instead
listen-address=127.0.0.1
listen-address=10.127.127.1
address=/private.home/10.127.127.1
domain=private.home,10.127.127.0/24
domain=docker.devnet,172.17.0.0/24
```

* Restart dnsmasq

```sh
sudo service dnsmasq restart
```

### Add DPS configuration to NetworkManager

* DPS will always bind to address `172.17.0.2`

```sh
nmcli con modify 'Wired connection 1' ipv4.dns 172.17.0.2
nmcli con modify 'Wired connection 1 offline' ipv4.dns 172.17.0.2
#
nmcli con up 'Wired connection 1'
```

### Create DPS config file

* Create directories and file

```sh
sudo mkdir -p /opt/dns-proxy-server/conf
sudo touch /opt/dns-proxy-server/conf/config.json
```

* reference for options: [running dns-proxy-server](https://mageddo.github.io/dns-proxy-server/docs/running.html)
    * fallback dns: 8.8.8.8
    * become a secondary dns server
    * set log level to: WARNING
    * set logfile to `/opt/dns-proxy-server/dps.log`
    * allow command line ping for container names

* add DPS settings  to the config file

```json
{
	"remoteDnsServers": [ ["8.8.8.8"] ],
	"envs": [
		{
			"name": ""
		}
	],
	"activeEnv": "",
	"lastId": 0,
	"webServerPort": 0,
	"dnsServerPort": 0,
	"defaultDns": false,
	"logLevel": "WARNING",
	"logFile": "/opt/dns-proxy-server/dps.log",
	"registerContainerNames": true
}
```

### Obtain and build a docker image for testing

```sh
git clone https://github.com/karlredman/lighttpd-docker.git
#
cd lighttpd-docker
#
sudo docker build -t lighttpd .
```

### Start DPS

```sh
docker run --rm --hostname dns.mageddo --name dns-proxy-server -p 5380:5380 -v /opt/dns-proxy-server/conf:/app/conf -v /var/run/docker.sock:/var/run/docker.sock -v /etc/resolv.conf:/etc/resolv.conf defreitas/dns-proxy-server
```

### Start example containers

```sh
# start FQDN hostname docker container 1
sudo docker run -d -p 8081:80 -p 4441:443 --rm -t --name docker-container-1-name -h docker-container-1.docker.devnet --net docker.devnet  lighttpd

# start container 2
sudo docker run -d -p 8082:80 -p 4442:443 --rm -t --name docker-container-2-name -h docker-container-2.docker.devnet --net docker.devnet lighttpd

# start container 3
sudo docker run -d -p 8083:80 -p 4443:443 --rm -t --name docker-container-3-name -h docker-container-3.docker.devnet --net docker.devnet lighttpd
```

### Test pings

* note pings in offline mode will be slow due to round robin dns resolution

```sh
ping -c 4 localhost
ping -c 4 mxtest
ping -c 4 mxacer

ping -c 4 dns.mageddo
ping -c 4 docker-container-1.docker.devnet
ping -c 4 docker-container-3.docker.devnet
ping -c 4 docker-container-2-name       # fails offline mode

sudo docker exec -ti docker-container-1-name sh -c "ping -c 4 host.docker"
sudo docker exec -ti docker-container-1-name sh -c "ping -c 4 a-wildcard.private.home"
sudo docker exec -ti docker-container-2-name sh -c "ping -c 4 docker-container-3-name"
sudo docker exec -ti docker-container-3-name sh -c "ping -c 4 docker-container-1.docker.devnet"
```

### View DPS web page (doesn't seem to work for me)

```sh
http://localhost:5380
http://dns.mageddo:5380
```

### Test addresses via browser

* works
    * http://localhost:8081/hostname.html
    * http://docker-container-1.docker.devnet/hostname.html
    * http://localhost:8082/hostname.html
    * http://docker-container-2.docker.devnet/hostname.html
    * http://localhost:8083/hostname.html
    * http://docker-container-3.docker.devnet/hostname.html

* does not work
    * http://docker-container-1-name
    * http://docker-container-1-name:8081

### Test docker-compose instance

* start the container

```sh
cd lighttpd-docker
sudo docker-compose up -d
```

* test ping to the compose container

```sh
ping -c 4 docker-container-4.docker.devnet
sudo docker exec -ti docker-container-4-name sh -c "ping -c 4 a-wildcard.private.home"
sudo docker exec -ti docker-container-4-name sh -c "ping -c 4 docker-container-3-name"
sudo docker exec -ti docker-container-4-name sh -c "ping -c 4 docker-container-1.docker.devnet"
#
sudo docker exec -ti docker-container-1-name sh -c "ping -c 4 docker-container-4.docker.devnet"
```

* test browser access to the container
    * http://localhost:8084/hostname.html
    * http://docker-container-4.docker.devnet/hostname.html


## That's It!!
