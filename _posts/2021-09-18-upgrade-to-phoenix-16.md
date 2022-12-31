---
title: "Journey of upgrading an app to Phoenix 1.6"
date: "2021-09-19 12:25:00 +1000"
last_modified_at: 2021-09-28 12:05:00 +1000
tags: elixir esbuild phoenix webpack
header:
  image: /assets/images/2021-09-19/elixir_code_1440_420.jpg
  image_description: "Code with Elixir and Phoenix"
  teaser: /assets/images/2021-09-19/elixir_code_1440_420.jpg
  overlay_image: /assets/images/2021-09-19/elixir_code_1440_420.jpg
  overlay_filter: 0.3
  caption: Code with Elixir and Phoenix
excerpt: Say goodbye to webpack and Node in your Phoenix applications
---

Phoenix 1.6 RC0 was released just over three weeks ago and I'm really excited
about it. Because it provides the option to replace webpack with esbuild, so
that we no longer need Node for asset building.

True that it's just the first release candidate, but we are still one step
closer to the formal release.

> **Update (28 September 2021):**
> [Phoenix 1.6.0][phx1.6.0] was released three days ago on 25 September, so now
> we do have our formal release

Last week, I managed to upgrade my little side project [Rubik's Cube Algorithms
Trainer][cube trainer] to Phoenix 1.6 and I'll share my journey in this post.
For the most part, I was following the [Phoenix 1.5.x to 1.6 upgrade
instructions][phx 16 upgrade guide] by [Chris McCord][].

If you prefer watching a video than reading, I also did a talk about it at
[Elixir Sydney September 2021 meetup][elixir sydney sept 2021] and the recording
is on [Youtube][talk recording].

## Update dependencies in Mixfile

First we need to update the dependencies in the `mix.exs` file:

```elixir
def deps do
  [
    {:phoenix, "~> 1.6.0"},
    {:phoenix_html, "~> 3.0"},
    {:phoenix_live_view, "~> 0.16.0"},
    {:phoenix_live_dashboard, "~> 0.5"},
    {:telemetry_metrics, "~> 0.6"},
    {:telemetry_poller, "~> 0.5"},
    ...
  ]
end
```

Then run `mix deps.get` to install the new dependencies.

Two thing to note here:

* ~~For `phoenix`, the `override: true` option is important, because Phoenix 1.6
  is still in RC~~ (This is no longer the case, since Phoenix 1.6.0 has been
  released)
* If you want to use the new `HEEx` templates, add `phoenix_live_view` even if you
  don't actually use live view

## esbuild for Javascript and CSS bundling (optional)

Next step is to use esbuild for Javascript and CSS bundling. This is an optional
step in upgrading to Phoenix 1.6, but it is what I'm all excited about, so it's
not optional for me :smirk:

### Phoenix asset pipeline overview

Before jumping into replacing webpack with esbuild, it's worth having a quick
review of the existing Phoenix asset pipeline:

* All static assets are served from `priv/static`
* Javascript: webpack bundles from `assets/js` to `priv/static/js`
* CSS: webpack bundles from `assets/css` to `priv/static/css`
* Images and other assets: webpack copies from `assets/static` -> `priv/static`

Now with the new asset pipeline based on esbuild, all static assets are still
served from `priv/static` directory, so the first item stays the same.

With webpack gone, the other three obviously will change. For JS and CSS,
esbuild will handle them; but we do need to deal with images and other assets
separately.

Alright, let's dive into how to make those changes.

### Remove webpack config and related node files

First we need to remove webpack config and related node files:

```sh
$ cd assets
$ rm webpack.config.js package.json
     package-lock.json .babelrc
$ rm -rf node_modules
```

If you use yarn, remove `yarn.lock` instead of `package-lock.json`.

### Add esbuild in deps

Then add `esbuild` as a dependency:

```elixir
def deps do
  [
    ...
    {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
  ]
end
```

### Configure esbuild

Next add configuration for esbuild in `config/config.exs`:

```elixir
# config/config.exs
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
```

> Note: here we are providing the relative path from `config` to `assets` with
> the `:cd` option, so that the esbuild command can be run in the `assets`
> directory. Given that, if you have a umbrella app, the path should be
> something like `../apps/your_web_app/assets`.

### Update watcher in endpoint configuration

In your `config/dev.exs` file, there should be a node watcher that uses webpack
under the endpoint configuration. We want to replace that one with the esbuild
watcher below:

```elixir
# config/dev.exs
config :your_web_app, YourWebApp.Endpoint,
  ...,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ]
```

> Note: this is for local development only.

### Move images and other assets

Then we deal with images.

The following is not mentioned in the Phoenix 1.6 upgrade instructions, but I
found [José Valim's recommendation][jose answer] in a reddit thread.

He recommends to move everything in `assets/static` to `priv/static`; stop
ignoring `priv/static` and commit it in version control; also ignore
`priv/static/assets` instead, since that's where esbuild puts the compiled
Javascript and CSS files.

### Add `assets.deploy` mix alias

Then we add a new mix alias for deployment:

```elixir
defp aliases do
  [
    ...,
    "assets.deploy": ["esbuild default --minify", "phx.digest"]
  ]
end
```

As we can see, it has two parts:

1. esbuild will create minified Javascript and CSS and put them in
   `priv/static/assets`
2. the `phx.digest` task will add digests for all static assets `priv/static`

This is for deployment, so we only need to run it on build servers. For
example when deploying to Heroku or the like, make sure it is run.

If you did run it locally, it would generate a whole bunch of digested assets.
Since we no longer ignore `priv/static`, they would show up when you run `git
status` for example and could be annoying.

We can remove them with the following command:

```sh
mix phx.digest.clean --all
```

### Update layouts

As mentioned in the last section, esbuild puts compiled Javascript and CSS in
`priv/static/assets` directory, so we need to update the references to them in
the layouts, usually in `app.html.eex` or `root.html.eex`:

```elixir
# update
Routes.static_path(@conn, "/js/app.js")
Routes.static_path(@conn, "/css/app.css")
# to
Routes.static_path(@conn, "/assets/app.js")
Routes.static_path(@conn, "/assets/app.css")
```

### Update `Plug.Static` configuration

Last step for the new asset pipeline is to update configuration for
`Plug.Static`.

We need to add the new `assets` directory in the `:only` option and also
remove `js` and `css` from there since we no longer have them.

```elixir
plug Plug.Static,
  at: "/",
  from: :my_app,
  gzip: false,
  only: ~w(assets fonts images favicon.ico robots.txt)
```

With the changes above, the new asset pipeline should be working, which means we
are officially free of webpack and node in our Phoenix application :tada:

## Migrate to `HEEx` templates (optional)

With Phoenix 1.6 the leex templates are deprecated and there is a new `HEEx`
engine, which is being used in all the HTML files generated by `phx.new`,
`phx.gen.html` etc.

It is HTML-aware and it enforces valid markup. It's also more strict for
the Elixir expressions inside tags.

In order to use it in an existing Phoenix project, make sure `phoenix_live_view`
is added as a dependency, because the `HEEx` engine is part of
`phoenix_live_view`.

Then rename all the existing `.html.eex` and `.html.leex` templates to
`.html.heex`

### Update Elixir expressions

When Elixir expressions appear in the body of HTML tags, `HEEx` templates use
`<%= ... %>` for interpolation just like `EEx` templates.

So code in the following example stays the same:

```elixir
<h2>Hello <%= @name %></h2>

<%= Enum.map(names, fn name -> %>
  <li><%= name %></li>
<% end) %>
```

But when an Elixir expression is used inside a tag, as the attribute value for
example:

```elixir
<div id="<%= @id %>">
```

It needs to be updated to:

```elixir
<div id={@id}>
```

Notice the `EEx` interpolation is inside double quotes, the curly braces are
not. So the Elixir expression has to serve as the whole attribute value, not
part of it.

With `EEx`, the Elixir expression can serve as part of the attribute value:

```elixir
<a href="/prefix/<%= @item.text %>">
```

In situations like this, directly replacing it with a pair of curly braces won't
work.

```elixir
# this doesn't work
<a href="/prefix/{@item.text}">
```

One way I could think of is to interpolate the original Elixir term in a string
and then put that string in a pair of curly braces like the following:

```elixir
<a href={"/prefix/#{@item.text}"}>
```

Now the resulting string is the Elixir expression and it serves as the whole
attribute value, so this works.

After making those changes, the new `HEEx` templates should be working.

## Deployment

There are changes to the deployment process as well and I'll cover that for
Gigalixir, since that's where my app is deployed to. But if you use Heroku, the
changes should be fairly similar.

Since we no longer use webpack and node to build assets,
`phoenix_static_buildpack` is not necessary any more. We can just get rid of it.

Also we need to make sure the `assets.deploy` task is run during deployment.
We can use `hook_post_compile` in Elixir buildpack for that.

Just add this line in your `elixir_buildpack.config`:

```elixir
hook_post_compile="eval mix assets.deploy && rm -f _build/esbuild"
```

With those two changes, my app can be deployed to Gigalixir without any issue.

If you'd like to deploy a new Phoenix 1.6 app to Gigalixir, check out the [full
guide][gigalixir guide].

## New generators

I'd like to quickly mention that Phoenix 1.6 also ships with two new generators:

* `phx.gen.auth` generates a complete authentication solution for your
  application
* `phx.gen.notifier` generates a notifier for sending emails

In my little app, I didn't need to use them. But if you do need an
authentication solution or a notifier, check them out.

## Summary

The release of Phoenix 1.6 is quite exciting, because by default webpack and
node is replaced by esbuild. Now we can focus on developing the application in
Elixir and Phoenix, without wasting time on breaking changes and nonsense
security alerts in node dependencies.

In this post, I walked through how I upgraded my humble little Phoenix app to
1.6, with a focus on updating the asset pipeline to use esbuild and migrating to
`HEEx` templates. Hope this helps someone who's trying to do the same.

Phoenix 1.6 do have other new features that are not covered in this post. For
those, make sure to check out the [release note][phx 16 release note].

[Chris McCord]: https://twitter.com/chris_mccord
[cube trainer]: https://github.com/wiserfirst/rubiks_cube_algs_trainer
[elixir sydney sept 2021]: https://www.meetup.com/elixir-sydney/events/gztkjsyccmbtb/
[gigalixir guide]: https://hexdocs.pm/phoenix/1.6.0-rc.0/gigalixir.html
[jose answer]: https://www.reddit.com/r/elixir/comments/p9t68v/with_the_new_esbuild_transition_what_do_you_use/ha0cskv?context=3
[phx 16 release note]: https://www.phoenixframework.org/
[phx 16 upgrade guide]: https://gist.github.com/chrismccord/2ab350f154235ad4a4d0f4de6decba7b
[phx1.6.0]: https://github.com/phoenixframework/phoenix/releases/tag/v1.6.0
[talk recording]: https://www.youtube.com/watch?v=NR_Jk3yUEqc
