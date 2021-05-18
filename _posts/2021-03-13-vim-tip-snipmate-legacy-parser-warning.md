---
title: "Vim Tip: Fix Legacy Parser Warning for snipMate"
date: 2021-03-13 10:40:00 +1100
last_modified_at: 2021-05-16 17:35:00 +1000
tags: tiny-tips vim
header:
  image: /assets/images/2021-05-16/vim_1440_400.jpg
  image_description: "Coding with Vim"
  teaser: /assets/images/2021-05-16/vim_1440_400.jpg
  overlay_image: /assets/images/2021-05-16/vim_1440_400.jpg
  overlay_filter: 0.6
  caption: Coding with Vim by Qing Wu
excerpt: A quick tip for resolving a warning message from snipMate
---

If you use both Vim and snipMate, and upgraded snipMate to the latest version
recently, you might encounter a warning:

> The legacy SnipMate parser is deprecated. Please see :h SnipMate-deprecate

If you follow the instruction and run `:h SnipMate-deprecate`, you'll see the
following in a help window:

> The legacy parser, version 0, is deprecated. It is currently still the default
> parser, but that will be changing. NOTE that switching which parser you use
> could require changes to your snippets--see the previous section.
>
> To continue using the old parser, set g:snipMate.snippet_version (see
> |SnipMate-options|) to 0 in your |vimrc|.
>
> Setting g:snipMate.snippet_version to either 0 or 1 will remove the start up
> message. One way this can be done--to use the new parser--is as follows:
>
> let g:snipMate = { 'snippet_version' : 1 }

Basically there is a new parser in snipMate, but the deprecated legacy parser
is still the default, which would cause this warning. Explicitly setting the
parser version to either 0 for the old parser or 1 for the new parser would
remove this start up warning message.

There doesn't seem to be a reason not to use the new parser, so I just added the
following in my `.vimrc`:

```vim
    let g:snipMate = { 'snippet_version' : 1 }
```

Now the annoying warning upon starting Vim is gone :tada:
