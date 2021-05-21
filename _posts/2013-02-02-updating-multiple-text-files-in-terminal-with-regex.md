---
title: "Updating Multiple Text Files in Terminal with Regular Expression"
date: "2013-02-02 10:00:00 +0800"
last_modified_at: 2021-05-21 15:36:00 +1000
tags: cygwin linux regex sed
header:
  image: /assets/images/2021-05-21/scenic_route_1280_400.jpg
  image_description: "Scenic Route"
  teaser: /assets/images/2021-05-21/scenic_route_1280_400.jpg
  overlay_image: /assets/images/2021-05-21/scenic_route_1280_400.jpg
  overlay_filter: 0.2
  caption: >
    Image by [v2osk](https://unsplash.com/@v2osk)
    from [Unsplash](https://unsplash.com/photos/1Z2niiBPg5A)
excerpt: >
  It is art of Unix for multiple cli tools to work seamlessly in the terminal
---

I am trying to do this in Cygwin on Windows, but I think it should work just
fine on Linux. The steps are as listed below.

Find the files needed to be updated (here I want to find all `cshtml` files
containing a certain pattern in its content):

```bash
find . -name "*cshtml" -exec grep -l "old-pattern" {} \;
```

Sometimes there are white spaces in filenames, so pipe the output to sed to
provide valid filenames for later use:

```bash
sed -e 's/\s/\\ /g'
```

Last, do the actual replacement by sed:

```bash
sed -i 's/old-pattern/new-pattern/g'
```

The full command is:

```bash
find . -name "*cshtml" -exec grep -l "old-pattern" {} \; | sed -e 's/\s/\\ /g' | sed -i 's/old-pattern/new-pattern/g'
```

Although step one may not seem necessary, it prevents accidentally changing
files that doesn't contain the target pattern.
