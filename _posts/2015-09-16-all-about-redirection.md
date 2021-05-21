---
title: "All about Redirection"
date: "2015-09-16 10:00:00 +1000"
last_modified_at: 2021-05-21 12:26:00 +1000
tags: linux redirection
header:
  image: /assets/images/2021-05-21/path_in_forest_1280_400.jpg
  image_description: "Path in Forest"
  teaser: /assets/images/2021-05-21/path_in_forest_1280_400.jpg
  overlay_image: /assets/images/2021-05-21/path_in_forest_1280_400.jpg
  overlay_filter: 0.3
  caption: >
    Image by [Zack Silver](https://unsplash.com/@zack_silver)
    from [Unsplash](https://unsplash.com/photos/5XiJQIvs6AY)
excerpt: A basic introduction to redirections on Linux
---

There are three special file descriptors: stdin, stdout and stderr (std stands
for standard), which are defined as file descriptor 0, 1 and 2. You can do
different types of redirections with them.

* redirect stdout to a file

```bash
ls -la > la.log
```

* redirect stderr to a file

```bash
ack 'pattern' 2> ack-error.log
```

* redirect stdout to stderr

```bash
ack 'pattern' 1>&2
```

* redirect stderr to stdout

```bash
ack 'pattern' 2>&1
```

* redirect stderr and stdout to a file

```bash
ack 'pattern' &> /dev/null
```

## References

1. [All about redirection from TLDP](http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-3.html)
2. [Linux file descriptor](http://stackoverflow.com/questions/22367920/is-it-possible-that-linux-file-descriptor-0-1-2-not-for-stdin-stdout-and-stderr)
