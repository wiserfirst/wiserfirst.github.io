---
title: "Reset Forgotten Hex Local Password"
date: "2019-08-03"
---

Hex is the package manager for the Erlang ecosystem. When you first install it with `mix local.hex` and authenticate with your hex.pm account, a local password is required. It'll be used when you publish/update a package on hex.pm. Since I had never done that until a few days ago, unsurprisingly my local password was forgotten.

There is a command `mix hex.user reset_password local` for updating your local password, but it requires you to enter your current local password. So that didn't help.

After some googling, I found out the local password is stored in `~/.hex/hex.config` file. Considering it's set during hex user authentication (`mix hex.user auth`), it occurred to me that deleting the config file and re-authenticating with hex.pm account might help. And it actually did work! I was able to set a new local password and publish [my first hex package](https://hex.pm/packages/leapyear), even though it's pretty much just for demonstration purpose.

Interested to learn more about hex? You might find [Become a Hex Power User](https://medium.com/@toddresudek/hex-power-user-deb608e60935) by Todd Resudek a good read.
