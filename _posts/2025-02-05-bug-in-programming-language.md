---
title: "The Case of Rejected Certificates: An OTP Mystery"
date: 2025-03-08 22:30:00 +1100
tags: Erlang OTP
header:
  image: /assets/images/2025-03-08/red_bug.jpg
  image_description: "Banff National Park"
  teaser: /assets/images/2025-03-08/red_bug.jpg
  overlay_image: /assets/images/2025-03-08/red_bug.jpg
  overlay_filter: 0.4
  caption: >
    Photo by [Jill Heyer](https://unsplash.com/@jillheyer)
    on [Unsplash](https://unsplash.com/photos/closeup-photography-of-ladybug-perched-on-green-leafed-plant-U9x5mG0pBiQ)
excerpt: Tracking down a production issue to a subtle bug in Erlang/OTP
---

## The Problem Arises

A couple of weeks ago, we attempted to upgrade our Erlang/OTP version from 24 to
25.3.2.16, which was the latest release at the time. Unfortunately, shortly
after the new release containing this change was deployed to production, our
Customer Service team reported that a specific payment feature had stopped
working. In fact, they noticed that we had stopped receiving this type of
payment almost immediately after the new release hit production. The timing was
too suspiciously close for this to be a coincidence.

## The Investigation

When investigating this issue, I had no idea what the cause was, but I did have
significant time pressure due to the nature of the problem—payments not being
processed is always urgent!

First thing I did was to understand where the failure was happening and managed
to replicate it in my local environment. Next, I methodically went through the
all the changes in this release, reverting suspicious-looking changes one by
one. Surprisingly, none of our actual code changes was the culprit.

The OTP version upgrade had seemed like one of the most innocent changes with
regard to the payment issue we were facing. However, after exhausting other
possibilities, I tested against OTP 24 since the OTP upgrade was a relatively
major change in the same release. I was quite shocked to discover that the new
version of OTP was indeed the guilty party.

## The (Partial) Solution

Since I'm not an expert on certificate validation in Erlang, the error message
we got when making requests to the bank looks cryptic:

```
TLS :client: In state :wait_cert_cr at ssl_handshake.erl:2123 generated CLIENT ALERT: Fatal - Unsupported Certificate
 - {:key_usage_mismatch,
 { {:Extension, {2, 5, 29, 15}, true, [:keyCertSign, :cRLSign]},
  {:Extension, {2, 5, 29, 37}, false,
   [{1, 3, 6, 1, 5, 5, 7, 3, 2}, {1, 3, 6, 1, 5, 5, 7, 3, 1}]}}}
```

But armed with this error message, I was able to find a [Github issue][gh-issue]
in the official OTP repository about the same problem. Apparently other
developers making HTTP requests with Erlang/Elixir had encountered the same
issue.

Thanks to Ingela Andin, the maintainer, and the community's efforts, a fix had
already been released for OTP 26 and 27. But unfortunately for us, there was an
impression that OTP 25 wasn't affected, so no fix had been done for it. Given
our urgent situation, we decided to revert back to OTP 24 to restore payment
processing as quickly as possible.

It's worth noting that after I reported that OTP 25 was indeed affected by the
same issue, Ingela responded quickly and worked on backporting the fix. A new
patch version with the fix was released about two weeks ago, clearing our path
to safely upgrading to OTP 25.

Now that we had a solution, I wanted to better understand what caused the
problem in the first place.

## Understanding Digital Certificates

To understand the bug, we need a quick primer on SSL/TLS certificates: digital
certificates are like digital ID cards that websites use to prove their
identity. Each certificate contains:

* The website's public key
* Information about the website (domain name, etc.)
* Information about how the certificate can be used
* A signature from a trusted Certificate Authority (CA)

Certificates have "extensions" that specify what they can be used for. Two
important ones are:

* Key Usage (KU): Broadly defines what the certificate's key can do (sign things, encrypt things, etc.)
* Extended Key Usage (EKU): More specifically defines the certificate's purpose (web server authentication, email, etc.)

## The Bug in OTP

The bug occurred because recent versions of OTP was enforcing a rule that wasn't
actually specified in the certificate standards (RFC 5280).

In simple terms:

* The certificates from certain CAs like Entrust had a flag set indicating they could sign other certificates (keyCertSign)
* They also had flags set saying they could be used for web server authentication
* OTP thought these two purposes were contradictory and rejected the certificate

It's like if you're qualified as both a teacher and a restaurant chef, but then
a bureaucrat refused to accept because "you can't possibly do both these
unrelated jobs." In reality, of course, there's no reason someone couldn't be
qualified for both roles independently.

And same goes for digital certificates. The certificate standard (RFC 5280)
allows certificates to serve multiple purposes simultaneously, but OTP's new
validation logic was too restrictive.

For those interested in further technical details, there are extensive
discussions in the [Github issue][gh-issue] and here is the [PR][gh-pr] that
fixed it.

## Takeaways

A few interesting lessons from this experience:

1. Hidden Complexity: Even mature, well-tested software like Erlang/OTP can have subtle bugs in complex areas like SSL/TLS.
2. Implementation vs. Specification: The bug wasn't a coding error but an overly strict interpretation of a technical standard.
3. Community Matters: Thanks to the Erlang community for identifying and fixing this issue very quickly.

## Summary

In this post, we started with an unexpected payment issue in production from
upgrading the OTP version to 25. After identifying the new OTP version as the
culprit, we had to revert back to OTP 24.

We also dove into understanding how the bug happened, which was essentially an
overly strict interpretation of certificate standards. Thanks to the responsive
Erlang community and OTP maintainers, a fix was backported to OTP 25, resolving
the bug.

For me this was quite an interesting experience, because the overwhelming
majority of bugs we face as developers are introduced by ourselves in the
application layer. Sometimes we do encounter bugs in the library or framework
that we use, but that's pretty rare. It is ultra rare to face a bug in the
underlying programming language. In fact, this was the very first one I had in
my whole career as a developer, and I've been doing this for almost 20 years.

[gh-issue]: https://github.com/erlang/otp/issues/9208
[gh-pr]: https://github.com/erlang/otp/pull/9286
