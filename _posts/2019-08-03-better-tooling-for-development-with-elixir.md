---
title: "Better Tooling for Development with Elixir"
date: "2019-08-03 10:00:00 +1000"
last_modified_at: 2021-05-19 11:15:00 +1000
tags: elixir credo git_hooks
header:
  image: /assets/images/2021-05-19/elixir_1440_400.jpg
  image_description: "Elixir on White Background"
  teaser: /assets/images/2021-05-19/elixir_1440_400.jpg
  overlay_image: /assets/images/2021-05-19/elixir_1440_400.jpg
  overlay_filter: 0.3
  caption: >
    Image by [CHUTTERSNAP](https://unsplash.com/@chuttersnap)
    from [Unsplash](https://unsplash.com/photos/hqVGQ4-D0NI)
excerpt: >
  Chinese proverb: craftsmen must first sharpen their tools before they can do a
  good job
---

We ❤️ Elixir, so we want to the development process as smooth as possible.
Fortunately there are various tools that can help with the following:

* keep the code nicely formatted
* keep the code in a consistent style
* automate those two and more

In this article, I'll cover how we used these tools to improve our local
development setup and hopefully you could find a thing or two that are useful
for you too.

## Format Elixir code

In [Elixir 1.6][], a very nice code formatter has been provided, which could
format your code automatically without changing the semantics. So it helps a
great deal in keeping the code style consistent across the whole codebase or
even multiple codebases.

Without any setup, you can run `mix format file1 file2 ...` to format a few
individual Elixir source files. Or if you want to format all files in a repo
with one single command, you could provide a `.formatter.exs` file with a list
of file paths and patterns under the `inputs` key. For example:

```elixir
[
  inputs: [
    "{mix,.formatter}.exs",
    "config/*.exs",
    "apps/**/*.{ex,exs}"
  ]
]
```

will capture all Elixir files in a typical umbrella project. As you can see,
wildcards are supported in the file patterns and they are expanded with
`Path.wildcard/2`. Please refer to [mix format documentation][] for more
details.

## Check format with Git pre-commit hook

The only problem is that if people need to run it manually, they tend to forget
from time to time. As many of us have experienced, pointing out style violations
in code reviews is usually not the most enjoyable thing to do. We want to make
sure that all our Elixir code is nicely formatted before it is committed to Git
and this is exactly what pre-commit hook can help us with.

The easies way to do this is by adding a file named `pre-commit` under
`.git/hooks` with content similar to the following:

```bash
#!/bin/bash

cd `git rev-parse --show-toplevel`
mix format --check-formatted
if [ $? == 1 ]; then
   echo "commit failed due to format issues..."
   exit 1
fi
```

Then when you try to commit new changes in command line, format will be checked
and if there is any Elixir file that has not been properly formatted, the commit
attempt will fail with an error message. So far so good.

## Auto-format in your editor

To make one's life even easier, there are editor plugins to automatically run
the formatter upon saving:

Vim [https://github.com/mhinz/vim-mix-format](https://github.com/mhinz/vim-mix-format)

VsCode [https://github.com/jakesorce/vscode-elixir-formatter](https://github.com/jakesorce/vscode-elixir-formatter)

Atom [https://github.com/rgreenjr/atom-elixir-formatter](https://github.com/rgreenjr/atom-elixir-formatter)

If you use other editors, very likely there is an existing plugin/extension for
formatting Elixir code too and Google is your friend.

## Leverage mix aliases

[mix aliases][] can be very useful in running the same group of tasks over and
over again. For example, in the top level `mix.exs` file, we have the following
aliases defined:

```elixir
defmodule OurProject.Mixfile do
  use Mix.Project

  def project do
    [
      .
      .
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp deps do
    [
      .
      .
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["compile --warnings-as-errors", "ecto.reset", "test", "credo -a --strict"]
    ]
  end
end
```

So with just `mix test` we are actually running the following:

```bash
mix compile --warnings-as-errors
mix ecto.drop
mix ecto.create
mix ecto.migrate
mix test
mix credo -a --strict
```

all in `test` env. Only caveat of setting aliases like this is that any test
file paths with optional line number passed in as command line arguments are
ignored and I haven't quite figured out how to get around that. Another thing
worth noting is the last step, namely `mix credo -a --strict`, will use
[credo][] to run static code analysis and thus keep the style consistent.

Of course you could setup different aliases to suit your needs.

## Run test suite with pre-push hook

Since the pre-commit hook worked really well for us and also we would like to
avoid CI failures due to typos or other minor issues, running the test suite
with a git hook seems a reasonable next step. Although our entire test suite
only takes around two minutes to run, it's still a bit too much delay for
committing any changes. But it feels legit to run the test suite before pushing
to Github, thus preventing almost all failures on CI.

This can be done by creating a file named `pre-push` with the following content
under `.git/hooks` in your repo:

```bash
#!/bin/bash

set -euxo pipefail

cd `git rev-parse --show-toplevel`
mix clean
mix format --check-formatted
mix test
```

If you are curious about what does `set -euxo pipefile` do, [explainshell.com][]
might be helpful.

Of course there are cases where one might want to push potentially failing code
to a remote branch. That can be done with the `--no-verify` option:

```bash
git push origin your-remote-branch --no-verify
```

## Make hooks work for GUI Git clients

If you, like me, also use GUI Git clients like SourceTree to add commits, you'll
notice that the formatting check is skipped. As Sindre Sorhus pointed out in
[this StackOverflow answer][], this is due to:

> GUI apps on OS X doesn't load the stuff in `.bashrc/.bash_profile`, which
> means they won't have user specified `$PATH` additions like `/usr/local/bin`,
> which is where the grunt binary is. You can either specify the full path or
> fix the `$PATH` in your pre-commit hook, by adding this after the top
> comments: `PATH="/usr/local/bin:$PATH`"

Since people might install Elixir differently, the full path for Elixir binaries
could be different. So adding the paths in the `$PATH` environment variable
should work better. For example, setting the following in the `pre-commit` hook

```bash
PATH="/Users/$(whoami)/.asdf/shims:/usr/local/bin:$PATH"
```

should work for Elixir installed either with [asdf][] or homebrew.

## Same Git hooks for the team

Up to now, the setup should be reasonably good for one developer, but if you
work within a team, the same setup for all team members might be a very good
idea. This should help in avoiding most of the only works or only doesn't work
on one particular machine problems. It can be achieved in a number of ways. The
simplest way I could think of is by committing the hooks in the repo (for
example `./bin/git_hooks`) rather than in `.git/hooks` and then run

```bash
git config core.hooksPath ./path/to/your/git_hooks
```

on each team member's development machine.

## Summary

I've introduced the formatter for making sure code is consistently formatted,
credo for keeping code in great style, mix aliases for running groups of mix
tasks easier and also Git pre-commit and pre-push hooks for running them
automatically. While those might not be exactly what you want, hopefully this
article can offer some hints on how you could archive your similar needs.

## Acknowledgement

Special thanks to [Paul Fioravanti][] for his great feedback to my first draft,
which made this article much better.

[Elixir 1.6]: https://elixir-lang.org/blog/2018/01/17/elixir-v1-6-0-released/
[Paul Fioravanti]: https://twitter.com/paulfioravanti
[asdf]: https://github.com/asdf-vm/asdf
[credo]: https://github.com/rrrene/credo
[explainshell.com]: https://explainshell.com/explain?cmd=set+-euxo+pipefail
[mix aliases]: https://hexdocs.pm/mix/Mix.html#module-aliases
[mix format documentation]: https://hexdocs.pm/mix/master/Mix.Tasks.Format.html
[this StackOverflow answer]: https://stackoverflow.com/a/17557522/1228752
