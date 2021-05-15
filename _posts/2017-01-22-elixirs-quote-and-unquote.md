---
title: "Elixir's quote and unquote"
date: "2017-01-22 10:00:00 +1100"
tags: elixir
---

For a very long time, I had a hard time trying to understand how macros work in
Elixir. Since I don't have any Lisp background, that's a whole new concept for
me.

But yesterday, after reading the relevant sections in [Elixir's getting started
guild](http://elixir-lang.org/getting-started/meta/quote-and-unquote.html), I
suddenly realised how `quote` and `unquote` work. First of all, Elixir
expression is internally represented as a tuple with three elements, which is
Elixir's version of the Abstract Syntax Tree (AST). `quote` can give you the AST
representation of a piece of code, so that you can manipulate later. `unquote`
only works inside `quote` and it can evaluate an expression and then inject the
resulting value into the AST. `quote` and `unquote` are probably the most
important building blocks of macros in Elixir.
