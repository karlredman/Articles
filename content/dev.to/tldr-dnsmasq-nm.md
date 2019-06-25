---
title: "TL;DR Version: Dnsmasq + NetworkManager + Private Network Setup"
public_article: true
description: ""
categories: [ecosystem,development,network]
tags: [network,dnsmasq,network-manager,ecosystem]
canonical_url: https://github.com/karlredman/My-Articles/wiki/

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-03-01T07:40:00-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-06-23T07:40:00-05:00"

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

# TL;DR Version: Dnsmasq + NetworkManager + Private Network Setup"

* original article: [on dev.to](https://dev.to/karlredman/dnsmasq--networkmanager--private-network-setup-258l)

## Tested systems:

* MX Linux v18.1
* Ubuntu v18.10
* Debian v9.8

## Disclaimer:

I **strongly urge** that you initially test this procedure with a virtual machine.

## Configure NetworkManager

### Add private network ip to network manager

* determine the connection to use (i.e. eth0, wlan0, etc.)

```sh
nmcli connection show
```

* add a `10` network address to our Network Manager connection

```sh
nmcli con mod 'Wired connection 1' ipv4.address 10.127.127.1/24
nmcli con mod 'Wired connection 1' connection.autoconnect yes
```

* Set the (auto) connection priority for the connection
    * This will force the connect to be attepted first followed by the offline (cloned) version configured below

```sh
nmcli connection modify 'Wired connection 1' connection.autoconnect-priority -998
```

* update connection (i.e. save the changes)

```sh
nmcli con up 'Wired connection 1'
```

* Clone the connection

```sh
nmcli connection clone 'Wired connection 1' 'Wired connection 1 offline'
```

* Change cloned connection settings in favor of isolation

```sh
nmcli c m 'Wired connection 1 offline'  ipv4.method manual
```

## (Optional) Install resolvconf

* this is a workaround for Network Manager that allows for finer grained resolver configuration

```sh
sudo apt install resolvconf
```

## Install and configure Dnsmask

* Install dnsmasq

```sh
# uninstall network manager version of dnsmasq
sudo apt remove dnsmasq-base -y

# install actual dnsmasq
sudo apt install dnsmasq -y
```

* enable dnsmasq service

```sh
sudo systemctl enable dnsmasq
```

### Dnsmasq configuration `/etc/dnsmasq.conf`

```txt
address=/private.home/10.127.127.1
listen-address=127.0.0.1
listen-address=10.127.127.1
bind-dynamic       # could use bind-interfaces instead
domain=private.home,10.127.127.0/24
domain=docker.devnet,172.17.0.0/24
```

## !!!! **REBOOT** !!!!!

## Test Dnsmasq

```sh
# test local private network (should print as `10.127.127.1`)
ping -c 4 private.home

# test google dns (from a dhcp connected network)
ping -c 4 google.com

# test host hostame
ping -c 4 [your hostname here]

# test another host on the network
ping -c 4 [a local network hosthame here]
```

### install docker

1. do an `sudo apt update`
2. download and install the `.deb` file manually (because mx linux doesn't natively support /etc/apt/sources.list)
    * reference: [get docker ce for debian | docker documentation](https://docs.docker.com/install/linux/docker-ce/debian/#install-from-a-package)
    * reference: [toplevel download path](https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/)
        1. [download and install docker-cli](https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce-cli_18.09.1~3-0~debian-stretch_amd64.deb)
        2. [download and install containerd.io](https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/containerd.io_1.2.2-1_amd64.deb)
           * the docker daemon will start automatically
        3. [download and install docker-ce](https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_18.09.1~3-0~debian-stretch_amd64.deb)
3. test docker

```sh
sudo docker run hello-world
```

### Install Docker Compose

```sh
# be sure to get the latest version (that is compatible with docker -most likely latest...)
#
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Build an image for testing

```sh
git clone https://github.com/karlredman/lighttpd-docker.git
#
cd lighttpd-docker
#
sudo docker build -t lighttpd .
```


### Create common docker network for containers

```sh
docker network create docker.devnet
```

### Add DNS to Docker daemon

* file /etc/docker/daemon.json

```json
{
	"dns": ["10.127.127.1", "8.8.8.8"]
}
```

* restart docker daemon

```sh
sudo service docker restart
```

### Testing Docker container to host DNS resolution

* Start test containers

```sh
# start FQDN hostname docker container 1
sudo docker run -d -p 8081:80 -p 4441:443 --rm -t --name docker-container-1-name -h docker-container-1.docker.devnet --net docker.devnet lighttpd

# start container 2
sudo docker run -d -p 8082:80 -p 4442:443 --rm -t --name docker-container-2-name -h docker-container-2 --net docker.devnet lighttpd

# start container 3
sudo docker run -d -p 8083:80 -p 4443:443 --rm -t --name docker-container-3-name -h docker-container-3 --net docker.devnet lighttpd
```

* Test DNS resolution

```sh
####### normal docker behavior with user-defined network 'docker.devnet'

# ping container 3 *container name* from container 2
sudo docker exec -ti docker-container-2-name sh -c "ping -c 4 docker-container-3-name"

# ping private network host wildcard from a container
## Note: if this part isn't working then you likely are being blocked by your own firewall
sudo docker exec -ti docker-container-1-name sh -c "ping -c 4 a-wildcard.private.home"
```

---

## Convenience sections:

### All combined dnsmasq tests

```sh
export A_NETWORK_HOST=[a local network hosthame here]
ping -c 4 private.home
ping -c 4 google.com
ping -c 4 $HOSTNAME
ping -c 4 $A_NETWORK_HOST
```

### All combined docker tests

* build testing image

```sh
git clone https://github.com/karlredman/lighttpd-docker.git
cd lighttpd-docker
docker build -t lighttpd .
```

* start test containers

```sh
sudo docker run -d -p 8081:80 -p 4441:443 --rm -t --name docker-container-1-name -h docker-container-1.docker.devnet --net docker.devnet -v /home/karl/Scratch/testconf/resolv.conf:/etc/resolv.conf lighttpd
sudo docker run -d -p 8082:80 -p 4442:443 --rm -t --name docker-container-2-name -h docker-container-2 --net docker.devnet -v /home/karl/Scratch/testconf/resolv.conf:/etc/resolv.conf lighttpd
sudo docker run -d -p 8083:80 -p 4443:443 --rm -t --name docker-container-3-name -h docker-container-3 --net docker.devnet -v /home/karl/Scratch/testconf/resolv.conf:/etc/resolv.conf lighttpd
```

* test containers

```sh
sudo docker exec -ti docker-container-2-name sh -c "ping -c 4 docker-container-3-name"
sudo docker exec -ti docker-container-1-name sh -c "ping -c 4 a-wildcard.private.home"
ping -c 4 a-wildcard.private.home
```

* stop containers

```sh
sudo docker container stop docker-container-1-name docker-container-2-name docker-container-3-name
```

