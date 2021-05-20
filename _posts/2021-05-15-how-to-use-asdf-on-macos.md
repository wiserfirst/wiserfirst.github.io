---
title: "How to Use asdf Version Manager on macOS"
date: "2021-05-15 19:35:00 +1000"
last_modified_at: 2021-05-17 21:23:00 +1000
tags: asdf version-manager macos ruby nodejs python
header:
  image: /assets/images/2021-05-15/coding_1440_400.jpg
  image_description: "Coding in Node.js"
  teaser: /assets/images/2021-05-15/coding_1440_400.jpg
  overlay_image: /assets/images/2021-05-15/coding_1440_400.jpg
  overlay_filter: 0.2
  caption: >
    Image by [Reza Namdari](https://unsplash.com/@rezanamdari?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/s/photos/programming?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
excerpt: Discover a fantastic version manager for programming languages
---

Last year, I wrote a post titled [Install Java with asdf][] and slightly
surprising to me, it ended up becoming the most visited article on my personal
blog. Given that, I decided to write another more complete guide to asdf. Even
though this guide is meant for macOS, most things covered here should apply to
Linux systems too, potentially with some minor tweaks.

## Why asdf

Before we begin, let's talk about why we might need it in the first place.

Say you work as a developer for a company and their tech stack is backend Ruby
on Rails and frontend React. There are quite a number of repositories for
different services and unsurprisingly not all of them use the same versions of
Ruby or Node.js.

To manage the different versions of Ruby, [rbenv][] is a good tool and for
Node.js, you have [nvm][]. Then Python is introduced for some machine learning
related tasks, so here comes [pyenv][].

Three tools to manage versions for three programming languages doesn't sound too
bad, but they all have slightly different command syntax for you to remember and
use from time to time. The situation only gets worse with more languages
introduced to the mix. For example, what if you want to build a side project
with Elixir/Phoenix or learn some Rust.

One version manager for each programming language is still okay for three
languages, but once the number reaches five or six, it becomes too much effort.

### asdf to the rescue

Luckily there is asdf and you can replace `rbenv`, `nvm`, `pyenv` and more with
just this one tool.

Thanks to its plugin system, asdf is extendable enough for you to install and
manage versions of almost all programming languages that you might want to use.
And with asdf you only need to learn one set of simple commands to do that.

Furthermore, if you'd like to manage something and there isn't yet a plugin for
it, it's possible to [create a plugin][] yourself.

With a relatively small core and the powerful plugin system, asdf offers nearly
infinite possibilities.

## Install asdf

First make sure that `coreutils`, `curl` and `git` are installed:

```sh
brew install coreutils curl git
```

### Install with Git

Personally I prefer installing asdf with Git, because it gives complete control
and avoids some pitfalls.

Cloning the latest tag is enough:

```sh
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
```

`v0.8.0` is the latest tag as of May 2021, but obviously that would change
over time, so make sure to check its [Github repository][] for that before you
install.

Then for Zsh add the following to the bottom of `~/.zshrc`:

```sh
. $HOME/.asdf/asdf.sh
```

Open a new terminal tab and you should be ready to use asdf :tada:

### Install with Homebrew

The alternative is to install asdf with Homebrew:

```sh
brew install asdf
```

If you prefer this method, before continuing, do check out [Common Homebrew
issues][] to be aware of potential issues you might run into.

And add the following line to the bottom of your `~/.zshrc`:

```sh
. $(brew --prefix asdf)/asdf.sh
```

> If you use Bash or Fish shell, please refer to the [Add to your Shell][]
> section in asdf documentation for instructions.

## Manage Plugins

Before you could install Ruby, Node.js or anything else, you'll need to add the
appropriate plugins. Plugins are how asdf understands handling of different
programming languages or, say, packages.

There is an [asdf plugins repository][] and for all the plugins listed there,
you can add with just the plugin name. For example, here is how to add the
plugins for Ruby and Node.js:

```sh
asdf plugin add ruby
asdf plugin add nodejs
```

If the plugin you want is not part of this repository, you can still add it with
its repository URL. For example:

```sh
asdf plugin-add elm https://github.com/vic/asdf-elm
```

You can list installed plugins with:

```sh
asdf plugin list
```

Or list all available plugins from the asdf plugin repository:

```sh
asdf plugin list-all
```

## Manage Language Versions

If you've looked through the asdf plugin repository, you may have noticed that
there are plugins not only for programming languages, but also for many other
cli tools like `fzf`, `minikube` etc.

For the purpose of our discussion here, whether it's a programming language or
something else doesn't really matter, because the commands for managing them are
going to be the same. I'll just refer to them as programming languages in this
post, but please keep in mind that you could use asdf to manage other cli tools
as well.

### Install Versions

Suppose we want to install the latest stable release of Ruby 2 and the latest
LTS release of Node.js, which are `2.7.2` and `14.16.1` respectively as of this
writing. We can simply run the following:

```sh
asdf install ruby 2.7.2
asdf install nodejs 14.16.1
```

> When you run into issues trying to install a particular language version, make
> sure to check out the Github repository for the plugin. It's very likely that
> you'll find instructions on how to solve those issues.

### Set Global Versions

After installing the first versions, you might also want to set them as global
versions for Ruby and Node.js:

```sh
asdf global ruby 2.7.2
asdf global nodejs 14.16.1
```

With this, we've made Ruby `2.7.2` and Node.js `14.16.1` "globally" available
for the current user.

In asdf terms, "global" means default everywhere. So unless it's overridden with
either a local or shell version, which are covered in the following sections,
asdf will assume the global version is the one to use.

### Set Local Versions (Optional)

Suppose we have a legacy project that we need to maintain and it only runs on
Node.js 10. What we can do with asdf is to install Node.js 10 and set a local
version in the project directory:

```sh
asdf install nodejs 10.22.0
# run in the project directory
asdf local nodejs 10.22.0
```

With this local version set, when you are in the legacy project directory or its
subdirectories, asdf will automatically switch to Node.js version `10.22`; when
you are in any other directories, it'll fallback to the global Node.js version,
unless of course if there is another local Node.js version set.

### Set Shell Version (Optional)

I had a fairly interesting situation at work recently. On this project, the
backend server and frontend client each lives in a subdirectory in the same
repository and we are in the process of developing a new client app to replace
the old one.

Normally I just run the server and new client, both of which run on Node.js 14.
This time I needed to run the old client to confirm some behaviours on a page,
but it requires Node.js 10.

In order to run the old client together with the server, I made another copy of
the whole project, set a local Node.js version to `10.22.0` in the new directory
and run the old client. For the server, since the local Node.js version is
already set to `14.16.1` in the original project directory, I could still start
it in as normal.

That certainly worked fine for me. But later I learned that there is a much
simpler way: to use an asdf shell version. Without making an extra copy of the
project, I could simply start a new shell session in the project directory and
set a shell version for Node.js by:

```sh
cd path/to/project
asdf shell nodejs 10.22.0
# run old client
```

This shell version only affects the current shell session, nothing else.

As for the server, just run it in another shell session would do.

### Quick Recap

So basically asdf allows you to select different versions of programming
languages on a per directory basis, and on top of that you have the option to
set a shell version which only affects the current shell session.

I think that should be flexible enough for anyone to cope with most of (if not
all) the situations they'll ever encounter.

## Under the Hood

<div style="margin: auto; text-align: center; width: 100%;">
  <figure style="display: block">
    <img src="/assets/images/2021-05-15/underhood_1024_540.jpg"
         alt="Mustang car with open hood" />
    <figcaption style="text-align: center;">
      Blue Mustang Coupe with Hood Open by
      <a href="https://unsplash.com/@aliivan">Alison Ivansek</a>
      from <a href="https://unsplash.com/photos/HAI-GVIEvSQ">Unsplash</a>
    </figcaption>
  </figure>
</div>

To someone who's new that might sound like magic, but in fact how asdf works is
actually quite straightforward.

### Global Versions

When you set a global version for a programming language, it'll add or update a
line for the language in a `.tool-versions` file under the current user's home
directory. If the file doesn't already exist, it'll create it first and then add
the new line.

If you've followed this post to install asdf, install Ruby and Node.js, and then
set the global versions, your `.tool-versions` file in home directory should
look like the following:

```sh
# cat ~/.tool-versions
nodejs 14.16.1
ruby 2.7.2
```

### Local Versions

When you set a local version in a directory, asdf will add or update a line for
the language in a `.tool-versions` file under that directory. Same as the global
`.tool-versions` file, it'll be created if not exist already.

Say you do have that legacy project where Node.js `10.22` is required and
therefore you've set a local version for Node.js in the project directory. The
`.tool-versions` file under the project directory should look like this:

```sh
# cd path/to/project
# cat ~/.tool-versions
nodejs 10.22.0
```

If you're working on a personal project or your team has adopted asdf, it would
be a very good idea to commit the `.tool-version` file to Git or the version
control system you use.

On the other hand, if your team hasn't reached an agreement on adopting asdf,
I'd recommend adding it to `.gitignore` and keeping it locally without
committing to version control. The [Migrate from Legacy Tools][] section might
offer more useful information, if you found yourself in situations like this.

### Shell Versions

How shell versions work is even simpler in my opinion. When you set one, asdf
will set an environment variable `ASDF_${LANG}_VERSION` for the current session.

For example, when I set a shell version for Node.js to `10.22.0`, asdf creates an
environment variable named `ASDF_NODEJS_VERSION` with value `10.22.0` in my
shell session.

Given that's how it works, setting the environment variable for a particular
language directly in a shell session or even for just one command would work
too.

The following example starts the Rails server with Ruby version `2.5.3`:

```sh
ASDF_RUBY_VERSION=2.5.3 bundle exec rails server
```

### Current Versions

When you run `node` for example, asdf will look for a `.tool-versions` file in
the current directory, then the parent directory, then parent's parent directory
etc. If it does find one and a local Node.js version is specified, it'll use
that version. In the case it couldn't find one, it'll fallback to the global
version set in the `.tool-versions` file under the current user's home
directory. So the logic is quite straightforward.

You could run `asdf current` to get a list of current versions of installed
programming languages in the current directory. For example, say we are in the
legacy project directory, where a local Node.js version is set, but no Ruby
version is set. What you get should be something like this:

```sh
# asdf current
nodejs          10.22.0         /Users/username/workspace/legacy-project/.tool-versions
ruby            2.7.2           /Users/username/.tool-versions
```

Whereas if you run it in another directory, assuming no local versions are set,
what you get is slightly different:

```sh
# asdf current
nodejs          14.16.1         /Users/username/.tool-versions
ruby            2.7.2           /Users/username/.tool-versions
```

As you can see, in the output, it not only tells you what the current versions
are, but also shows from which `.tool-versions` file asdf got each version.

I reckon this command could come in handy when you try to figure out where a
particular local version is set.

## Use asdf in a Team

Coming back to the scenario mentioned at the beginning of this article, where
you work for a company which uses Ruby on Rails for backend and React for
frontend and different projects might have different language version
requirements.

After introducing asdf you no longer have to deal with different tools for
managing versions of different programming languages, which is great. But
obviously when starting to work on a different project for the first time,
everyone still need to get the correct local versions installed.

What I used to do is to check out what are the versions specified in the
`.tool-versions` file of the project and then manually install them. For
example, if the file has

```sh
nodejs 10.22.0
ruby 2.5.3
```

Running the following should do it:

```sh
asdf install nodejs 10.22.0
asdf install ruby 2.5.3
```

But this feels slightly tedious and it is.

Luckily as it turns out there is a much better way: running `asdf install`
without any arguments. If a required version is not installed yet, asdf will go
ahead and install it; if a version is already installed, it will tell you that
and does nothing.

I think this is a rather neat trick for installing the specified local versions
for a project, therefore it makes this aspect of onboarding new team members to
a project pretty much painless.

## Migrate from Legacy Tools

If you are sold on asdf but for whatever reason can't adopt it at work, there is
a configuration option that could allow you to still use it.

What you need to do is to create a `.asdfrc` file in your home directory with
the following content:

```sh
legacy_version_file = yes
```

Setting this to `yes` will cause asdf plugins to read "legacy" version files,
for example `.ruby-versions` for Ruby and `.nvmrc` or `.node-versions` for
Node.js.

This is especially helpful when you are in a team where your teammates don't
want to change to a different tool for managing the programming languages.
Change is hard even when there are obviously benefits, so expect resistance if
people are not already familiar with asdf.

With this setting though, they can continue to use the legacy tools they prefer,
but you would have the option to use asdf if you want.

> Note: not all plugins support this feature. If you rely on this behaviour,
> please do check the documentation of the plugins you use.

Hopefully one day they'll start noticing conveniences of asdf and change their
minds, at which point the whole team could fully adopt asdf and enjoy the
benefits it brings.

## Summary

In this post, I covered:

* how to install asdf
* how to add plugins
* how to manage versions
* how versions work under the hood
* how asdf fits in a team setting
* how to use asdf with legacy tools

While there are definitely aspects of asdf that I didn't cover, this should be a
solid starting point for someone new. After reading this post and following
along, you should be able to start using asdf with confidence. If you do run
into issues, check out [asdf documentation][] and Google is your friend.

With asdf, one could manage different versions of all the programming languages
that they might need without any trouble, and also it makes sharing a common set
of programming language versions across a team for a project very easy.

Because of the conveniences it offers, I'm a big fan of asdf and I truly believe
that every developer should use it or at least know it as a potential option to
consider.

[Add to your Shell]: https://asdf-vm.com/#/core-manage-asdf?id=add-to-your-shell
[Common Homebrew issues]: https://github.com/asdf-vm/asdf/issues/785
[Github repository]: https://github.com/asdf-vm/asdf/tags
[Install Java with asdf]: /blog/install-java-with-asdf/
[Migrate from Legacy Tools]: /blog/how-to-use-asdf-on-macos/#migrate-from-legacy-tools
[asdf documentation]: https://asdf-vm.com/#/core-manage-asdf
[asdf plugins repository]: https://asdf-vm.com/#/plugins-all
[create a plugin]: https://asdf-vm.com/#/plugins-create
[nvm]: https://github.com/nvm-sh/nvm
[pyenv]: https://github.com/pyenv/pyenv
[rbenv]: https://github.com/rbenv/rbenv
