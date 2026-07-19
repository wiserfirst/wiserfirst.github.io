---
title: "Setup New Mac for Software Development"
date: "2021-09-07 11:35:00 +1000"
last_modified_at: 2026-07-19 23:30:00 +1000
tags: Apple Mac macos
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

<div class="notice--info" markdown="1">
**Update, July 2026:** I've refreshed this guide for my current setup:

- [Step 3] switched to the gh CLI, which generates and uploads the SSH key in
  one flow, keeping the website route as an alternative
- [Step 4] folded my Vim config into dotfiles, dropping the standalone
  maximum-awesome step
- [Step 5] switched asdf to the Homebrew install and refreshed the language
  versions
- [Step 8] added herdr for terminal workspaces
- [Step 9] added Raycast, with a cameo from Hammerspoon, for launching and
  window management
- [Step 10] updated the iTerm2 settings to match
- [Step 11] replaced the deprecated `softwareupdate --ignore` trick with an
  approach that works on current macOS

</div>

Many software developers use Mac computers for work or personal use. To start on
a new Mac, the most convenient option is to transfer from an existing Mac or
restore from a Time Machine backup. But from time to time, we still need to set
it up as a brand new computer, maybe because an existing Mac isn't available or
we simply want to start fresh with the new laptop.

In this post, I'll document what I consider the best way to setup a brand new
Mac for software development. The primary purpose is to serve as a reference for
my future self, but if some readers find it useful, that would be awesome too.

These are just based on my personal experience, so there is no guarantee they'll
work well for you too. If you find other better ways to do certain steps, please
let me know in the public comment below or reach out to me directly.

## Step 1: Install Homebrew

I use Homebrew to install and manage most command line tools and GUI apps.

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

I've saved a `Brewfile` to my `dotfiles` repository on GitHub, so I can just
download it with:

```sh
curl -fL -o Brewfile https://raw.githubusercontent.com/wiserfirst/dotfiles/master/Brewfile
```

And then run `brew bundle` to install the packages.

Among other things, this pulls in the tools I configure in later steps (iTerm2,
herdr, Raycast, and Hammerspoon), so those steps are about setting them up
rather than installing them.

## Step 3: Add SSH key to GitHub

The next couple steps involve cloning from GitHub, so the new Mac needs an SSH
key added to my GitHub account. The GitHub CLI (installed by `brew bundle` in
Step 2) handles the whole thing, key generation included:

```sh
gh auth login
```

Choose GitHub.com, pick **SSH** as the preferred protocol, let it generate a
new SSH key (it prompts for an optional passphrase; the key lands in
`~/.ssh/id_ed25519`), give the key a title, and authenticate with the web
browser option. The browser part shrinks to entering an 8-character one-time
code and clicking Approve, and it doesn't have to happen on the new Mac:
approving from your phone works, which is handy when the new machine has no
browser signed in to GitHub yet. As a bonus, `gh` itself is now authenticated
for anything else you need it for later.

You can add another key later without redoing auth:

```sh
gh ssh-key add ~/.ssh/id_ed25519_work.pub --type authentication
```

### Alternative: add via the GitHub website

If you are more comfortable with the good old way, generate the key yourself:

```sh
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Please note: the `-C` email is just a comment to help you tell keys apart; it
doesn't affect authentication in any way.

Reference: [Generating a new SSH key and adding it to the ssh-agent][GitHub
generate SSH key docs]

Then copy your public key to the clipboard:

```sh
pbcopy < ~/.ssh/id_ed25519.pub
```

Finally, login to your GitHub account, go to Settings -> SSH and GPG keys ->
New SSH key. Give it a title and paste your key into the "Key" field.

Reference: [Adding a new SSH key to your GitHub account][GitHub add SSH key
docs]

## Step 4: Install my dotfiles

```sh
git clone git@github.com:wiserfirst/dotfiles.git
cd dotfiles
ruby ./install.rb
```

`install.rb` symlinks all of my dotfiles into place: shell config, Vim,
Hammerspoon, herdr, and so on. The Vim part is worth calling out: it symlinks
`.vimrc`, `.vimrc.bundles`, and `~/.vim`, and that configuration used to live in
a separate [maximum-awesome] checkout before I folded it into these dotfiles.

The first time you launch Vim, [vim-plug] bootstraps itself and installs all
plugins automatically, with no manual `:PlugInstall` needed.

## Step 5: Install asdf and programming languages

I use [asdf] to manage language runtime versions, and it's installed by `brew
bundle` (Step 2). asdf works through a shims directory, so it needs that
directory on your `PATH`. If you don't already have this in your `~/.zshrc`,
add:

```sh
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

For zsh completions, the Homebrew formula already installs a completion file
into Homebrew's `site-functions` directory, so they work as long as that
directory is on your `fpath` before `compinit` runs (Homebrew's shell setup, and
prezto in Step 6, both take care of that). If you installed asdf some other way,
generate the file yourself and drop it somewhere on your `fpath`:

```sh
asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
```

Now I'd like to install Erlang and Elixir:

```sh
asdf plugin add erlang
asdf plugin add elixir
asdf install erlang 29.0.2
asdf install elixir 1.20.2-otp-29
asdf set -u erlang 29.0.2
asdf set -u elixir 1.20.2-otp-29
```

A couple of notes:

- `asdf set -u` is what pins those versions globally; the `-u`/`--home` flag
  writes them to `~/.tool-versions` in your home directory.
- The Erlang build picks up Homebrew's OpenSSL automatically, so it usually
  needs no extra configuration. If a build ever fails to locate OpenSSL, point
  it at it explicitly with
  `export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3)"`.

Obviously you could install whatever programming languages you need, be that
Ruby, Node.js, Python or something else.

For more details on how to do that with asdf, check out my comprehensive guide:
[How to Use asdf Version Manager on macOS (2026 Update)][asdf post].

## Step 6: Install prezto

```sh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

If you followed Step 4, some of these symlinks (like `.zshrc`) already exist,
so `ln -s` will complain "File exists" for them. Those errors are harmless:
the dotfiles versions already source prezto.

## Step 7: Install fzf

```sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Step 8: Terminal workspaces with herdr

[herdr] is a tmux-style terminal workspace manager. A background **server**
holds your sessions while the TUI you see is just a **client**, so closing the
window or detaching never kills your shells. Running `herdr` on its own
reattaches to the default session, right where you left it. If there are other
sessions, they'll keep running too: `herdr --session <name>` starts a named
session or reattaches to it if it already exists, and `herdr session list` shows
them all.

Setup is already handled by earlier steps: `brew bundle` installed it (Step 2)
and `install.rb` (Step 4) symlinked its config to `~/.config/herdr/config.toml`,
so it works out of the box.

The mental model is **Workspaces** (one per project) → **Tabs**. (It also
supports **Panes**, splits within a tab, if you want them.) The **prefix** is
`ctrl+b` (so "prefix+f" means press `ctrl+b`, release, then `f`), and **Meh**
(`ctrl+alt+shift`) drives workspace and tab navigation:

| Action                            | Key                                            |
| --------------------------------- | ---------------------------------------------- |
| New workspace (project picker)    | `prefix+f` (or Raycast "Open Project")         |
| New empty workspace               | `prefix+shift+n`                               |
| Close workspace (asks to confirm) | `prefix+shift+d`                               |
| New tab                           | `prefix+c`                                     |
| Close tab                         | `prefix+shift+x`                               |
| Next / prev workspace             | `Meh+J` / `Meh+K`                              |
| Jump to workspace 1-9             | `Meh+1-9`                                      |
| Next / prev tab                   | `Meh+L` / `Meh+H` (or `prefix+n` / `prefix+p`) |

The main way I open a workspace is the **sessionizer**: `prefix+f` pops an fzf
picker over my project directories and creates-or-focuses a workspace for
whatever I pick. The same script backs the Raycast "Open Project" command in the
next step, so I can reach it from outside the terminal too. Press `prefix+?` any
time for the full list of bindings.

herdr is built for running AI coding agents, so its sidebar lists **agents**
alongside your workspaces. It detects agents like Claude Code running in its
terminals and shows each one's status (idle, working, or blocked), and a glance
at the sidebar tells you which workspace needs your attention. Built-in
integrations deepen the status reporting (`herdr integration install claude`,
with Codex, opencode, and friends also supported), and the `herdr agent`
subcommands (`list`, `send`, `wait`, and more) let you script against running
agents from outside the TUI.

One note on clearing the screen: use `ctrl+l` or `clear`, not `Cmd+K`. In iTerm2
`Cmd+K` clears the entire terminal buffer, which pulls the ground out from under
herdr's TUI: the sidebar listing your workspaces and agents simply vanishes and
the screen goes blank. It's not fatal, since `Cmd+Tab` away and back forces a
repaint and everything comes back. If you don't need `Cmd+K` to clear the
buffer, you can remap it to send `ctrl+l` instead (see Step 10).

## Step 9: Raycast for launching and window management

[Raycast] is a Spotlight replacement that I use as an app launcher, window
manager, and general command runner (it was installed back in Step 2). Almost
all of its global hotkeys hang off **Hyper** (`⌘⌃⌥⇧`), a single key that fires
Command, Control, Option, and Shift together, opening up a whole space of combos
that nothing else on the system uses.

App switching:

| Hotkey  | App                    |
| ------- | ---------------------- |
| Hyper+B | Zen                    |
| Hyper+C | Chrome                 |
| Hyper+T | iTerm2                 |
| Hyper+Z | Zed                    |
| Hyper+S | SourceTree             |
| Hyper+V | MacVim (via Quicklink) |
| Hyper+K | ClickUp                |
| Hyper+P | Postico                |
| Hyper+O | Obsidian               |

Window management:

| Hotkey  | Action       |
| ------- | ------------ |
| Hyper+H | Left half    |
| Hyper+L | Right half   |
| Hyper+M | Maximize     |
| Hyper+D | Next display |

Two custom commands are worth calling out:

- **Open Project**: a script command that wraps `~/.local/bin/herdr-sessionizer`
  (the exact same sessionizer as `prefix+f` in herdr, one script and one source
  of truth). It's the out-of-terminal twin for jumping straight into a project's
  workspace.
- **MacVim Quicklink**: MacVim is a brew formula whose app bundle lives in the
  Cellar, so it stays invisible to Spotlight even with the
  `/Applications/MacVim.app` symlink. A Quicklink launches it instead of the
  Applications extension.

A few Raycast things worth mentioning:

- **Aliases** (Extensions tab): a short keyword typed in Root Search that
  prioritizes a command; it costs no global hotkey, so it's great for
  second-tier commands.
- **The `⌘K` action menu:** with a command highlighted in Root Search, `⌘K`
  opens the actions available for it (configure it, set an alias, and so on).
  The exact wording depends on what's selected, and it just drops you into
  Settings focused on that item.
- **Review what you've customized:** in Settings → Extensions, enable "Show only
  customized" in the dropdown to narrow the list to everything you've given a
  hotkey or alias.
- **Hyper Key feature** (Settings → Keyboard → Hyper Key): can turn Caps Lock
  into Hyper (hold = Hyper, tap = Escape), handy though it only produces Hyper,
  not Meh.

Both **Hyper** and **Meh** (`⌃⌥⇧`) are single physical keys on my ZSA
Moonlander, defined in its QMK firmware. On keyboards with no QMK support you
can synthesize the same keys with [Karabiner-Elements] instead, or, for Hyper
alone, use Raycast's Hyper Key feature mentioned above.

The way I keep the two from stepping on each other: every Raycast hotkey sits on
Hyper, every herdr binding sits on Meh, and I make sure herdr's `Meh+H/J/K/L`
and `Meh+1-9` are never bound in Raycast or macOS. Nothing actually forces that
split; Hyper and Meh combos can coexist just fine, as long as no individual
chord collides.

One last small piece: [Hammerspoon] (also installed and configured via my
dotfiles) does exactly one thing in my setup, **mouse-follows-focus**. When
keyboard focus moves to another window, it warps the pointer to that window's
centre so scroll and wheel events land where I'm actually working (guarded so
click-to-focus never yanks the cursor away). It complements Raycast's window
management nicely.

## Step 10: Settings in GUI

- iTerm2 (Settings)
  - Profiles -> Colors -> Color Presets -> Solarized Dark
  - Profiles -> Text -> Font -> Size to 14
  - Profiles -> Terminal -> Scrollback Buffer -> tick "Unlimited scrollback"
  - Profiles -> Keys -> General -> set **both** Left and Right Option keys to
      "Esc+" (required for herdr's Meh/alt navigation hotkeys)
  - (Optional) Profiles -> Keys -> Key Mappings -> remap `⌘K` to Send Hex Code
      `0x0C` so it clears the pane like `ctrl+l` instead of blanking herdr's UI
- System Settings
  - Keyboard -> Keyboard Shortcuts -> Modifier Keys -> Map "Caps Lock" key to
      Escape
  - Trackpad -> Point & Click -> tick "Tap to click"
  - Accessibility -> Pointer Control -> Trackpad Options -> turn on "Use
      trackpad for dragging" -> Dragging style "Three Finger Drag"
  - (Optional for external monitor) Displays -> select the external monitor
      and choose a scaled resolution of 2560 x 1440 (enable "Show all
      resolutions" if it isn't listed)

## Step 11: Defer a major macOS upgrade (optional)

If you're not ready to jump to the latest major version of macOS, be aware that
the widely-shared `sudo softwareupdate --ignore "macOS ..."` command no longer
works for this: Apple deprecated it for major upgrades back in Big Sur, and on
recent releases (Sequoia, Tahoe) it just prints a deprecation notice while any
upgrade prompt sticks around.

What works now is pushing the major-upgrade notification date far into the
future:

```sh
defaults write com.apple.SoftwareUpdate MajorOSUserNotificationDate -date "2035-01-01 00:00:00 +0000"
```

This only silences the "Upgrade to macOS ..." prompt; notifications about normal
point releases and security updates keep coming. (If you'd rather mute those
too, the sibling key `UserNotificationDate` does the same for routine updates.)
To undo it later, delete the key:

```sh
defaults delete com.apple.SoftwareUpdate MajorOSUserNotificationDate
```

If you'd rather not touch the command line, you can get most of the way there in
the GUI: turn off automatic updates under System Settings -> General -> Software
Update, and silence the nag under System Settings -> Notifications -> Software
Update. When you're finally ready to upgrade, just do it from Software Update as
normal.

## Summary

After following the steps in this post, there may be things you still need to
install or tweak, but the new Mac should be fairly close to being ready as the
primary development machine.

Surely, these steps are going to evolve over time and I'll try my best to keep
them up-to-date. But again, I don't do this very often, so they may get out of
date.

Anyway, please feel free to take what you need and let me know what you think
:slightly_smiling_face:

[bundle manpage]: https://docs.brew.sh/Manpage#bundle-subcommand
[GitHub add SSH key docs]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
[GitHub generate SSH key docs]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
[Homebrew Bundle]: https://github.com/Homebrew/homebrew-bundle
[Homebrew Installation guide]: https://docs.brew.sh/Installation
[maximum-awesome]: https://github.com/wiserfirst/maximum-awesome
[vim-plug]: https://github.com/junegunn/vim-plug
[herdr]: https://herdr.dev
[Raycast]: https://www.raycast.com
[Hammerspoon]: https://www.hammerspoon.org
[Karabiner-Elements]: https://karabiner-elements.pqrs.org
[asdf]: https://asdf-vm.com/
[asdf post]: /blog/how-to-use-asdf-on-macos-2026-update/
