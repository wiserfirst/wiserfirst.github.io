---
title: "Make a Shell Command Always Succeed"
date: "2019-07-20 10:00:00 +1000"
last_modified_at: 2021-05-19 12:05:00 +1000
tags: linux bash
header:
  image: /assets/images/2021-05-19/golden_hour_1440_400.jpg
  image_description: "People Facing Golden Hour"
  teaser: /assets/images/2021-05-19/golden_hour_1440_400.jpg
  overlay_image: /assets/images/2021-05-19/golden_hour_1440_400.jpg
  overlay_filter: 0.3
  caption: >
    Image by [Guille Álvarez](https://unsplash.com/@guillealvarez)
    from [Unsplash](https://unsplash.com/photos/IcI3FizU9Cw)
excerpt: Never give up, until you succeed
---

In bash and many other shells, zero is called successful exit status code,
whereas any non-zero codes are failure exit codes. That is to say when a command
returns exit code of zero, it's considered successful; otherwise, it's
considered a failure.

In some situations, one want to make sure a command always return zero, ignoring
potential failures. This can be done with the `true` command:

```bash
random_thing || true
```

The most recent example is in our CI, there is a step to upload code coverage
report to codecov.io, but unfortunately their site has been flaky over the past
couple weeks, which might cause otherwise successful builds to fail. In this
case, we try to upload code coverage report, but if it fails for whatever
reason, it's okay to ignore. So the true command to the rescue:

```bash
./.codecov || true
```

where `.codecov` is the script for uploading the report.
