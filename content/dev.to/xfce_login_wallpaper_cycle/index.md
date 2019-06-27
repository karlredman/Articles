---
title: "Randomize your XFCE / LightDM Login Screen Wallpaper"
published: true
public_article: true
description: "HowTo: randomize LightDM / XFCE v4.x login screen wallpaper images."
categories: [dev.to,linux,admin,ricing]
tags: [lightdm,xfce,wallpaper,greeter]
canonical_url: https://github.com/karlredman/Articles/blob/master/content/dev.to/xfce_login_wallpaper_cycle/index.md
published_url: https://dev.to/karlredman/randomize-your-xfce-lightdm-login-screen-wallpaper-1ape
is_public: true

author: "Karl N. Redman"
creatordisplayname: "Karl N. Redman"
creatoremail: "karl.redman@gmail.com"

lastmodifierdisplayname: "Karl N. Redman"
lastmodifieremail: "karl.redman@gmail.com"

lastmod: 2019-06-24T23:57:02-05:00
date: 2019-06-24T23:57:02-05:00

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

weight: 5
---

HowTo: randomize LightDM / XFCE v4.x login screen wallpaper images.
<p>&nbsp;</p>
<p>&nbsp;</p>
For fans of the lightweight and highly configurable linux desktop environment [XFCE](https://xfce.org/), with it's default Greeter managed by [LightDM](https://wiki.ubuntu.com/LightDM), it's a frustrating fact of reality that there is no built in way to randomize the login screen image. This simple perl script and directory layout will provide that service using a cron job. The process will copy a random image file from a directory that contains a pool of images into a 'publish' directory; as `background.jpg`. XFCE then uses that image as the background for the login screen once configured.

## Overview:

The basic premise of this procedure will be:

1. populate some directory with images you want to use for login backgrounds.
2. setup a cron job to run a script to copy a random image from the source directory into a `publish` directory
3. XFCE will use that image as the login screen background image.

## TL;DR:

An example project for configuring randomized login screens for XFC can be found [here](https://github.com/karlredman/LoginWallpaper-XFCE-Variety)

## Single vs Multi User system and encrypted `home` directories:

* Single-user systems that do not use encrypted home directories you can use a directory within your home directory (i.e. `/home/karl/Repositories/LoginWallpaper-XFCE-Variety`).
* Multi-user systems that use a program like [variety](https://peterlevi.com/variety/) will need to use a user-group level directory location. (i.e. `/opt/LoginWallpaper-XFCE-Variety`)
* Single-user and Multi-user system that use encrypted home directories will need to use a user-group level directory location (i.e. `/opt/LoginWallpaper-XFCE-Variety`)

## Generic setup

Examples will assume a multi-user system with encrypted home directories.

### clone the example project to an appropriate directory:

```sh
# a global directory space
cd /opt
#
# clone the project
sudo git clone git@github.com:karlredman/LoginWallpaper-XFCE-Variety.git
#
# set permissions on the project directory
sudo chown -R root:users LoginWallpaper-XFCE-Variety
```

### add images to the image directory `Variety`

* Add whatever `jpg` images you deem worthy / safe to be on a login screen. For this example the images you add will go into `/opt/LoginWallpaper-XFCE-Variety/Variety/`.
* Do verify that your images belong to `users` group -change as necessary

### run the project script to seed the `publish` directory

(i.e. `/opt/LoginWallpaper-XFCE-Variety/Greeter/background.jpg`)

* seed the file

```sh
cp $(/opt/LoginWallpaper-XFCE-Variety/mbin/print_random_file.pl /opt/LoginWallpaper-XFCE-Variety/Variety) /opt/LoginWallpaper-XFCE-Variety/Greeter/background.jpg
```

* verify the file exists -troubleshoot...

```sh
ls /opt/LoginWallpaper-XFCE-Variety/background.jpb
```

### Configure LightDM Greeter via the GUI interface

* start the greeter config app using one of these methods:
  * via the GUI menu for `LightDM GTK Greeter settings`
    * name may vary based on linux desktop distribution
  * via command line

  ```sh
  sudo lightdm-gtk-greeter-settings
  ```

  [![ghtdm-gtk-greeter-settings.png](https://raw.githubusercontent.com/karlredman/Articles/master/content/dev.to/xfce_login_wallpaper_cycle/lightdm-gtk-greeter-settings.png)](https://raw.githubusercontent.com/karlredman/Articles/master/content/dev.to/xfce_login_wallpaper_cycle/lightdm-gtk-greeter-settings.png)

* Select `Background->Image`

* Set `Image` to `<path>/background.jpg`
  * i.e. `/opt/LoginWallpaper-XFCE-Variety/Greeter/background.jpg`
  * the name `background.jpg` is required

* Save the setting and exit the app

### test and debug

If you are having issues try to run the command manually.

### add cron job

* open cron in your default editor:

```sh
cron -e
```

* add the job (example)

```crontab
# change to wallpaper every 10 min
*/10 * * * * cp $(/opt/LoginWallpaper-XFCE-Variety/mbin/print_random_file.pl /opt/LoginWallpaper-XFCE-Variety/Variety) /opt/LoginWallpaper-XFCE-Variety/Greeter/background.jpg
```

## Using `Variety` as the image source:

[Variety](https://peterlevi.com/variety/) is a wallpaper background manager that is available for several linux distributions and is compatible with several desktop managers. One of the options `variety` offers is the ability to manage your login greeter image.

1. open variety preferences and navigate to `customize` tab
2. select `Login Screen Support` checkbox
3. specify the image directory (i.e. /opt/LoginWallpaper-XFCE-Variety/Variety)

[![variety.png](https://raw.githubusercontent.com/karlredman/Articles/master/content/dev.to/xfce_login_wallpaper_cycle/variety.png)](https://raw.githubusercontent.com/karlredman/Articles/master/content/dev.to/xfce_login_wallpaper_cycle/variety.png)
