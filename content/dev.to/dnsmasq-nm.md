---
title: "Dnsmasq + NetworkManager + Private Network Setup"
public_article: true
description: "Dnsmasq + NetworkManager + Private Network Setup"
categories: [dev.to,network, ecosystem]
tags: [dnsmasq,network-manager,network,ecosystem]
canonical_url: https://github.com/karlredman/Articles/blob/master/content/dev.to/dnsmasq-nm.md
published_url: https://dev.to/karlredman/dnsmasq--networkmanager--private-network-setup-258l
published: true

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"
date: "2019-03-01T07:30:30-05:00"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"
lastmod: "2019-06-11T07:30:30-05:00"

slug: null

hide: false
alwaysopen: false

toc: true
type: "page"
#theme: "league"
hasMath: false

weight: 5
---

This is a howto/method for minimal configuration which provides a local private network that will be available to the local host for both online and offline (internet/DHCP) connectivity. The goal is to provide a scalable and network switchable development environment for virtual machines and bare metal application systems. This method intends to provide the developer the ability to roam (via laptop, et al) and maintain a consistent network development environment. Note that this configuration will require that you become accustomed to using `NetworkManager`.

* A TL;DR version of this article can be found [here](https://github.com/karlredman/Articles/blob/master/content/dev.to/tldr-dnsmasq-nm.md).

## Features of this howto:

* Reference Docker containers by name between containers.
* Reference the host (private network) with wildcards from both the host and containers.
* Work/develop offline or online (almost) seamlessly.
* Reference internet hosts from docker containers (if connected -most likely DHCP).
* Reference local host network hosts (if connected -most likely DHCP and there is a DNS running).
* No extra configuration with `/etc/hosts`
* Ability to implement (your extended configurations):
    * DNS caching.
    * DHCP on a private network local to the host.
    * shared networking via NetworkManager from a host interface.
    * various VMs on the private network with full local DNS support.

## Caveats / Limitations

* Your bare metal services will need to be configured for the private network (i.e. 10.127.127.1) in order to utilize 'docker container to host' DNS resolution.
* This procedure *does not* provide a method to resolve container hostnames from the host.
* This procedure *does not* provide a method to resolve container hostnames from the from containers (see below for an explanation).
    * containers can, however, use Docker's internal DNS to resolve containers by container names.

## Tested systems:

* MX Linux v18.1
* Ubuntu v18.10
* Debian v9.8

## Disclaimer:

I **strongly urge** that you initially test this procedure with a virtual machine. I find Virtualbox to be the easiest sandbox installation platform for desktop systems but your mileage may vary. Either way, use a spare bare metal system or a virtual machine for testing this method to see if it works for you and your environment. I am not responsible if you mess up your system, data, etc.. This information is provided as is -use at your own risk.

Also, I tend to write wordy howto's with extra information that you may not care about -as evidenced by this sentence. I'll try to keep that to a minimum here. ;)

## Introduction:

TL;DR: Skip this part -it's a motivation statement...

Developing network-able services across the myriad virtual machine/container options (Docker, kubernetes, singularity, libvert, singularity, LXC, etc.) is challenging. An additional challenge is trying to develop these kinds of services while, as a developer, roaming between networks. For me the answer is to emulate the various network environments as closely as possible. One step toward this endeavor is to establish a basic platform whereby a single system (i.e. laptop) can roam between different network environments and maintain a consistent production-like network simulation -whether online, offline, at work, at a party, at your friends house, in a mall, on the road, or at home (etc.).

There are **a lot** of 'moving parts' when developing any software application. That number of moving parts increases by orders of magnitude for every system resource (i.e. basic network connectivity compounds any application -add any concept of scalability and the complexity of the application dramatically increases). My attempt here is to provide a minimalist configuration whereby the reader doesn't have to understand how everything works *right now*. Rather, as needs for various development environments and tools become relevant, this basic network structure (hopefully) should provide a general baseline for adding emulation capabilities for future development capabilities. In the end, this howto is really simple -yet the ability to develop in a private network with a roaming system (i.e. laptop) eludes many, many developers. The moving parts to building a proper development environment become very confusing and very frustrating to many of us. It's overwhelming and thus, we hack...

I came up with this solution so that I could develop across the many virtual machine/container options on a single machine (laptop) regardless of the environment/location and the network I'm working in. With a simple configuration of NetworkManager IP addressing + system level dnsmasq I can now create any service for any IP (on the private network) and ultimately proxypass it (with whatever proxypass tool) to my host network domain -allowing me to both provide shared services across networks and/or develop any number of combined virtual systems on an isolated system; all on a single system (laptop).

Hopefully this method is a step toward providing the basis of an environment which is helpful for isolated and corporate and cloud development alike.


## Configure NetworkManager

Presumably a fresh installation of various linux flavors will configure NetworkManager at installation time. The following information assumes that you have installed linux, are able to connect to the internet via DHCP, and do not have other issues pending with your network.

### Add private network ip to network manager

This section implements a static ip address for the local host to use with future networks and services. All future networks on the system will use this base network -base address as configured here. To leverage this network for virtual systems you will need to identify your vitual interfaces to use this network -or otherwise configure a bridge (beyond the scope of this article).

* reference [network manager - How to Add dnsmasq and keep systemd-resolved (18.04) - Ask Ubuntu](https://askubuntu.com/a/1041742)

* determine the connection to use (i.e. eth0, wlan0, etc.)
    * command

    ```sh
    nmcli connection show
    ```

    * example output

    ```text
    NAME                UUID                                  TYPE            DEVICE
    Wired connection 1	xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  802-3-ethernet  eth0
    br-0a159c4a8cf4     xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  bridge          br-0a159c4a8cf4
    br-b1bce84765b8     xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  bridge          br-b1bce84765b8
    docker0             xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  bridge          docker0
    ```


* add a `10` network address to our Network Manager connection

```sh
nmcli con mod 'Wired connection 1' ipv4.address 10.127.127.1/24
nmcli con mod 'Wired connection 1' connection.autoconnect yes
```

* Set the (auto) connection priority for the connection
    * This will force this connection to be attepted first followed by the offline (cloned) version configured below

```sh
nmcli connection modify 'Wired connection 1' connection.autoconnect-priority -998
```

* update connection (i.e. save the changes)

```sh
nmcli con up 'Wired connection 1'
```

* Note: do *not* add the new IP to your `/etc/hosts` file. A network/host name for this new address will be configured later through Dnsmasq.

### Clone connection and configure

NetworkManager will hang (seemingly) indefinitely when you connect to a network that does not provide DHCP connectivity. Cloning the working connection and making some adjustments will provide the ability to work 'offline' while maintaining the private netowrk with the system dnsmasq instance and it's (if configured) DHCP capabilities.

When a network does *not* offer DHCP capability you will use this connection to gain access to your local private network.

Note: switching between NetworkManager connections may require that you restart `dnsmasq`: `sudo service dnsmasq restart`. This issue occurs mostly when switching from a fully DHCP authenticated internet connection to one that is not (i.e. a connection that is not DHCP/internet enabled). In the reverse I've found, rarely, a need to run `sudo dhclient` when switching from an isolated network to one that is DHCP enabled. Additionally, I've had to reboot in various situations when switching from DHCP networks to non and visa versa -milage may very (sorry for the ambiguity -that's the state of networking...).

* Clone the connection

```sh
nmcli connection clone 'Wired connection 1' 'Wired connection 1 offline'
```

* Change cloned connection settings in favor of isolation

```sh
nmcli connection modify 'Wired connection 1 offline'  ipv4.method manual
```

## (Optional) Install resolvconf

* this is a workaround for Network Manager that allows for finer grained resolver configuration

```sh
sudo apt install resolvconf
```

## Install and configure Dnsmasq

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

## Configure dnsmasq

### Dnsmasq configuration `/etc/dnsmasq.conf`

```text
address=/private.home/10.127.127.1
listen-address=127.0.0.1
listen-address=10.127.127.1
bind-dynamic       # could use bind-interfaces instead
domain=private.home,10.127.127.0/24
domain=docker.devnet,172.17.0.0/24
```

### Restart Dnsmasq and inspect hosts file

* restart dnsmasq service

```sh
sudo service dnsmasq restart
```

## !!!! **REBOOT** !!!!!

This is a cringe worthy necessity. Just reboot, it's easy. Accept that the moving parts are more than you want to deal with and that it's really less time to just reboot. I, personally, hate this statement but ... this is the state of things -accept it or spend some time finding a universal way around the reboot and report back here :D

* your `/etc/resolv.conf` file will look similar to this:

```sh
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
nameserver 127.0.0.1
search your-isp.net
```

* your `/etc/hosts` file will look something like this

```text
127.0.0.1	localhost
127.0.0.1   this-laptop

# The following lines are desirable for IPv6 capable hosts
::1		localhost ip6-localhost ip6-loopback
fe00::0		ip6-localnet
ff00::0		ip6-mcastprefix
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters
```

## Test Dnsmasq

### After reboot:

* test local private network (should print as `10.127.127.1`)
```sh
ping -c 4 private.home
```

* test google DNS (from a DHCP connected network)
```sh
ping -c 4 google.com
```

* test host hostame
```sh
ping -c 4 [your hostname here]
```

* test another host on the network
```sh
ping -c 4 [a local network hosthame here]
```

## Things should be working so far...

If you don't have responses that seem correct at this point -if something seems broken -then either this method doesn't work for you on your OS or you skipped a step (or I goofed and the documentation is wrong).


If you can't ping `private.home` and/or `google.com` by name then something is wrong. Please do ping 8.8.8.8 (google name server) explicitly to see if you have network access and work backwards from there. ...

## Add Docker container DNS resolution

**Important**:

This section demonstrates docker container dynamic host name resolution for *container to container* and *container to host* resolution. Modern Docker container names can resolve across a bridge network -which we will create. Also, because we have established a private network, containers will be able to resolve a host's hostname back to our private 10.127.127.1 ip address (established earlier).

Note: resolving host to container hostnames is generally not required (or even considered a good idea) in production environments. The point of view is that virtual machines export ports to the host without regard for (or, more appropriately, in spite of) localhost. `localhost` in a container is not the host's localhost -i.e. the container's localhost is 127.0.0.1 within it's own namespace/address-space while the host's localhost is 127.0.0.1 relative to physical components of the host system. The container has it's own localhost **separate** from the host system.

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
* reference [Install Docker Compose](https://docs.docker.com/compose/install/)
    * [Releases · docker/compose](https://github.com/docker/compose/releases)

```sh
# be sure to get the latest version (that is compatible with docker -most likely latest...)
#
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Build an image for testing

This image is used for testing throughout this documentation where Docker is specified.

```sh
git clone https://github.com/karlredman/lighttpd-docker.git
#
cd lighttpd-docker
#
sudo docker build -t lighttpd .
```

### Create common docker network for containers

* This section creates a common network that all `docekr run` commands and `docker-compose` instances may communicate with one another -including the ability to resolve docker container names from within the respective container instances.

* Specify a `.` (dot) delimited network name for finicky applications that require a FQDN (fully qualified domain name).

* Note: use `-` in names instead of `_` when possible (if needed) to maintain compatibility with various tools.

```
sudo docker network create docker.devnet
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

### Testing host to Docker container DNS resolution

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

```conf
####### normal docker behavior with user-defined network 'docker.devnet'
#
# ping container 3 *container name* from container 2
sudo docker exec -ti docker-container-2-name sh -c "ping -c 4 docker-container-3-name"
#
# ping private network host wildcard from a container
## Note: if this part isn't working then you likely are being blocked by your own firewall
sudo docker exec -ti docker-container-1-name sh -c "ping -c 4 a-wildcard.private.home"
```


## That's it!

I hope this workes for you...

