---
title: "Updating Multiple Text Files in Terminal with Regular Expression"
date: "2013-02-02 10:00:00 +0800"
tags: cygwin linux regex
---

I am trying to do this in Cygwin on windows, but I think it should work just
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
