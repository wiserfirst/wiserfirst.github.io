---
title: "Restore Gem to Original State after Bundle Open"
date: "2017-12-19 10:00:00 +1100"
last_modified_at: 2021-05-19 16:45:00 +1000
tags: ruby bundle gem tiny-tips
header:
  image: /assets/images/2021-05-19/gemstone_1440_420.jpg
  image_description: "Red Gemstone"
  teaser: /assets/images/2021-05-19/gemstone_1440_420.jpg
  overlay_image: /assets/images/2021-05-19/gemstone_1440_420.jpg
  overlay_filter: 0.1
  caption: >
    Image by [Joshua Fuller](https://unsplash.com/@joshuafuller)
    from [Unsplash](https://unsplash.com/photos/p8w7krXVY1k)
excerpt: Experiment with Ruby Gems safely without messing it up
---

When trying to understand how a gem works,

```bash
bundle open [gem]
```

can be a very useful command. But after finished debugging, logging and etc., it
would be awesome to be able to restore the gem you've messed with to its
original state. Thankfully there is a command for exactly that:

```bash
bundle exec gem pristine [gem]
```

Reference:
[https://github.com/bundler/bundler-features/issues/5](https://github.com/bundler/bundler-features/issues/5)
