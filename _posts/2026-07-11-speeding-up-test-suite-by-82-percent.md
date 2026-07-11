---
title: "Speeding Up Our Test Suite by 82%"
date: 2026-07-11
tags: elixir phoenix bcrypt testing ai
header:
  image: /assets/images/2026-07-11/lighthouse_road.jpg
  image_description: "A winding coastal path leading to a red lighthouse"
  teaser: /assets/images/2026-07-11/lighthouse_road.jpg
  overlay_image: /assets/images/2026-07-11/lighthouse_road.jpg
  overlay_filter: 0.5
  caption: >
    Photo by [Marcelo Santos](https://unsplash.com/@yotta88)
    on [Unsplash](https://unsplash.com/photos/ShWsTBAMzYM)
excerpt: "A discovery that shouldn't have been necessary"
---

## The Config Line That Made Me Wince

Late last year I joined a new company. In my first week, poking around the
Phoenix app I'd be working on, I found this in `config/test.exs`:

```elixir
config :bcrypt_elixir, :log_rounds, 1
```

Nobody on the team had written that line. The installer that scaffolded the
app's authentication generated it, as Phoenix's own `phx.gen.auth` does for
every new app. The `bcrypt_elixir` docs recommend the same thing plainly.

I winced. Only months earlier, at my previous company, I had spent weeks
"discovering" this exact fix: profiling, benchmarks, rounds of factory rewrites,
using the best available model at the time.

I even had a post drafted about that journey, documenting what felt like a solid
performance win. It had been waiting on finishing touches I never got round to,
and after that week they stopped mattering. So here it is instead, rewritten as
a confession.

## The Slow Suite

Rewind to my previous company. Our main Phoenix application had no
reliable test suite. Some tests existed, but many failed for various reasons.
That meant we couldn't run them on CI, so they offered little assurance that new
changes wouldn't break existing functionality.

We were a tiny team, just three developers, hammered by an endless stream of
feature requests and bug reports. My colleagues stayed underwater in that
stream. But I kept coming back to the Chinese saying 工欲善其事，必先利其器: to
do good work, one must first sharpen one's tools. So I took the test suite on.

I fixed some failures, temporarily skipped others, and got the suite green. Then
I set up a Jenkins pipeline so every change ran the tests. A real step forward,
with a catch.

The full suite took 285 seconds on my laptop, and even longer on CI. Nearly five
minutes per run meant I avoided running it locally, and every build was a long
wait.

The slowness bothered me, but I had no clear picture of where the time was going
and no obvious plan of attack. I couldn't justify spending days on optimization
without a concrete goal, so we lived with it for a long time.

What eventually changed the calculus was AI-assisted coding. With models finally
capable of serious work on a real codebase, an open-ended optimization effort
stopped looking like a time sink I couldn't afford.

## Finding the Bottleneck

Before optimizing anything, I profiled. The culprit revealed itself quickly:
**Bcrypt**. Every call to `Bcrypt.hash_pwd_salt()` took 100–200ms.

That might not sound like much, until you realize the suite called it hundreds
of times. Every `insert(:user)`, `insert(:customer)`, and `insert(:provider)`
in our ExMachina factories hashed a password:

```elixir
def user_factory() do
  %User{
    username: Internet.user_name(),
    email: Internet.email(),
    password_hash: Bcrypt.hash_pwd_salt("test_password_123")  # 100-200ms each!
  }
end
```

Multiply that by hundreds of test setups, and the bottleneck was clear.

## Optimizing the Hard Way

The work happened in Claude Code, on Opus 4, the strongest model of the day. My
instruction was direct: benchmark the factories and optimize away the repeated
hashing.

And that is exactly what it did. Diligently. We pre-computed password hashes as
module constants and reused them for all default test data, falling back to real
hashing only for custom passwords:

```elixir
defmodule Admin.UserFactory do
  # Pre-computed hash for the default test password
  @user_test_password "test_password_123"
  @user_test_password_hash "$2b$12$MFkURc/nMXU5HQxgWURhauA4tegLJKvJPlOtvQxzvQ35oz0q/Nrj2"

  def user_factory(attrs) do
    password = Map.get(attrs, :password, @user_test_password)

    # Use pre-computed hash for default, generate for custom passwords
    password_hash = Map.get_lazy(attrs, :password_hash, fn ->
      if password == @user_test_password do
        @user_test_password_hash  # Fast: pre-computed
      else
        Bcrypt.hash_pwd_salt(password)  # Slow: on-demand
      end
    end)

    %User{
      username: Internet.user_name(),
      email: Internet.email(),
      password_hash: password_hash
    }
  end
end
```

We applied this pattern across every authentication-related factory: users,
customers, providers. Each got its own default test password and
pre-computed hash.

The results?

```bash
# Before
$ mix test
....................................
Finished in 285.6 seconds

# After first optimization
$ mix test
....................................
Finished in 105.2 seconds
```

**~63% improvement.** Nearly three minutes off the suite. Success!

But notice what didn't happen. The model knew the goal was a faster test suite,
and, as I would soon find out, it knew the standard fix. Yet across all those
rounds of benchmarking and refactoring, it never suggested `log_rounds`, or even
checking the `bcrypt_elixir` docs. I had asked it to optimize factories, so it
optimized factories.

And something felt wrong to me. We had added real complexity (constants,
conditionals, helper functions across multiple factory files) for a problem that
every Elixir app hashing passwords must share. A problem this common shouldn't
need solving the hard way.

## The Question That Changed Everything

If the problem was that common, someone must have solved it properly already. So
I asked a different question: **"Is there a cheaper alternative to
`Bcrypt.hash_pwd_salt` for tests?"**

The model came back with the fix almost immediately: `log_rounds`. It had known
all along. It was just never asked.

Bcrypt is intentionally slow. That's the whole point: by making password hashing
computationally expensive, it protects against brute-force attacks. The
`log_rounds` parameter controls this cost:

- `log_rounds: 12` means 2^12 = **4,096 iterations**
- `log_rounds: 10` means 2^10 = **1,024 iterations**
- `log_rounds: 4` means 2^4 = **16 iterations**

Each increment doubles the computational work. The default of 12 is right for
production. But test passwords are ephemeral: they exist only during a test run
and are immediately discarded. They only need to be valid hashes, not
brute-force resistant.

And crucially, `log_rounds` can be configured per environment:

```elixir
# config/test.exs
config :bcrypt_elixir, :log_rounds, 4
```

One line. I reverted every factory change (the constants, the conditionals, the
helpers) and the factories went back to their simple, original form:

```elixir
def user_factory(attrs) do
  password = Map.get_lazy(attrs, :password, fn -> random_password() end)

  %User{
    username: Internet.user_name(),
    email: Internet.email(),
    password_hash: Bcrypt.hash_pwd_salt(password)  # Now fast!
  }
end
```

The results?

```bash
# After second optimization
$ mix test
....................................
Finished in 50.1 seconds
```

From 285 seconds to 50: **an 82% speedup**, 5.7× faster, with less code than we
started with. Production and dev configs stayed at 12, so there was no security
compromise anywhere.

## It Shouldn't Have Been a Discovery

I drafted this story a couple of months after the fix. Knowing no better, I had
framed it as a reasonable approach to a tough problem, with a big discovery at
the end. It needed only some finishing touches, but life got busy, and the draft
sat.

Then came the new company, and that config line staring at me from a `test.exs`
nobody had to write. I checked the `bcrypt_elixir` README. There it was: a low
`log_rounds` setting for tests, documented clearly, all along.

I was taken aback. My hard-won discovery was just boilerplate, knowledge so
standard that app generators write it for you. For a good while I wasn't sure
this post deserved publishing at all.

But that is exactly why it does. A tiny team lived with a five-minute test suite
for years. The best model of the day ran rounds of benchmarks without once
suggesting the docs. The fix was one documented line. The failure mode is the
story.

## What I Actually Learned

**The bottleneck was the question, not the intelligence.** The model knew about
`log_rounds` the entire time. Any of us could have found it in the README in
five minutes. Nobody asked.

**AI amplifies your framing; it doesn't correct it.** Asked to optimize
factories, the model optimized factories: skillfully, and entirely within my
flawed premise. Knowing my end goal didn't help; my instructions had already
chosen the approach. The quality of the answer is capped by the quality of the
question.

**Read the library docs before optimizing around the library.** Bcrypt was never
the problem. Using production settings in tests was, and the library authors had
anticipated exactly that.

**Listen to the "this is too hard" feeling.** The pre-computed-hash detour
wasn't wasted. The discomfort of all that added complexity is what pushed me to
stop and ask a better question.

**Config can beat code.** If your Elixir test suite is slow and uses Bcrypt, the
fix is one line, and if your app's authentication came from a generator like
`phx.gen.auth`, it is probably already there:

```elixir
# config/test.exs
config :bcrypt_elixir, :log_rounds, 1
```

Generators write 1; the `bcrypt_elixir` docs suggest 4, which is what we used.
Either way, hashing becomes effectively free in tests.

Sometimes the best optimization isn't clever code, or even a smarter model. It's
noticing that a problem is too common to be this hard, then asking the question
that assumes someone already solved it.
