---
title: "Install Latest Versions of Linux, Nginx, MySQL and PHP (LEMP) on Ubuntu 12.04"
date: "2015-07-27"
---

Installing the LEMP stack on Ubuntu is pretty simple, you can follow a step-by-step guide like [this one](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-12-04). But as of July 2015, the versions of Nginx and PHP are 1.1.19 and 5.3.10 respectively, both of which are pretty old. If you want the latest version of Nginx and PHP, there are a few extra steps to take.

First of all you need to install `python-software-properties` package, in order to add ppa later:

```bash
sudo apt-get -y install python-software-properties
```

Next add ppa for Nginx and install the latest version:

```bash
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:nginx/stable
sudo apt-get update
sudo apt-get install nginx
```

Then add ppa for PHP5.6 and install the latest version:

```bash
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:ondrej/php5-5.6
sudo apt-get update
sudo apt-get remove php-pear php5-fpm php5-cgi php5-cli php5-common php5-curl php5-dev php5-gd php5-mcrypt php5-mysql libssh2-php
sudo apt-get autoremove
sudo apt-get install php5-fpm php5-mysql php5-gd php5-mcrypt php5-curl php5-dev php-pear libssh2-1-dev libssh2-php php5-redis
```

Notice that you need to remove old php 5.3 related packages first before installing the new php packages for PHP 5.6, otherwise you might get into trouble like
> apt couldn't resolve dependencies
