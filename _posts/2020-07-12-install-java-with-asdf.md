---
title: "Install Java with asdf"
date: "2020-07-12 12:30:00 +1000"
last_modified_at: 2021-05-27 14:36:00 +1000
tags: java asdf
header:
  image: /assets/images/2021-05-18/east_java_1440_450.jpg
  image_description: "Baluran National Park, East Java"
  teaser: /assets/images/2021-05-18/east_java_1440_450.jpg
  overlay_image: /assets/images/2021-05-18/east_java_1440_450.jpg
  overlay_filter: 0.3
  caption: >
    Image by [Hanandito Adi](https://unsplash.com/@hndi?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/photos/2j3nEOWjEwA)
excerpt: >
  Getting Java installed on macOS or Linux can be painless if you have chosen
  the right tool
---

For some reason, I needed to install Java on my work laptop, which is a Macbook
Pro. I could use Homebrew, but it would only allow me to have one version of
Java, or two if you count Java11. If I ever need to run different versions of
Java for different projects, it would be very cumbersome to manage, if not
downright impossible. For that reason, I generally use a tool called asdf to
manage the installations of programming languages.

If you don't already have it and want to give it a go, the [asdf installation
instructions][] for macOS and Linux on their website should be handy. Once you
have asdf, installing a version of Java, or most popular programming languages,
should be reasonably painless.

### Add the plugin

First add the plugin for Java:

```bash
asdf plugin-add java
```

### List available versions

This could be helpful when you are not sure which versions are available and you
can do that by:

```bash
asdf list-all java
```

If you, like me, haven't followed the development of Java over the past decade,
you might be surprised by the number of options for Java with asdf. Among them,
OpenJDK is Oracle's open source implementation of Java Standard Edition.
According to [this StackOverflow Answer][], Oracle stopped offering downloads of
Java 8/9/10, which is why there is the AdoptOpenJDK project. Since I'm not
exactly an expert on Java, if you'd like to know more, my friend, Google is a
good starting point.

### Install a version

Once you pick which version you want, install it with:

```bash
asdf install java openjdk-14.0.1
```

In the example above, I wanted the latest version of OpenJDK, which is `14.0.1`
as of July 2020.

### Select a global version

After installing the first version, you might also want to select it as the
global version for that language by:

```bash
asdf global java openjdk-14.0.1
```

### Set JAVA_HOME

To set `JAVA_HOME` environment variable for Zsh initialisation, add the
following:

```bash
. ~/.asdf/plugins/java/set-java-home.zsh
```

Refer to [asdf-java documentation][] for Bash or Fish shells.

### Summary

Hopefully this short introduction to installing Java with asdf could be helpful
to someone else too. I use asdf to manage all my programming language
installations (literally one tool to rule them all!) and I love it.

### Update (May 2021)

If you like this short introduction to asdf, I've recently published a more
complete guide to asdf [How to Use asdf Version Manager on macOS][], which you
might also find interesting.

[How to Use asdf Version Manager on macOS]: /blog/how-to-use-asdf-on-macos/
[asdf installation instructions]: https://asdf-vm.com/#/core-manage-asdf-vm
[asdf-java documentation]: https://github.com/halcyon/asdf-java#java_home
[this StackOverflow Answer]: https://stackoverflow.com/a/32811065/1228752
