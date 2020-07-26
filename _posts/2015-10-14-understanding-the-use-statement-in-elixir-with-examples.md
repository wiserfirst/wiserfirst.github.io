---
title: "Understanding the Use Statement in Elixir with Examples"
date: "2015-10-14"
tags: elixir use
---

When you `use` a module in Elixir, the `__using__/1` macro of that module is called.

In the Hello example app from [Phoenix Guides](https://hexdocs.pm/phoenix/up_and_running.html), the router is defined as a module named `HelloPhoenix.Router` in `web/router.ex`. The first line of its body looks like this:

```elixir
use HelloPhoenix.Web, :router
```

It is calling the `__using__/1` macro of `HelloPhoenix.Web` module, with a atom `:router` as the parameter. If you open `web/web.ex`, where `HelloPhoenix.Web` module is defined, you can find the macro near the bottom:

```elixir
@doc """
When used, dispatch to the appropriate controller/view/etc.
"""
defmacro __using__(which) when is_atom(which) do
  apply(__MODULE__, which, [])
end
```

`__MODULE__` is one of Elixir's read-only pseudo-variables. Similar to Erlang's `?MODULE`, it expands to the current module's name at compile time, which in our case is `HelloPhoenix.Web`. As for the `apply/3` function, according to [Elixir document](https://hexdocs.pm/elixir/Kernel.html#apply/3), it has the following signature:

```elixir
apply(module, fun, args)
```

So in this case, the current module, an atom `:router` and an empty list are bind to the `module`, `fun` and `args` parameters respectively. What the apply function do is:

> Invokes the given fun from module with the array of arguments args. Inlined by the compiler.

That means a function named `router` in the current module will be called with an empty list as the parameter. Let's look at the `router` function:

```elixir
def router do
  quote do
    use Phoenix.Router
  end
end
```

The code in a quote block will be turned it into its internal representation in Elixir. You can find more about quoting [here](http://elixir-lang.org/getting-started/meta/quote-and-unquote.html). Then we have another round of `use`, and now the `__using__/1` macro of module `Phoenix.Router` will be called with no parameter (which defaults to an empty list).
