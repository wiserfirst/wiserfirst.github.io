---
title: "Reset Forgotten Hex Local Password"
date: "2019-08-05 10:00:00 +1000"
last_modified_at: 2021-05-19 10:38:00 +1000
tags: hex tiny-tips
header:
  image: /assets/images/2021-05-19/blue_flowers_1440_430.jpg
  image_description: "Blue flowers"
  teaser: /assets/images/2021-05-19/blue_flowers_1440_430.jpg
  overlay_image: /assets/images/2021-05-19/blue_flowers_1440_430.jpg
  overlay_filter: 0.3
  caption: >
    Image by [Alpine Light](https://unsplash.com/@western_skies)
    from [Unsplash](https://unsplash.com/photos/smBzN2gcqoM)
excerpt: Where there is a forgotten password, there is a way to reset it
---

Hex is the package manager for the Erlang ecosystem. When you first install it
with `mix local.hex` and authenticate with your hex.pm account, you are required
to create a local password. It'll be needed when you publish/update a package on
hex.pm. Since I had never done that until a few days ago, unsurprisingly my
local password was forgotten.

There is a command `mix hex.user reset_password local` for updating your local
password, but it requires you to enter your current local password. So that
didn't help.

After some googling, I found out the local password is stored in
`~/.hex/hex.config` file. Considering it's set during hex user authentication
(`mix hex.user auth`), it occurred to me that deleting the config file and
re-authenticating with hex.pm account might help. And it actually did! I was
able to set a new local password and publish [my first hex package], even though
it's pretty much just for demonstration purpose.

Interested to learn more about hex? You might find [Become a Hex Power User] by
Todd Resudek a good read.

[Become a Hex Power User]: https://medium.com/@toddresudek/hex-power-user-deb608e60935
[my first hex package]: https://hex.pm/packages/leapyear
