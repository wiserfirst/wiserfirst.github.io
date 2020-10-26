---
title: "Migrating Blog to Jekyll"
date: 2020-10-26 15:31:00 +1000
tags: jekyll blog
---

Back in 2010, I started blogging on [WordPress]. The reason was simple, I
thought since it is the world's most popular blogging system, it should offer
reasonably good user experience. But to my surprise, The UI wasn't that great
especially for technical posts with code snippets. Having done no web
development at all back then, I just had to cope with it.

Fast forward to 2012, I started doing web development with ASP.NET/C#. My former
colleagues Yijun Xu and Jianguo Ning at the time were creating their blog sites
with [Jekyll] + [Octopress] and hosted on [Github Pages] under custom domains.
So with their help, I managed to do the same. I really liked the result, because
for me writing markdown felt more in control than fiddling with WordPress'
WYSIWYG interface. My old Jekyll blog was using a theme named [Scribble]. I
liked the fact that it was a fairly minimalist theme, but there were things I
had hoped to be different. For example, when viewed on a modern computer, the
viewing area was too narrow. While syntax highlighting for code snippets was
possible, the color schema wasn't the best. Having said all that though, it was
probably the best I could have done. I was still new as a web developer by then
and my frontend skills are fairly limited, so designing or customising a Jekyll
theme was too far-fetched for me.

After not blogging for the whole 2016, I started writing super short posts on
[Medium] in early 2017, because those are more approachable than longer form
articles. I was quite impressed by Medium's editing interface, which is a fine
balance between markdown and WYSIWYG and the published articles look gorgeous as
well. So I was happy with Medium for a few years, until they started to enforce
what they call a "[metered paywall]". Of course there was a rational behind the
[Medium Model] and to be honest, that was a nice idea, but still I wasn't a fan.
I write to share what I've learnt and I want my writings freely available for
everyone who's interested. So naturally any form of paywalls are at odds with my
purpose for writings.

A few months ago, I finally decided 2020 is the year to stop putting up with the
platform with a paywall and to migrate my personal blog back to Jekyll.
Apparently Jekyll has improved massively over the past eight years in terms of
user experience. Kudos to the [Jekyll team] :+1:! Also I received lots of help
from [Paul] and the [source for his blog] at [paulfioravanti.com] was a great
resource to learn from. I ended up picking the same theme [Minimal Mistakes],
but chose the dark skin because I like dark mode for everything. Since I got
help again, setting up the blog itself was a pleasant task.

## Content Migration

Because of the phases of my blogging journey, I have content in three different
forms, which means I'll need to migrate them in different ways too.

### WordPress

Posts in WordPress can be exported in XML format and then there is a node tool
called [wordpress-export-to-markdown] that can help convert them into markdown.

First login to the WordPress admin console and navigate to the "Export Content"
page via Tools -> Export . Then hitting the "Export all" button should get all
the posts in WordPress exported in a single XML file.

Next run `wordpress-export-to-markdown` with npx to convert the posts from XML
into markdown:

```bash
npx wordpress-export-to-markdown --input=path-to-your-export-file.xml
```

Or another option is to clone the repository and run it locally, which makes
repeated runs much faster:

```bash
git clone git@github.com:lonekorean/wordpress-export-to-markdown.git
cd wordpress-export-to-markdown
npm install
node index.js
```

The nice thing about this tool is by default it starts in wizard mode and asks
about any options not provided on the command line. To learn more about
available options, head over to [its Github repository]. Also [How To Convert
WordPress To Markdown] by Kev Quirk covers converting WordPress to markdown in
great details. You might want to check it out.

### Jekyll

For posts from my old Jekyll blog, it should have been straightforward because
they were originally written in markdown already. But regrettably for some
reason I only put the generated site in the blog repository on Github without
the markdown files, so the HTML files were what I had to work with. That was
definitely more work than if I could just copy over the original markdown files,
but I found an online tool called [Turndown] to convert HTML to Markdown, which
made working on this much more tolerable. It also offer options to choose
heading style, code block style and etc., which I found quite handy.

For each of my old Jekyll posts, I had to paste in the HTML source and copy the
markdown output into a new file. That was quite repetitive for sure, but since
there was only less than ten posts in this category, it wasn't too bad. This
time around, I wouldn't make the same mistake. The source of my blog is in [this
repository]. Hopefully open-soucing the blog itself would make the life of
future me a bit easier and might even help others too.

### Medium

Lastly it comes to migrating my posts in Medium and for that there is an npm
package named `mediumexporter`. First install it with

```bash
npm install -g mediumexporter
```

Then run it with

```bash
mediumexporter https://url-to-the-medium-post-to-export > exported_post.md
```

Similar to Turndown, I had to go through all my Medium posts one by one with
`mediumexporter`. Again there was less than ten, so it was okay.

If you'd like more details about exporting Medium posts to markdown, check out
[Export your Medium posts to Markdown].

## Content Adjustment

After getting the content as markdown from the three sources, I still need to
make various adjustments.

### Front Matter

Most posts exported from the above tools do not include Jekyll front matter and
even when front matter is included, it doesn't have the relevant tags. So I'd
like to add front matter with title, date and tags to all posts, which would
look like the following:

```markdown
---
title: "Understanding the Use Statement in Elixir with Examples"
date: "2015-10-14"
tags: elixir use
---
```

### Style Consistency

As mentioned earlier, Turndown supports choosing markdown styles for heading,
code block, etc., which is handy. But unfortunately, the other two export tools
doesn't provide such options, therefore I had to make manual adjustments in
order to keep the style consistent.

For example, `mediumexporter` uses indentation for code blocks:

```markdown
    asdf plugin-add java
```

But I prefer fenced with back ticks:

````markdown
```bash
asdf plugin-add java
```
````

### Updating Stale Links

I have been blogging on and off for ten years, which is a long time.
Unfortunately during that time many of the sites that I originally linked to are
no longer live, so there are a fair number of stale links in my posts. For some
of the linked pages, the site was moved and I was able to find their new home
then update to the new links. For others the site was simply gone, but I
still kept the stale links as plain text maybe just to note that there used to
be this article on the Internet.

Also even for the valid links, after all these years the content might be
out-of-date or even irrelevant. Sadly there is not much I could do about that.
Like it or not, nothing lasts for ever in this world.

## Summary

In this post, I briefly went through my blogging journey over the past ten
years, noted down how I migrated content from three different sources to the
current Jekyll blog and the various adjustments that were made.

Hopefully this would serve as a reference for people who want to do the
same and might even be helpful for my future self as well.

Again I'd like to thank Paul, Yijun and Jianguo for their generous help, thank
the authors to the articles I referenced for sharing their knowledge for free
and thank the creators and contributors of the open source tools I used for
their great work.

[Export your Medium posts to Markdown]: https://medium.com/@macropus/export-your-medium-posts-to-markdown-b5ccc8cb0050
[Github Pages]: https://pages.github.com/
[its Github repository]: https://github.com/lonekorean/wordpress-export-to-markdown
[How To Convert WordPress To Markdown]: https://kevq.uk/how-to-convert-wordpress-to-markdown/
[Jekyll]: https://jekyllrb.com/
[Jekyll team]: https://jekyllrb.com/team/
[Octopress]: https://github.com/octopress/octopress
[Medium]: https://medium.com/@wiserfirst
[Medium Model]: https://blog.medium.com/the-medium-model-3ec28c6f603a
[metered paywall]: https://help.medium.com/hc/en-us/articles/360017581433-About-the-metered-paywall
[Minimal Mistakes]: https://mmistakes.github.io/minimal-mistakes/
[Paul]: https://twitter.com/paulfioravanti
[paulfioravanti.com]: https://paulfioravanti.com
[source for his blog]: https://github.com/paulfioravanti/paulfioravanti.github.io
[Scribble]: https://github.com/muan/scribble
[Turndown]: https://domchristie.github.io/turndown/
[this repository]: https://github.com/wiserfirst/wiserfirst.github.io
[WordPress]: https://wordpress.com/
[wordpress-export-to-markdown]: https://github.com/lonekorean/wordpress-export-to-markdown
