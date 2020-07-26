---
title: "Restore Gem to Original State after Bundle Open"
date: "2017-12-19"
---

When trying to understand how a gem works,

```
bundle open [gem]
```

can be a very useful command. But after finished debugging, logging and etc., it would be awesome to be able to restore the gem you've messed with to its original state. Thankfully there is a command for exactly that:

```
bundle exec gem pristine [gem]
```

Reference: [https://github.com/bundler/bundler-features/issues/5](https://github.com/bundler/bundler-features/issues/5)
