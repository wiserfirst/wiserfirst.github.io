---
title: "Install Java with Asdf"
date: "2020-07-12"
tags: java asdf
---

For some reason, I needed to install Java on my work laptop, which is a Macbook
Pro. I could use Homebrew, but it would only allow me to have one version of
Java, or two if you count Java11. If I ever need to run different versions of
Java for different projects, it would be very cumbersome to manage, if not
downright impossible. For that reason, I generally use a tool called asdf to
manage the installations of programming languages.

If you don't already have it and want to give it a go, the [asdf installation
instructions](https://asdf-vm.com/#/core-manage-asdf-vm) for macOS and Linux on
their website should be handy. Once you have asdf, installing a version of Java,
or most popular programming languages, should be reasonably painless.

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
According to [this StackOverflow
Answer](https://stackoverflow.com/a/32811065/1228752), Oracle stopped offering
downloads of Java 8/9/10, which is why there is the AdoptOpenJDK project. Since
I'm not exactly an expert on Java, if you'd like to know more, my friend, Google
is a good starting point.

### Install a version

Once you pick which version you want, install it with:

```bash
asdf install java openjdk-14.0.1
```

In the example above, I wanted the latest version of OpenJDK, which is 14.0.1 as
of July 2020.

### Select a global version

After installing the first version, you might also want to select it as the
global version for that language by:

```bash
asdf global java openjdk-14.0.1
```

### Set JAVA_HOME

To set `JAVA_HOME` environment variable for zsh initialisation, add the
following:

```bash
. ~/.asdf/plugins/java/set-java-home.zsh
```

Refer to [asdf-java
documentation](https://github.com/halcyon/asdf-java#java_home) for bash or fish
shells.

### Summary

Hopefully this short introduction to installing Java with asdf could be helpful
to someone else too. I use asdf to manage all my programming language
installations (literally one tool to rule them all!) and I love it.
