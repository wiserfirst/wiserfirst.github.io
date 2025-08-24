---
title: "Taking Control of Terminal Titles"
date: 2025-08-24 21:55:00 +1000
tags: iTerm2 terminal
header:
  image: /assets/images/2025-08-24/terminal.jpg
  image_description: ""
  teaser: /assets/images/2025-08-24/terminal.jpg
  overlay_image: /assets/images/2025-08-24/terminal.jpg
  overlay_filter: 0.5
  caption: >
    Photo by [Sean Wang](https://unsplash.com/@maooooozaizi)
    on [Unsplash](https://unsplash.com/photos/an-escalator-in-a-large-building-with-lots-of-windows-DZSbsJHadH0)
excerpt: One simple command to rule them all
---

## The Background

As a developer, I use the terminal extensively and often SSH into remote machines
for management tasks. When I connect via SSH, iTerm2 automatically updates both
the window and tab titles to something like `user@machine-ip:directory-name`,
which provides helpful context about where I'm working. The problem? These titles
don't automatically revert when I disconnect, leaving me with stale information
in my terminal tabs.

For years, I had no idea what was happening under the hood, let alone how to fix
it. My workaround was crude but effective: close the tab and open a new one.
Eventually, I got fed up and decided to take some actions. After some research,
I added this mysterious snippet to my `.zshrc`:

```bash
precmd() {
  # sets the tab title to current dir
  echo -ne "\e]1;${PWD##*/}\a"
}
```

I'll be honest—I didn't fully understand how it worked, but it did the job. This
function "forced" my tab title to always display the current directory name,
even after disconnecting from SSH sessions.

Later, I discovered [Prezto][], a configuration framework for Zsh that includes
a handy `set-tab-title` function. This gave me more flexible control over tab
titles, so I happily retired my hacky `precmd` solution.

You might have noticed that the window title remained untouched throughout this
journey. It simply wasn't annoying enough to warrant investigation—until Claude
Code came along.

Since its public launch in February, Claude Code has become my go-to tool for
AI-assisted coding. Like SSH, it helpfully sets custom tab and window titles to
show what it's working on. Also like SSH, these titles stick around after Claude
Code exits, cluttering my terminal with outdated information like "Building
Feature X..." or "Optimising test performance..." long after those tasks
completed.

Since I was using Claude Code across multiple projects every day, these stale
titles were starting to get on my nerves and that was the final straw. It was
time to properly understand how terminal titles work and build a comprehensive
solution.

## Understanding Terminal Titles in iTerm2

Before diving into solutions, let's understand what we're dealing with. iTerm2
(and most terminal emulators) recognize two distinct title types:

1. **Tab Title** - Displayed on the individual tab
2. **Window Title** - Shown in the center of the window's title bar

These titles are controlled through ANSI escape sequences - special character
combinations that terminals interpret as commands rather than text to display.

### The Magic Behind Terminal Titles

Here's how escape sequences work for setting titles:

```bash
# Set window title only (shows in title bar)
echo -ne "\033]2;Your Window Title\007"

# Set tab title only (shows in tab)
echo -ne "\033]1;Your Tab Title\007"

# Set both window and tab to the same title
echo -ne "\033]0;Your Title\007"
```

The cryptic `\033]` starts the escape sequence, the number (0, 1, or 2)
specifies which title to set, and `\007` (the bell character) ends it.

Quick note on escape characters: You might see these written as `\e` (instead of
`\033`) and `\a` (instead of `\007`) in some scripts—they're equivalent, just
different representations of the same ASCII characters. I'm using the octal
format (`\033` and `\007`) here for maximum compatibility across different
shells and systems.

Simple, right? Well, not exactly intuitive and quite cumbersome to use, which is
why we're building a better interface.

## The Solution: A Simple Title Manager

Let's create a user-friendly function that makes title management a breeze. Add
this to your `~/.zshrc` (or `~/.bashrc` for Bash users):

```bash
# Terminal title management functions
terminal_titles() {
    case "$1" in
        window)
            echo -ne "\033]2;$2\007"
            ;;
        tab)
            echo -ne "\033]1;$2\007"
            ;;
        both)
            echo -ne "\033]0;$2\007"
            ;;
        help)
            echo "Usage: terminal_titles [window|tab|both|reset|help] [title]"
            echo "  window [title] - Set window title only"
            echo "  tab [title]    - Set tab title only"
            echo "  both [title]   - Set both window and tab to same title"
            echo "  reset          - Reset to default titles"
            echo "  help           - Show this help message"
            echo "  (no args)      - Same as reset"
            ;;
        reset|"")
            # Window title: full path with ~ for home
            echo -ne "\033]2;${PWD/#$HOME/~}\007"
            # Tab title: last portion of the full path
            echo -ne "\033]1;${PWD##*/}\007"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use 'terminal_titles help' for usage"
            ;;
    esac
}

# Alias for convenience
alias tt='terminal_titles'
```

### How to Use It

Now you have a simple `tt` command at your disposal:

```bash
# Reset titles to show current directory info
tt

# Set a custom window title
tt window "Development Server"

# Set a custom tab title
tt tab "logs"

# Set both to the same title
tt both "Project X"

# Get help
tt help
```

The default behavior (`tt` with no arguments) resets your titles to something
useful:

- **Window title**: Full path of current directory (with `~` for home)
- **Tab title**: Just the current folder name

For example, if you're in `/Users/you/projects/awesome-app`, the window shows
`~/projects/awesome-app` and the tab shows `awesome-app`.

## Conclusion

After years of closing and reopening tabs to clear stale SSH titles, and more
recently dealing with Claude Code's persistent status messages, I finally have a
solution that just works. The `tt` command is now muscle memory—quick to type,
easy to remember, and does exactly what I need.

The beauty of this solution is its simplicity. No complex configurations, no
heavyweight terminal managers—just a few lines of shell script that give you
complete control. Whether you're jumping between SSH sessions, running Claude
Code throughout the day, or just want cleaner tab organization, you now have the
tools to keep your terminal titles under control.

Happy terminal customizing! 🚀

---

> **Note**: After building this solution, I discovered that Prezto actually has
> a `set-window-title` command hiding alongside the `set-tab-title` function I'd
> been using for years. Had I found it earlier, this entire journey into the
> depths of ANSI escape sequences might never have happened. But you know what?
> I'm okay with missing it. Sometimes the scenic route teaches you more than the
> shortcut ever could, and now I truly understand what's happening under the
> hood rather than just blindly using a command.

## Appendix: Auto-Reset with Smart Persistence

If you want titles to automatically reset after commands like Claude Code exit,
but keep your manually-set titles, here's an enhanced version with intelligent
auto-reset. This adds more complexity but offers finer control:

```bash
# Terminal title management functions with smart auto-reset
terminal_titles() {
    case "$1" in
        window)
            echo -ne "\033]2;$2\007"
            export TERMINAL_TITLE_MANUAL=1
            ;;
        tab)
            echo -ne "\033]1;$2\007"
            export TERMINAL_TITLE_MANUAL=1
            ;;
        both)
            echo -ne "\033]0;$2\007"
            export TERMINAL_TITLE_MANUAL=1
            ;;
        help)
            echo "Usage: terminal_titles [window|tab|both|reset|auto|help] [title]"
            echo "  window [title] - Set window title only"
            echo "  tab [title]    - Set tab title only"
            echo "  both [title]   - Set both window and tab to same title"
            echo "  reset          - Reset to default titles"
            echo "  auto           - Enable auto-reset after commands"
            echo "  help           - Show this help message"
            echo "  (no args)      - Same as reset"
            ;;
        auto)
            unset TERMINAL_TITLE_MANUAL
            terminal_titles reset
            echo "Auto-reset enabled"
            ;;
        reset|"")
            # Window title: full path with ~ for home
            echo -ne "\033]2;${PWD/#$HOME/~}\007"
            # Tab title: last portion of the full path
            echo -ne "\033]1;${PWD##*/}\007"
            unset TERMINAL_TITLE_MANUAL
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use 'terminal_titles help' for usage"
            ;;
    esac
}

# Alias for convenience
alias tt='terminal_titles'

# Auto-reset after commands ONLY if not manually set (for zsh)
if [[ -n "$ZSH_VERSION" ]]; then
    precmd() {
        # Only reset if titles weren't manually set
        if [[ -z "$TERMINAL_TITLE_MANUAL" ]]; then
            # Window title: full path with ~ for home
            echo -ne "\033]2;${PWD/#$HOME/~}\007"
            # Tab title: last portion of the full path
            echo -ne "\033]1;${PWD##*/}\007"
        fi
    }
fi
```

This enhanced version adds:

- **Smart persistence**: Manually-set titles survive command execution
- **Auto-reset mode**: Titles automatically update after commands (when not
  manually set)
- **Flexible control**: Switch between manual and automatic modes with `tt auto`

### The Smart Workflow

1. **Normal operation**: Titles auto-update to show your current directory
2. **Set custom title**: `tt tab "server logs"` - This persists across commands
3. **Return to auto-mode**: `tt auto` or `tt reset`

[Prezto]: https://github.com/sorin-ionescu/prezto
