---
title: "A Different Perspective for Elixir Macros"
date: "2022-03-21 11:48:00 +1100"
tags: elixir macro tiny-tips
header:
  image: /assets/images/2022-03-21/australia_nature_1440_420.jpg
  image_description: "Australian Outback"
  teaser: /assets/images/2022-03-21/australia_nature_1440_420.jpg
  overlay_image: /assets/images/2022-03-21/australia_nature_1440_420.jpg
  overlay_filter: 0.3
  caption: >
    Image by [Dylan Shaw](https://unsplash.com/@dylanshaw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
excerpt: Some random thoughts about Elixir Macros
---

In Elixir, macros are a way of metaprogramming, which is sometimes explained as
something like "using code to write code". While offering good intuition on what
metaprogramming is about, it's not very accurate, because it doesn't actually
write code.

When trying to understand macros, I use the slightly different mental model: a
macro is like a template with a name that can optionally have parameters; when
the name is used, it's substituted by the template with "values" of the
arguments injected.

Sorry if it didn't make it better. I'll try to explain what do I mean by that.
But let's first review how C macros work.

## C Macos

Before actually compiling a C program, the C compiler will use the C
preprocessor to transform the program, which is also referred to as
preprocessing. One of the things that happens in this preprocessing step is
macro expansion.

In GNU's online documentation for [the C Preprocessor][gnu-cpp], a macro is
defined as following:

> A macro is a fragment of code which has been given a name. Whenever the name
> is used, it is replaced by the contents of the macro.

You can define a macro like this:

```c
#define DOUBLE(x) (2 * x)
```

> NOTE: by convention macro names in C use uppercase.

And then use it as below:

```c
DOUBLE(5)
```

During preprocessing, the preprocessor will replace it with `(2 * x)`. The
compiler would just see `(2 * x)` as if you wrote it in stead of `DOUBLE(5)` in
the first place.

So a macro in C allows us to define a fragment of code that can have parameters,
and when it's used the macro name would be replaced by the code fragment we
defined with arguments interpolated.

It's worth noting that since this happens before compilation, the program is
still just a piece of text, so both arguments interpolation and macro expansion
are just literal text substitution.

How does this relate to Elixir's macros? Well macro expansion in Elixir is
definitely not text substitution, but it's still substitution, just happens at
a higher level.

## The Abstract Syntax Tree (AST)

Most programming languages have the Abstract Syntax Tree (AST), which is a tree
structure the compiler builds from the source code before turning it into either
machine code or byte code.

In most languages, the AST is not exposed to us developers and we can get our
code working without worrying about the AST or even knowing about it.

In the case of Elixir, the compiler give us access to the AST. This comes with
great power and allows us to do many things that aren't possible in other
languages, creating macros among them.

You can get the AST for a piece of code by using `quote`, for example:

```elixir
iex(1)> quote do
...(1)> 1 + 2
...(1)> end
{:+, [context: Elixir, import: Kernel], [1, 2]}
```

This is probably the simplest form, but in general Elixir's AST is represented
as a three elements tuple. When the expression is more complex, its corresponding
AST is usually deeply nested.

In Elixir, the AST is also known as quoted expressions.

For more details on working with quoted expressions, please refer to offical
[Quote and unquote][quote-unquote] guide.

## Macros in Elixir

One thing to remember about macros in Elixir is that they receive AST as
arguments and return AST.

You can define a macro with `defmacro`:

```elixir
defmodule MyIf do
  defmacro if(condition, do: action) do
    quote do
      case unquote(condition) do
        x when x in [false, nil] -> nil
        _ -> unquote(action)
      end
    end
  end
end
```

Then you can use it by:

```elixir
require MyIf

MyIf.if true, do: IO.puts("Hello world!")

# or

MyIf.if false, do: IO.puts("Will not print anything")
```

## Mental models about Macros

### Tree Metaphor

To understand how macros work in general, I often use the tree metaphor. The
entire program is just a big tree containing data and expressions as nodes, some
of which are macro usages. This is literally correct with Elixir, because the
compiler do convert the program into a big abstract syntax tree in the form of a
deeply nested three elements tuple.

Defining a macro is like creating a template in AST or say a sub-tree. If there
are arguments, they can be injected to the sub-tree with `unquote`.

During macro expansion, the Elixir compiler will replace each macro usage node
with the AST sub-tree returned by its macro definition with the arguments
injected. Because macros can be used inside another macro, macro expansion will
happen repeatedly until there are no more macros.

If we compare Elixir macros with C macros, we can see that they both offer a way
to substitute an expression with a template. The difference is that in C we
define the template as text and replaced as text, whereas in Elixir, the
template is defined as a piece of AST and the substitution happens at the AST
level as well.

### Copy-Paste Metaphor

To figure out what a particular macro does, I usually think of it as copying
what the macro definition has and pasting it where the macro is being used. For
unquoted arguments, mentally replace them with the corresponding values passed
in.

When the macro is more complex, this might not work, but it should still set one
on the right path in understanding the macro.

## Summary

Macros are hard and they can be daunting even for experienced developers.

In this short post, I tried to offer a different perspective in understanding
macros in Elixir.

It would fantastic if this makes it slightly easier for someone to learn about
macros.

If you'd like to learn more about Elixir macros, check out [Saša Jurić][sasa]'s
great blog post series [Understanding Elixir Macros][understanding-macros] and
[Chris Mccord][chris-mccord]'s book [Metaprogramming Elixir][meta-elixir].

[chris-mccord]: https://twitter.com/chris_mccord
[gnu-cpp]: https://gcc.gnu.org/onlinedocs/cpp/Macros.html
[meta-elixir]: https://pragprog.com/titles/cmelixir/metaprogramming-elixir/
[quote-unquote]: https://elixir-lang.org/getting-started/meta/quote-and-unquote.html
[sasa]: https://twitter.com/sasajuric
[understanding-macros]: https://www.theerlangelist.com/article/macros_1
