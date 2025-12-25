---
title: "Installing Elixir Language Server for Vim"
date: 2025-12-25 15:50:00 +1100
tags: Elixir LSP Vim
header:
  image: /assets/images/2025-12-25/toolbox.jpg
  image_description: ""
  teaser: /assets/images/2025-12-25/toolbox.jpg
  overlay_image: /assets/images/2025-12-25/toolbox.jpg
  overlay_filter: 0.2
  caption: >
    Photo by [LouisMoto](https://unsplash.com/@louismotorrad)
    on [Unsplash](https://unsplash.com/photos/a-tool-kit-with-tools-in-it-sitting-on-a-table-m4XS2ACf85k)
excerpt: Leveraging the power of LSP
---

ElixirLS is the Elixir Language Server that provides IDE features like
autocomplete, diagnostics, go-to-definition, and Dialyzer integration. This
guide covers setting it up in Vim using coc.nvim.

## Prerequisites

- Vim or Neovim with [coc.nvim](https://github.com/neoclide/coc.nvim) installed
- Elixir and Erlang installed (ideally managed via asdf)

## Step 1: Install ElixirLS

Clone and build ElixirLS:

```bash
git clone https://github.com/elixir-lsp/elixir-ls.git ~/.elixir-ls
cd ~/.elixir-ls
mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod mix elixir_ls.release2 -o release
```

The last command builds the executable language server to
`~/.elixir-ls/release/`, and that is the path we need to use in the coc.nvim
configuration.

## Step 2: Configure coc.nvim

Open your coc settings in Vim with `:CocConfig` and add:

```json
{
  "elixir.pathToElixirLS": "~/.elixir-ls/release/language_server.sh"
}
```

## Step 3: Install coc-elixir

In Vim, run:

```vim
:CocInstall coc-elixir
```

This installs the coc.nvim extension that communicates with ElixirLS.

## Step 4: Verify

Open an Elixir file in your project. You should see:

- Autocomplete suggestions
- Inline diagnostics and warnings
- Go-to-definition working (`:call CocAction('jumpDefinition')`)

## Understanding the .elixir_ls Directory

When you first open an Elixir project, ElixirLS creates a `.elixir_ls/`
directory and compiles your project. You might wonder why it doesn't just use
`_build/`.

ElixirLS maintains its own build for several reasons:

1. **Avoids conflicts** - Your `_build/` uses your development environment.
   ElixirLS compiles separately so running `mix test` doesn't invalidate the
   language server's build.

2. **Different compile options** - ElixirLS uses flags that capture additional
   metadata for IDE features. These would slow down normal development builds.

3. **Dialyzer PLT files** - ElixirLS caches Dialyzer's Persistent Lookup Table
   here. Building PLTs is slow, so caching them per-project saves time.

4. **Independence** - If your `_build/` breaks, ElixirLS keeps working.

Consider adding `.elixir_ls/` to your global gitignore:

```bash
echo ".elixir_ls/" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

## Troubleshooting

If ElixirLS behaves unexpectedly, the simplest fix is to delete its cache and restart:

```bash
rm -rf .elixir_ls/
```

Then in Vim:

```vim
:CocRestart
```

ElixirLS automatically recreates the directory and recompiles when it restarts.

**Common reasons to clear the cache:**

- Upgraded Elixir or Erlang versions
- Dialyzer giving stale warnings
- Language server stuck or unresponsive
- Dependency changes not being picked up
