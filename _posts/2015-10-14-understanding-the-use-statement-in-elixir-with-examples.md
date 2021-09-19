---
title: "Understanding the Use Statement in Elixir with Examples"
date: "2015-10-14 10:00:00 +1100"
last_modified_at: 2021-09-18 11:35:00 +1000
tags: elixir use phoenix
header:
  image: /assets/images/2021-05-20/bottles_of_potion_1280_400.jpg
  image_description: "Bottles of Potion"
  teaser: /assets/images/2021-05-20/bottles_of_potion_1280_400.jpg
  overlay_image: /assets/images/2021-05-20/bottles_of_potion_1280_400.jpg
  overlay_filter: 0.3
  caption: >
    Image by [Jalyn Bryce](https://pixabay.com/users/jalynbryce-5426636/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=4387824)
    from [Pixabay](https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=4387824)
excerpt: >
  In order to read code better, one need to understand the building blocks of
  the language
---

When you `use` a module in Elixir, the `__using__/1` macro of that module is
called.

In the Hello example app from [Phoenix Guides][], the router is defined as a
module named `HelloPhoenix.Router` in `web/router.ex`. The first line of its
body looks like this:

```elixir
use HelloPhoenix.Web, :router
```

It is calling the `__using__/1` macro of `HelloPhoenix.Web` module, with a atom
`:router` as the parameter. If you open `web/web.ex`, where `HelloPhoenix.Web`
module is defined, you can find the macro near the bottom:

```elixir
@doc """
When used, dispatch to the appropriate controller/view/etc.
"""
defmacro __using__(which) when is_atom(which) do
  apply(__MODULE__, which, [])
end
```

`__MODULE__` is one of Elixir's read-only pseudo-variables. Similar to Erlang's
`?MODULE`, it expands to the current module's name at compile time, which in our
case is `HelloPhoenix.Web`. As for the `apply/3` function, according to [Elixir
documentation][apply docs], it has the following signature:

```elixir
apply(module, fun, args)
```

So in this case, the current module, an atom `:router` and an empty list are
bind to the `module`, `fun` and `args` parameters respectively. What the apply
function does is:

> Invokes the given fun from module with the array of arguments args. Inlined by
> the compiler.

That means a function named `router` in the current module will be called with
an empty list as the parameter. Let's look at the `router` function:

```elixir
def router do
  quote do
    use Phoenix.Router
  end
end
```

The code in a quote block will be turned it into its internal representation in
Elixir. You can find more about quoting in the [quote and unquote guide][]. Then
we have another round of `use`, and now the `__using__/1` macro of module
`Phoenix.Router` will be called with no parameter, which defaults to an empty
list.

[Phoenix Guides]: https://hexdocs.pm/phoenix/up_and_running.html
[apply docs]: https://hexdocs.pm/elixir/Kernel.html#apply/3
[quote and unquote guide]: http://elixir-lang.org/getting-started/meta/quote-and-unquote.html
