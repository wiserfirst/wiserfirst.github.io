---
title: "Understanding Application Configuration in Elixir"
date: 2024-04-18 22:19:00 +1000
tags: elixir configuration distillery release
header:
  image: /assets/images/2024-04-19/banff_canada.jpg
  image_description: "Banff National Park"
  teaser: /assets/images/2024-04-19/banff_canada.jpg
  overlay_image: /assets/images/2024-04-19/banff_canada.jpg
  overlay_filter: 0.2
  caption: >
    Photo by [Luca Bravo](https://unsplash.com/@lucabravo)
    on [Unsplash](https://unsplash.com/photos/banff-national-park-canada-oV4bR3YoR_s)
excerpt: Application configuration can get interesting in Elixir. Let's dig ...
---

Recently I started working on an Elixir project, which was a breath of fresh
air, especially after two years mainly working with Node. However, it didn't
take long before I stumbled upon something that puzzled me.

In the production configuration files of this project, we have environment
variable names interpolated in strings as follows:

```elixir
# config/prod.exs
config :my_app, MyApp.Repo,
  hostname: "${DATABASE_HOSTNAME}",
  username: "${DATABASE_USERNAME}",
  ...
```

Clearly this approach wouldn't work for the `:dev` environment, where we would
typically see something like this:

```elixir
# config/dev.exs
config :my_app, MyApp.Repo,
  hostname: System.get_env("DATABASE_HOSTNAME"),
  username: System.get_env("DATABASE_USERNAME"),
  ...
```

However, I also knew that the interpolation syntax did work for us in
production. This made me curious: How exactly does this work? It was time for
some investigation.

## The How

After consulting with our old friend Google and chatting with our new friend
GPT-4, I learnt that this peculiar method of setting configuration values from
environment variables is facilitated by Distillery, the tool we use for building
releases.

For this functionality to be enabled, the environment variable `REPLACE_OS_VARS`
must be set to `true`. And then Distillery would replace environment variables
with their actual values upon encountering interpolation syntax, such as
`"${DATABASE_USERNAME}"`, in the configuration files.

As a matter of fact, when it comes to handling application configuration,
Distillery supports more than simple variable interpolation. It also supports
Config Providers, which are custom modules capable of dynamically generating
configuration at the start of your application. For further details, please
refer to the relevant section in [Distillery documentation][distillery-doc].

## The Why

While it's enlightening to learn how it works, I kept wondering: why does
Distillery offer support for both interpolation and Config Providers? Isn't
`System.get_env` good enough for this purpose? As it turns out, although
`System.get_env` is quite effective for the `:dev` environment, it can be
inadequate for the production environment in many cases.

To grasp this, we need to take a step back and have a quick review of how Elixir
the language works. Elixir is a compiled language. When you execute `mix
compile`, the Elixir compiler transforms your project into Erlang bytecode. This
bytecode then runs on the Erlang Virtual Machine, commonly known as
Bogdan/Björn's Erlang Abstract Machine (BEAM).

The configuration files and code that are outside of function bodies within a
module are evaluated at compile-time. Thus, if you use
`System.get_env("DATABASE_HOSTNAME")` within a configuration file, it's
evaluated during the compilation process. This means the value of the
environment variable `DATABASE_HOSTNAME` is then captured and embedded in the
application as a static value.

For production configurations, the goal is generally to dynamically capture
runtime environment variables, rather than to embedding those from the build
server as static values. Apparently using `System.get_env` wouldn't achieve this
purpose.

That is precisely why Distillery supports both the interpolation syntax and
Config Providers, enabling dynamic configuration value setting from the runtime
environment of the application.

It's noteworthy that with version 1.9, Elixir introduced built-in support for
[releases][mix-release] as well, which includes a novel approach to runtime
configuration. This was achieved through the introduction of a new configuration
file `config/releases.exs`, which is executed every time a release starts. Then
in Elixir 1.11, another configuration file `config/runtime.exs` was introduced,
which is essentially a superior version of `config/releases.exs`. For more
details on these developments, please consult to the [relevant
documentation][elixir-1-11-change].

## Summary

In this post, I shared my initial confusion about the interpolation syntax
`"${DATABASE_HOSTNAME}"` in our production configuration files, followed by an
exploration into understanding how it works and why is it necessary for runtime
configuration. As always, my aim is to provide a reference for my further self
and perhaps assist others along their journey.

[distillery-doc]: https://hexdocs.pm/distillery/config/runtime.html
[elixir-1-11-change]: https://hexdocs.pm/elixir/1.11.0/changelog.html#config-runtime-exs-and-mix-app-config
[mix-release]: https://hexdocs.pm/mix/Mix.Tasks.Release.html
