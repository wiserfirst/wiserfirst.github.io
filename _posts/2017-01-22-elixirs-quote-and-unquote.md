---
title: "Elixir's quote and unquote"
date: "2017-01-22 10:00:00 +1100"
last_modified_at: 2021-05-19 18:36:00 +1000
tags: elixir macro tiny-tips
header:
  image: /assets/images/2021-05-19/sunlight_1440_400.jpg
  image_description: "Sun Light through a Tree"
  teaser: /assets/images/2021-05-19/sunlight_1440_400.jpg
  overlay_image: /assets/images/2021-05-19/sunlight_1440_400.jpg
  overlay_filter: 0.4
  caption: >
    Image by [Omkar Jadhav](https://unsplash.com/@jadhav24omkar)
    from [Unsplash](https://unsplash.com/photos/s5xNLPMxHZU)
excerpt: The first step in understanding macros in Elixir
---

For a very long time, I had a hard time trying to understand how macros work in
Elixir. Since I don't have any Lisp background, that's a whole new concept for
me.

But yesterday, after reading the relevant section in [Elixir's getting started
guild], I suddenly realised how `quote` and `unquote` work. First of all, an
Elixir expression is internally represented as a tuple with three elements,
which is Elixir's version of the Abstract Syntax Tree (AST). `quote` can give
you the AST representation of a piece of code, so that you can manipulate later.
`unquote` only works inside `quote` and it can evaluate an expression and then
inject the resulting value into the AST. `quote` and `unquote` are probably the
most important building blocks of macros in Elixir.

[Elixir's getting started guild]: http://elixir-lang.org/getting-started/meta/quote-and-unquote.html
