---
title: "Setting Up QMK on macOS the Modern Way"
date: "2026-06-25 10:00:00 +1000"
tags: qmk macos mechanical_keyboard homebrew
header:
  image: /assets/images/2026-06-25/keyboard_build.jpg
  image_description: "A computer keyboard with several components attached to it"
  teaser: /assets/images/2026-06-25/keyboard_build.jpg
  overlay_image: /assets/images/2026-06-25/keyboard_build.jpg
  overlay_filter: 0.5
  caption: >
    Photo by [Limi change](https://unsplash.com/@limichange)
    on [Unsplash](https://unsplash.com/photos/Wx_6Jn7Xzxw)
excerpt: >
  A practical walkthrough for installing QMK on macOS the modern,
  self-contained way, and untangling an older Homebrew-based setup if
  you have one.
---

If your keyboard supports QMK, you can rewrite its firmware yourself: remap any
key, stack on layers, add macros and tap-hold behaviour, then flash the result
straight onto the board. On macOS, the way you install the toolchain for this
has quietly changed a while back. The old Homebrew recipe has been retired in
favour of a self-contained installer that is far less likely to break on you.
Here is how to set things up cleanly, and how to untangle an old Homebrew
install if that is where you are starting from.

Examples below use a ZSA Moonlander (`zsa/moonlander`) and a keymap called
`mykeymap`. Swap in your own board and keymap name as you go.

## Quick start

1. Install the toolchain: `curl -fsSL https://install.qmk.fm | sh`
2. Fetch the QMK source: `qmk setup` (already have a clone?
   `qmk config user.qmk_home=/path/to/qmk_firmware` instead)
3. Sanity-check: `qmk doctor` (optional if you ran `qmk setup`, which runs it
   for you)
4. Keep your keymap in its own repo via External Userspace (details below)
5. Build: `qmk compile -kb zsa/moonlander -km mykeymap`
6. Flash: `qmk flash -kb zsa/moonlander -km mykeymap`, then drop the board
   into its bootloader.

## Setting up QMK (recommended)

### What you're actually installing

The modern setup keeps everything tidy and self-contained, well away from your
system Python and your day-to-day Homebrew packages. Three pieces get
installed, all into user space:

- The **`qmk` CLI**, running inside its own `uv`-managed Python environment,
  so a Python upgrade somewhere else on your machine cannot break it.
- The **compilers** (ARM, AVR, RISC-V), as a prebuilt bundle that QMK
  maintains and ships itself. You do not have to hunt down cross-compilers or
  babysit their versions.
- The **flashing utilities** (`dfu-util`, `avrdude`, and friends), bundled
  right alongside.

When it is done, here is where things live by default, worth knowing so
nothing feels like a black box:

- `~/.local/bin/qmk`: the CLI, a symlink into `~/.local/share/uv/tools/qmk/`
- `~/.local/bin/uv`: the `uv` tool manager, if the script installed it
- `~/Library/Application Support/qmk/`: the compilers and flashing tools
- `~/Library/Application Support/qmk/qmk.ini`: your CLI config

### 1. Install the CLI and toolchains

One line does it:

```bash
curl -fsSL https://install.qmk.fm | sh
```

Yes, it is a `curl … | sh`, but it is the genuine official installer: all it
does is fetch QMK's bootstrap script and run it. It gives you a 10-second
countdown before touching anything (hit `Ctrl+C` if you change your mind),
then installs the three pieces above.

If you already have some of the prerequisites and do not want the installer
fussing with them, you can opt out of individual steps. The handiest one on a
machine already set up for development keeps it away from your Homebrew
packages:

```bash
curl -fsSL https://install.qmk.fm | SKIP_PACKAGE_MANAGER=1 sh
```

`SKIP_PACKAGE_MANAGER=1` stops the installer running `brew update`/`brew
upgrade`, so it will not churn through your existing packages just to install a
keyboard toolchain. (Already manage `uv` yourself? See
[Already manage uv yourself?](#already-manage-uv-yourself) below.)

Curious what else you can toggle? Run the installer with `--help`:

```bash
curl -fsSL https://install.qmk.fm | sh -s -- --help
```

One last thing before you move on: make sure `~/.local/bin` is on your `PATH`,
and ideally ahead of `/opt/homebrew/bin`, so the `qmk` you just installed is
the one your shell actually reaches for. Drop this in your `~/.zshrc` if it is
not already there:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then open a fresh shell and confirm with `which qmk`. You want to see
`/Users/you/.local/bin/qmk`.

### 2. Tell the CLI where the QMK source lives

The CLI needs to know which `qmk_firmware` checkout to build from. That is
the `qmk_home` setting.

If you do not have the QMK source yet, let QMK grab it for you (pass your
GitHub fork's username if you have one):

```bash
qmk setup
```

That clones the repo into `~/qmk_firmware`, sets `qmk_home`, and runs
`qmk doctor` to check things over.

Already cloned it somewhere of your own? Then skip `qmk setup`. Running it
would just clone a redundant second copy. Point the CLI at what you have
instead:

```bash
qmk config user.qmk_home=/Users/you/opensource/qmk_firmware
```

A quick read-back to confirm it stuck:

```bash
qmk config user.qmk_home
```

### 3. Check everything's happy

```bash
qmk doctor
```

Think of this as your pre-flight check. A clean run means the CLI, the
compilers, and `qmk_home` are all talking to each other. If something is
missing or misconfigured, this is where it will tell you, much nicer than
finding out halfway through a build.

### 4. Where to put your keymap

The recommendation here is **External Userspace**: keep your keymap in its
own repository, completely outside the QMK tree. It is the approach that ages
best: your personal config stays in a clean repo you own, and the QMK source
stays pristine, so pulling in upstream updates never tangles with your
changes.

The trick is that your external folder mirrors QMK's own layout, so your
keymap lives at:

```bash
<your-userspace>/keyboards/zsa/moonlander/keymaps/mykeymap/
```

You point QMK at the root of that userspace once:

```bash
qmk config user.overlay_dir=/path/to/your/userspace
```

From then on, the normal `qmk compile` command finds your keymap there
automatically, with no difference in how you build. The full walkthrough,
including how to scaffold the folder, lives in the [QMK External Userspace
docs](https://docs.qmk.fm/newbs_external_userspace).

If you would rather keep things dead simple and do not mind your keymap living
inside the QMK checkout, the in-tree spot still works fine: drop the same
`keymaps/mykeymap/` folder under `<qmk_home>/keyboards/zsa/moonlander/`. A lot
of people version just that folder as its own git repo to get some of the
separation benefits. It is a perfectly good starting point for a single
keymap. The snag shows up once you have more than one: because each keymap
lives in its own folder, each becomes its own separate git repo, so managing
several, possibly across different keyboards, means a repo to track for every
one. Your keymaps also show up as local changes inside the QMK tree.

### 5. Build it

```bash
qmk compile -kb zsa/moonlander -km mykeymap
```

A green `[OK]` and a freshly generated `.bin` (or `.hex` on AVR boards) means
you are good. You do not have to worry about the compiler being on your
`PATH`. The CLI quietly wires up its bundled toolchain for you each time.

### 6. Flash it

```bash
qmk flash -kb zsa/moonlander -km mykeymap
```

This compiles and then sits waiting for your keyboard to show up in bootloader
mode. To get a Moonlander there, do one of:

- Tap a **`QK_BOOT`** key, if your keymap has one mapped, or
- Press the physical **reset button** on top of the board.

The moment it enters the bootloader, `qmk flash` spots it and writes the
firmware. Prefer a GUI? ZSA's **Keymapp** flashes the same firmware without
the command line.

### Staying up to date

- **The CLI** is a `uv` tool, so `uv tool upgrade qmk` bumps it, or just
  re-run the install script.
- **The toolchains** refresh by re-running the install script whenever you
  want the latest bundle.
- **The QMK source** updates with a `git pull` in your `qmk_home`. Follow it
  with `git submodule update --init --recursive` to sync the submodules QMK
  pulls in. As long as you created your own keymap rather than updating the
  built-in keymaps in QMK, the pull stays conflict-free.

## Already manage uv yourself?

If you already have `uv` installed, say via Homebrew or its standalone
installer, there is no need to run the uv installer again. Pass `SKIP_UV=1` so
the QMK installer reuses the `uv` you already have:

```bash
curl -fsSL https://install.qmk.fm | SKIP_UV=1 sh
```

The only tradeoff is who owns updates: the `qmk` CLI still runs in its own
uv-managed environment either way, but you keep `uv` itself current yourself
(`brew upgrade uv`, or however you installed it) rather than re-running the QMK
installer to refresh it.

## If you set up QMK the old way (via Homebrew)

Most likely you installed `qmk` and the ARM/AVR compilers from a handful of
third-party Homebrew taps (`qmk/qmk`, `osx-cross/arm`, `osx-cross/avr`). For
years that was just a few `brew tap` and `brew install` commands that ran
without fuss. But that has recently changed: Homebrew 6.0.0 introduced Tap
Trust. Because a tap is a Git repo of Ruby that runs with your privileges, it
now refuses to load a non-official tap until you have explicitly trusted it. It
is a healthy change, it surfaces a trust decision that used to be made silently
on your behalf, but it also turns the old setup into a fiddlier and slightly
nervier process of vouching for several third-party sources before anything
will install. The self-contained installer above sidesteps all of that, which
is why the tap-based recipe has been retired.

### Cleaning out the old Homebrew install

Do this **after** the modern setup is working (`qmk doctor` green and a
successful compile), so you are never without a working build. The order
matters: uninstall the formulae first, then remove the taps, then sweep up
orphans.

```bash
brew uninstall --force qmk hid_bootloader_cli mdloader
brew uninstall arm-none-eabi-gcc@8 arm-none-eabi-binutils avr-gcc@8 avr-binutils
brew untap qmk/qmk osx-cross/arm osx-cross/avr
brew autoremove
```

A few notes so nothing surprises you:

- The `--force` on the first line clears out all installed versions at once.
- You cannot untap a tap while its formulae are still installed, which is why
  the untap comes after the uninstalls.
- `brew autoremove` mops up the long chain of dependencies the `qmk` formula
  originally dragged in (think Pillow → cairo/freetype/fonts, plus flashing
  tools like `avrdude`, `dfu-util`, `dfu-programmer`). It only removes things
  nothing else depends on, so shared tools like `make`, `libusb`, `hidapi`,
  `python`, and `openssl` stay put. Glance over its proposed list before
  confirming, and if you use something like `dfu-util` for non-QMK work, leave
  that one out of the uninstall.

### Other gotchas you might run into

**`qmk: no such file or directory` right after uninstalling.** This one is a
classic head-scratcher. zsh caches the full path of each command it has run,
so after you delete a binary it keeps reaching for the old, now-gone path.
Clear the cache and you are fine:

```bash
hash -r
```

(`rehash` works too, or just open a new terminal.)

**`qmk_home` set to `None`, so you are building the wrong tree.** If the CLI
does not know where the QMK source lives, it falls back to `~/qmk_firmware`,
which might be empty or simply not the repo your keymap is in, and you will get
baffling build results. Check it, then set it:

```bash
qmk config user.qmk_home
qmk config user.qmk_home=/Users/you/opensource/qmk_firmware
```

## Quick reference

Where everything lives by default:

- **CLI binary**: `~/.local/bin/qmk`, a symlink into
  `~/.local/share/uv/tools/qmk/`
- **Compilers and flashing tools**: `~/Library/Application Support/qmk/`
- **CLI config**: `~/Library/Application Support/qmk/qmk.ini`
- **QMK source**: wherever `user.qmk_home` points
- **Keymap (External Userspace)**:
  `<overlay_dir>/keyboards/<vendor>/<board>/keymaps/<name>/`
- **Keymap (in-tree)**: `<qmk_home>/keyboards/<vendor>/<board>/keymaps/<name>/`

Handy sanity commands:

```bash
qmk doctor
which qmk
qmk config
qmk compile -kb zsa/moonlander -km mykeymap
```
