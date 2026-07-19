---
title: "How to Use asdf Version Manager on macOS (2026 Update)"
date: "2026-07-19 23:30:00 +1000"
tags: asdf version-manager macos ruby nodejs golang
header:
  image: /assets/images/2026-07-19/engine_1440_400.jpg
  image_description: "Colorful engine of a classic car, with blue hoses and a red damper"
  teaser: /assets/images/2026-07-19/engine_1440_400.jpg
  overlay_image: /assets/images/2026-07-19/engine_1440_400.jpg
  overlay_filter: 0.7
  caption: >
    Image by [Julian Hochgesang](https://unsplash.com/@julianhochgesang)
    from [Unsplash](https://unsplash.com/photos/xayPzzDCA4c)
excerpt: A fresh guide to asdf after its ground-up rewrite in Go
---

Five years ago, I wrote [How to Use asdf Version Manager on macOS][], and it
went on to become one of the most popular posts on my tiny blog site. There is
just one problem: as years went by, many things changed in asdf, especially
after the full rewrite in Go. If you follow my old guide today, almost nothing
works. The rewrite removed most of the commands that guide was built around.
`asdf global` is gone. `asdf local` is gone. Even the way to install it has
changed.

So here is the 2026 updated guide for asdf: same tool, same philosophy, new
binary, new commands. Whether you are upgrading or starting fresh, this will
get you productive with asdf.

## Why asdf

Say you work as a developer for a company whose stack is Ruby on Rails on the
backend and React on the frontend. The backend is not one repository but
several, and they do not all run the same Ruby version; the frontend
repositories are in the same boat with Node.js.

To manage the different versions of Ruby you could use [rbenv][], for Node.js
there is [nvm][], and when Python enters the picture for some machine learning
tasks, along comes [pyenv][]. Three tools with three slightly different command
syntaxes is already a burden, and it only gets worse when you want to build a
side project with Elixir or learn some Rust.

asdf replaces all of them. Thanks to its plugin system, one tool with one set of
commands can install and manage versions of almost any programming language,
along with plenty of other CLI tools. And if a language or tool does not have a
plugin yet, you can [create one][create a plugin] yourself.

## What Changed in the Go Rewrite

In early 2025, asdf was rewritten from the ground up in Go and shipped as
version 0.16.0. Until then, asdf was implemented in shell scripts, and the
`asdf` command you ran was actually a shell function sourced into your session.
It is now a single compiled binary.

I will admit the rewrite did not win me over right away. The changes felt
dramatic: suddenly everything was new in a tool I knew inside out. The way the
upgrade was pushed did not help either. After 0.16.0 came out, my still-working
installation started printing a long red warning on every single asdf command,
telling me to migrate. Since every tool installed through asdf runs through
asdf, that wall of red text greeted every `ruby` and `node` invocation too, even
though, by the notice's own admission, the old version "works as it did in asdf
version 0.15.0 and older". Nothing was broken; I was just being nagged.

Having lived with the new asdf for a while, though, I have come around.
Everything feels snappier, though speed was never my complaint after years of
daily use. What won me over were the quieter wins from the switch to a real
binary: you now install and upgrade asdf through your package manager like any
other tool, and there is nothing to source into your shell config.

A rewrite of the internals alone would not warrant a new guide. The breaking
changes do:

* `asdf global` and `asdf local` are gone, replaced by a single `asdf set`
  command with flags for the different scopes.
* `asdf shell` is gone. A binary cannot modify the environment of your running
  shell, so per-session overrides are now done with plain environment variables.
* Hyphenated commands lost their hyphens: `asdf plugin-add` became
  `asdf plugin add`, and `asdf list-all` became `asdf list all`.
* `asdf update` is gone. You upgrade asdf itself through your package manager
  instead.
* The shell setup changed. Instead of sourcing `asdf.sh` in your shell config,
  you put the shims directory on your `PATH`.

Do not worry if some of these terms mean nothing to you yet: they are all
covered below. The latest release as of this writing is `v0.20.0`, which is the
version this guide uses.

## Install asdf

The simplest way to install asdf on macOS is with Homebrew:

```sh
brew install asdf
```

Then add the asdf shims directory to your `PATH` (shims are explained in [Under
the Hood](#under-the-hood) below). For Zsh, add the following to the bottom of
`~/.zshrc`:

```sh
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

Open a new terminal tab and you should be ready to use asdf :tada:

In the previous version of this guide, I recommended installing asdf by cloning
its Git repository and sourcing `asdf.sh` from your shell config. Neither
applies anymore: asdf is a compiled binary now, so there is nothing to source.
If you are upgrading from a pre-0.16 installation, remove the old
`. $HOME/.asdf/asdf.sh` line from your `~/.zshrc` when you add the `PATH` line
above.

Homebrew is not the only option. You can also download a prebuilt binary from
the [asdf releases][] page and put it somewhere on your `PATH`, or install it
with `go install` if you already have Go set up. If you use Bash, Fish or
another shell, refer to the [Getting Started][] guide for the matching setup
instructions.

## Manage Plugins

Before you can install Ruby, Node.js or anything else, you need to add the
appropriate plugins. Plugins are how asdf knows how to handle each language or
tool:

```sh
asdf plugin add ruby
asdf plugin add nodejs
```

For plugins listed in the [asdf plugins repository][], the short name above is
all you need. A plugin that is not listed there can still be added by passing
its Git URL, shown here with the Node.js plugin standing in as an example:

```sh
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

In practice you will rarely need this: the plugins repository covers hundreds
of tools.

You can list the plugins you have installed:

```sh
asdf plugin list
```

Or list all the plugins available in the plugins repository:

```sh
asdf plugin list all
```

Plugins are also where new version definitions come from. If a freshly
released version does not show up in `asdf list all`, update your plugins
first:

```sh
asdf plugin update --all
```

## Manage Language Versions

### Install Versions

Suppose we want the current stable Ruby and the current LTS release of Node.js,
which are `4.0.6` and `24.18.0` respectively as of this writing:

```sh
asdf install ruby 4.0.6
asdf install nodejs 24.18.0
```

You can browse the available versions first:

```sh
asdf list all ruby
```

Or skip looking up version numbers entirely:

```sh
asdf install nodejs latest
```

To see which versions you already have installed, and to remove one you no
longer need:

```sh
asdf list ruby
asdf uninstall ruby 3.3.6
```

> If a version fails to install, check the GitHub repository of the
> plugin: known issues and their fixes are usually documented there.

### Set Versions

This is the biggest change from the old command set. Where you previously chose
between `asdf global` and `asdf local`, there is now a single command:

```sh
asdf set nodejs 24.18.0
```

By default, `asdf set` writes to a `.tool-versions` file in the current
directory, which is exactly what `asdf local` used to do. Run it in a project
directory and that project is pinned to Node.js `24.18.0`, regardless of what
other projects use.

To set a user-wide default version, the equivalent of the old `asdf global`,
pass the `-u` flag (for the home directory):

```sh
asdf set -u nodejs 24.18.0
asdf set -u ruby 4.0.6
```

The asdf team dropped the "global" terminology on purpose: it was never truly
global, just a fallback in your home directory that any project could override.
The new naming makes that explicit, and to me this is one place where the
rewrite improved not just the implementation but the logic.

There is also a `-p` flag, which updates the nearest existing `.tool-versions`
file in a parent directory. This is handy in a monorepo, where you might run the
command deep inside a subdirectory but want to update the version pinned at the
repository root.

Finally, if you want a tool to fall back to whatever macOS or Homebrew provides,
you can set its version to `system`:

```sh
asdf set ruby system
```

### Session Overrides

The old guide had a section on `asdf shell`, which set a version for just the
current shell session. That command is gone, but the underlying mechanism
survives: asdf still honours an environment variable named
`ASDF_${TOOL}_VERSION`, and it takes precedence over any `.tool-versions` file.

Say a legacy client app in your project only runs on an older Node.js. Instead
of touching any files, you can override the version for one shell session:

```sh
export ASDF_NODEJS_VERSION=20.19.0
```

Or for a single command:

```sh
ASDF_NODEJS_VERSION=20.19.0 npm start
```

Other sessions are unaffected, and closing the terminal cleans up after you.

### Quick Recap

asdf lets you pin versions per directory through `.tool-versions` files, set
user-wide defaults with `asdf set -u`, and override everything per session or
per command with an environment variable. That should be flexible enough for
most situations you will ever encounter.

## Under the Hood

If you are new to asdf, this might sound like magic, but how asdf works is
actually quite straightforward, and the Go rewrite made it easier to explain.

### Shims

The `PATH` entry you added during installation points at a directory of shims. A
shim is a tiny executable that sits in front of the real one: when you run
`node`, you are actually running the `node` shim, which asks asdf to resolve the
right Node.js version and then executes that version's real `node` binary. This
is why there is nothing to source in your shell config anymore, and why any
program, not just your interactive shell, picks up the correct versions.

One maintenance command worth knowing here is `asdf reshim`. Shims are generated
when a version is installed, so when a package you add later ships its own
executable, think `gem install rubocop` or a global npm package, the shell may
not find the new command. Regenerate the shims for that plugin and you are back
in business:

```sh
asdf reshim ruby
```

### Version Resolution

When a shim resolves a version, asdf checks the following, in order:

1. The `ASDF_${TOOL}_VERSION` environment variable.
2. A `.tool-versions` file in the current directory, then the parent directory,
   then the parent's parent, all the way up.
3. The `.tool-versions` file in your home directory, which is where
   `asdf set -u` writes.

If you enable the `legacy_version_file` option described in [Coexist with
Legacy Tools](#coexist-with-legacy-tools) below, legacy files such as
`.ruby-version` and `.nvmrc` are also consulted during step 2, right after
`.tool-versions`.

The `.tool-versions` file itself is plain text, one tool per line:

```sh
cat ~/.tool-versions
nodejs 24.18.0
ruby 4.0.6
```

If you are working on a personal project or your team has adopted asdf, it is a
very good idea to commit the project's `.tool-versions` file to version control.
If your team has not agreed on asdf yet, add it to `.gitignore` instead, and see
[Coexist with Legacy Tools](#coexist-with-legacy-tools) below.

### Current Versions

To see which versions are active in the current directory and where they come
from, run `asdf current`:

```sh
asdf current
Name    Version    Source                                    Installed
nodejs  24.18.0    /Users/username/project/.tool-versions    true
ruby    4.0.6      /Users/username/.tool-versions            true
```

The `Source` column shows exactly which `.tool-versions` file each version was
resolved from, which makes it easy to figure out where a surprising version is
coming from.

## Use asdf in a Team

Coming back to the scenario from the beginning of this post: suppose your team
has adopted asdf (and if it has not yet, the next section is for you). Everyone
still needs the correct versions installed when they start working on a project
for the first time.

You could read the project's `.tool-versions` file and install each version by
hand, but there is no need. Run `asdf install` in the project directory without
any arguments:

```sh
asdf install
```

asdf reads `.tool-versions` and installs anything that is missing. One command,
and a new team member is ready to run the project. This remains one of my
favourite asdf features, and it works exactly as it did before the rewrite.

## Coexist with Legacy Tools

If you are sold on asdf but your team still uses rbenv, nvm and friends, there
is a configuration option that lets you meet them where they are. Create a
`.asdfrc` file in your home directory with the following content:

```sh
legacy_version_file = yes
```

With this set, asdf plugins will read the version files of other version
managers, for example `.ruby-version` for rbenv and `.nvmrc` for nvm. Your
teammates keep their existing tools and version files, and you get to use asdf
against the same repositories.

> Note: not all plugins support this feature. If you rely on this behaviour,
> check the documentation of the plugins you use.

## What About mise?

A 2026 guide to asdf would not be complete without mentioning [mise][]. mise
started life as a Rust reimplementation of asdf, and has grown into a broader
tool that also manages environment variables and project tasks. It understands
`.tool-versions` files and can use asdf plugins, so the two coexist well, and
the asdf documentation itself links to a [comparison][] between them.

I have stuck with asdf: it does one thing well, and I have used it for years.
Speed used to be the complaint you would hear most often, and mise is still
faster on paper, but with the 2x to 7x speedups from the Go rewrite, there is no
practical difference in daily use. If you want an all-in-one tool, though, mise
is a good alternative.

## Summary

In this post, I covered:

* what changed in the asdf rewrite in Go
* how to install asdf
* how to add plugins
* how to manage versions with `asdf set`
* how shims and version resolution work under the hood
* how asdf fits in a team setting
* how to use asdf alongside legacy tools

The commands may have changed since 2021, but the reasons I recommended asdf
back then have not: one tool, one set of commands, and a `.tool-versions` file
that makes sharing language versions across a team effortless. If you run into
anything this guide does not cover, the [asdf documentation][] remains your best
first stop.

[Getting Started]: https://asdf-vm.com/guide/getting-started.html
[How to Use asdf Version Manager on macOS]: /blog/how-to-use-asdf-on-macos/
[asdf documentation]: https://asdf-vm.com/
[asdf plugins repository]: https://github.com/asdf-vm/asdf-plugins
[asdf releases]: https://github.com/asdf-vm/asdf/releases
[comparison]: https://mise.jdx.dev/dev-tools/comparison-to-asdf.html
[create a plugin]: https://asdf-vm.com/plugins/create.html
[mise]: https://mise.jdx.dev/
[nvm]: https://github.com/nvm-sh/nvm
[pyenv]: https://github.com/pyenv/pyenv
[rbenv]: https://github.com/rbenv/rbenv
