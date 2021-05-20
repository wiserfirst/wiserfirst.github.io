---
title: "Git Tip: Prune Stale Remote References"
date: 2020-10-31 18:20:00 +1000
last_modified_at: 2021-05-16 18:15:00 +1000
tags: tiny-tips git
header:
  image: /assets/images/2021-05-16/git_1440_480.jpg
  image_description: "A Git GUI client"
  teaser: /assets/images/2021-05-16/git_1440_480.jpg
  overlay_image: /assets/images/2021-05-16/git_1440_480.jpg
  overlay_filter: 0.75
  caption: >
    Image by [Yancy Min](https://unsplash.com/@yancymin?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/s/photos/git?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
excerpt: A Git tip that I didn't know before and I find it very useful at times
---

When a colleague pushes a new branch to Github, we can run the following to get
it locally:

```bash
git pull # or git fetch
git checkout <branch-name>
```

This works because git uses what's called "remote references" to keep track of
the last known state of remote branches, which are essentially read-only
bookmarks. In this case, `git pull` would create a new remote reference for the
new remote branch apart from updating existing remote references. Then `git
checkout ...` would create a new local branch that tracks the new remote branch
and switch to it.

That's all well and good until there are too many branches in the codebase,
which is not at all uncommon when working in a reasonably sized team. Git
automatically creates remote references for all known remote branches, but it
doesn't automatically remove stale remote references when the remote branches
are deleted. This annoys me because the stale remote references might mess with
my auto-completion for branch names. After some Googling, I managed to find a
way to remove them for the default remote connection `origin`:

```bash
git remote prune origin
```

Also the following command lists remote references:

```bash
git remote show origin
```

After sharing my findings with my colleagues, they pointed out that passing the
`--prune` option to `git pull` or `git fetch` would do the trick as well. As
mentioned in this nice [tutorial for git prune][], the following:

```bash
git fetch --prune
```

is the same as:

```bash
git fetch --all && git remote prune
```

[tutorial for git prune]: https://www.atlassian.com/git/tutorials/git-prune
