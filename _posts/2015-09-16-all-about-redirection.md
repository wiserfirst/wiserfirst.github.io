---
title: "All about Redirection"
date: "2015-09-16"
tags: linux redirection
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
