---
title: "Setup New Mac for Software Development"
date: "2021-09-07 11:35:00 +1000"
tags: Apple Mac macOS
header:
  image: /assets/images/2021-09-07/macbook_1440_400.jpg
  image_description: "Macbook on desk"
  teaser: /assets/images/2021-09-07/macbook_1440_400.jpg
  overlay_image: /assets/images/2021-09-07/macbook_1440_400.jpg
  overlay_filter: 0.4
  caption: >
    Image by [Clay Banks](https://unsplash.com/@claybanks)
    from [Unsplash](https://unsplash.com/photos/oO6Gm16Cqcg)
excerpt: Step by step guide for setting up a new Mac computer
---

Many software developers use Mac computers for work or personal use. To start
on a new Mac, the most convenient option is to transfer from an existing Mac or
restore from a Time Machine backup. But from time to time, we still need to set
it up as a brand new computer, maybe because an existing Mac isn't available or
we simply want to start fresh with the new laptop.

In this post, I'll document what I consider the best way to setup a brand new
Mac for software development. The primary purpose is to serve as a reference
for my future self, but if some readers find it useful, that would be awesome
too.

These are just based on my personal experience, so there is no guarantee they'll
work well for you too. If you find other better ways to do certain steps, please
let me know in the public comment below or reach out to me directly.

## Step 1: Install Homebrew

I use Homebrew to install and manage most of command line tools and GUI apps.

Install it with:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This script is quite intelligent. It works on Intel or Apple Silicon based Macs
and even Linux, and it installs Homebrew to different preferred prefixes based
on the situation. For more information, please refer to the [Homebrew
Installation guide].

## Step 2: brew bundle

Manually installing all the packages needed on a new Mac is tedious, but luckily
we don't have to do that thanks to [Homebrew Bundle].

One can create a `Brewfile` with `brew bundle dump` and then run `brew bundle`
to install and upgrade all packages from the `Brewfile`. For more details,
please refer to [the `brew bundle` section of the `brew man` output][bundle
manpage] or `brew bundle --help`.

I've saved a `Brewfile` to my `dotfiles` repository on Github, so I can just
download it with:

```sh
curl -fL -o Brewfile https://raw.githubusercontent.com/wiserfirst/dotfiles/master/Brewfile
```

And then run `brew bundle` to install the packages.

## Step 3: Add SSH key to Github

The next couple steps involve cloning from Github, so generating a new SSH key
and adding it to my Github account is necessary.

### Generate new SSH key

```sh
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Reference: [Generating a new SSH key and adding it to the ssh-agent][Github generate SSH key docs]

### Add to Github account

First copy your SSH public key to clipboard with

```sh
pbcopy < ~/.ssh/id_ed25519.pub
```

Then login to your Github account, go to Settings -> SSH and GPG keys -> New SSH
key. Give it a title and paste your key into the "Key" field.

Reference: [Adding a new SSH key to your Github account][Github add SSH key
docs]

## Step 4: Install my dotfiles

```sh
git clone git@github.com:wiserfirst/dotfiles.git
cd dotfiles
ruby ./install.rb
```

## Step 5: Install maximum-awesome

```sh
git clone git@github.com:wiserfirst/maximum-awesome.git
cd maximum-awesome
git checkout qing
rake
```

For installing Vim plugins separately, just run `:PlugInstall` in Vim.

## Step 6: Install asdf-vm and programming languages

```sh
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
```

If you don't already have this in your zshrc, the following is needed:

```sh
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
```

Now I'd like to install Erlang and Elixir:

```sh
asdf plugin-add erlang
asdf plugin-add elixir
# actual Openssl version depends on what's in `brew list`
export KERL_CONFIGURE_OPTIONS="--without-javac --with-ssl=$(brew --prefix openssl@1.1)"
asdf install erlang 23.3.4
asdf install elixir 1.12.3
asdf global erlang 23.3.4
asdf global elixir 1.12.3
```

Obviously you could install whatever programming languages you need, be that
Ruby, Node.js, Python or something else.

For more details on how to do that with asdf, check out my comprehensive guide:
[How to Use asdf Version Manager on macOS].

## Step 7: Install prezto and set zsh as default shell

```sh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
sudo chsh -s /bin/zsh
```

## Step 8: Install fzf

```sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Step 10: Preferences in GUI

* iTerm
  * Profiles -> Colors -> Color Presets -> Solarized Dark
  * Profiles -> Text -> Font -> Size to 14
  * Profiles -> Terminal -> Scrollback Buffer -> tick "Unlimited scrollback"
* System Preferences
  * Keyboard -> Modifier Keys -> Map "Caps lock" key to Escape
  * Trackpad -> Point & Click -> tick "Tap to click"
  * Accessibility -> Pointer Control -> Trackpad Options -> tick "Enable
      dragging" -> three finger drag
  * (Optional for external monitor) Displays -> (on the external monitor) Option + click "Scaled" and choose
      2560 x 1440

## Step 11: Ignore new system update (optional)

If you are not ready to upgrade to the latest version of macOS, you can stop it
from showing up in System Preferences -> Software Update with:

```sh
sudo /usr/sbin/softwareupdate --ignore "macOS [version name]"
```

Here `version name` could be `Catalina`, `Big Sur` or `Monterey`, depending on
which you'd like to ignore.

When you are ready to install the new version, just restore it with:

```sh
sudo /usr/sbin/softwareupdate --reset-ignored
```

## Summary

After following the steps in this post, there may be things you still need to
install or tweak, but the new Mac should be fairly close to be ready as the
primary development machine.

Surely, these steps are going to evolve over time and I'll try my best to keep
them up-to-date. But again, I don't do this very often, so they may get out of
date.

Anyway, please feel free to take what you need and let me know what you think
:slightly_smiling_face:

[bundle manpage]: https://docs.brew.sh/Manpage#bundle-subcommand
[Github add SSH key docs]: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
[Github generate SSH key docs]: https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
[Homebrew Bundle]: https://github.com/Homebrew/homebrew-bundle
[Homebrew Installation guide]: https://docs.brew.sh/Installation
[How to Use asdf Version Manager on macOS]: /blog/how-to-use-asdf-on-macos/
