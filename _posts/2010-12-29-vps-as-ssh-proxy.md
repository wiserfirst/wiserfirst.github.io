---
title: "使用VPS做SSH代理"
date: "2010-12-29 10:00:00 +0800"
last_modified_at: 2021-09-28 12:45:00 +1000
tags: Chinese vps ssh proxy
header:
  image: /assets/images/2021-05-21/nasa_earch_1280_400.jpg
  image_description: "Earth from Space"
  teaser: /assets/images/2021-05-21/nasa_earch_1280_400.jpg
  overlay_image: /assets/images/2021-05-21/nasa_earch_1280_400.jpg
  overlay_filter: 0.1
  caption: >
    Image by [NASA](https://unsplash.com/@nasa)
    from [Unsplash](https://unsplash.com/photos/Q1p7bh3SHj8)
excerpt: Create a personal proxy service on a VPS
---

首先登录到VPS并切换到root帐号（也可以使用sudo命令），然后使用如下命令建立新帐户，专门用于SSH代理：

```bash
useradd -M -s /sbin/nologin -n username
```

然后为该用户设置密码:

```bash
passwd username
```

接着根据提示输入两遍这个用户的密码即可。（参考了这篇文章《[在VPS上建立最低权限的SSH帐号用于代理服务][ssh
proxy on vps]》）若要删除这个用户，运行如下命令:

```bash
userdel username
```

为了保证用户名和密码的安全性，我使用了一个国外网站上的在线工具生成随机字符串作为用户名和密码，~~地址在这里~~(2021-04-02注：此工具网站已下线)。可以指定包含字符的类别和串的长度，个人认为挺好用的，回头有时间自己写一个。

密码设好以后，Server配置就完成了，接下来做Client配置。在Windows下可以使用Bitvise
Tunnelier(2020-07-27注：已更名为Bitvise SSH Client)，点[这里下载][bitvise
download]，~~其配置实用参考了这篇文章~~(2021-09-28注：文章链接已失效)。

下载安装Tunnelier软件后，首先在Login页面中输入VPS地址及其SSH端口，以及刚刚设置的用户名和密码。在Options页面的On
Login下取消选中Open Terminal和Open
SFTP，这样使用这个帐户登录时就不会自动打开Terminal和SFTP窗口。其实这里即使不取消也是登录不上去的，因为这个帐户权限不够。最后在Service页面选中SOCKS/HTTP
Proxy Forwarding下面的Enable，并在Listen
Port中设置一个你想使用的端口号，如`4567`。这样本地代理的配置就完成了。

想要通过这个代理上网只需要在浏览器中，设置代理地址为`127.0.0.1:4567`即可。当然如果你使用Firefox并且安装了Autoproxy插件，还可以根据网址无缝切换翻墙与否，十分方便。只需在Autoproxy插件的配置中将`SSH
-D`方式后面的端口号改为`4567`，并选择使用`SSH -D`即可。关于详细的设置请自行Google之。

[ssh proxy on vps]: http://www.zhukun.net/archives/4504
[bitvise download]: https://dl.bitvise.com/BvSshClient-Inst.exe
