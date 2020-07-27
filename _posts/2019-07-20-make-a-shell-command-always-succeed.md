---
title: "Make a Shell Command Always Succeed"
date: "2019-07-20"
tags: linux bash
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
