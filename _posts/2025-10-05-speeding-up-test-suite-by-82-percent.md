---
title: "Speeding Up Our Test Suite by 82%"
date: 2025-09-30
tags: Elixir  Phoenix Bcrypt Testing
excerpt: "One small trick reduced run time of our test suite from 285 seconds to 50 seconds"
---

## The Slow Beginning

Initially, our main Phoenix application had no reliable test suite. While some
tests existed, many failed for various reasons, so they provided very little
assurance that new changes wouldn't break existing functionality and we can not
run them on CI.

Obviously that wasn't a great situation to be in, so when I started working on
this application, one of the first things I did was to fix the test suite. I
fixed some test failures and temporarily skipped others, so that the whole test
suite could run successfully. Next I created a build pipeline that runs the test
suite on our Jenkins CI server, so at least for the parts of the codebase with
test coverage, we get some level of confidence.

While being a step forward, it did bring a new problem: the test suite was quite
slow. A full run on my work laptop takes almost five minutes, so I generally
avoid running the full test suite locally. But it takes even longer on CI, so it
was quite some wait for each build to pass.

Since we were all busy working on new features or fixing bugs, this situation
lasted a long time unfortunately.

That would change, however, with AI assisted coding. In particular I mainly have
been using Claude Code

## Finding the Bottleneck

Before optimizing anything, we needed to understand what was actually slow. A quick profiling session revealed the culprit: **Bcrypt**. Specifically, every call to `Bcrypt.hash_pwd_salt()` was taking 100-200ms.

That might not sound like much, until you realize our test suite was calling it hundreds of times. Every `insert(:user)`, every `insert(:affiliate)`, every `insert(:app_user)` in our ExMachina factories was hashing a password:

```elixir
def app_user_factory() do
  %AppUser{
    username: Internet.user_name(),
    email: Internet.email(),
    password_hash: Bcrypt.hash_pwd_salt("test_password_123")  # 100-200ms each!
  }
end
```

Multiply that by hundreds of test setups, and suddenly our bottleneck was clear.

## First Optimization: Avoiding Repeated Hashing

Our initial thinking was straightforward: if we can't avoid Bcrypt entirely, let's at least call it fewer times. The idea was to pre-compute password hashes once as module constants, then reuse them for all default test data.

Here's what that looked like:

```elixir
defmodule Admin.AppUserFactory do
  # Pre-computed hash for the default test password
  @app_user_test_password "test_password_123"
  @app_user_test_password_hash "$2b$12$MFkURc/nMXU5HQxgWURhauA4tegLJKvJPlOtvQxzvQ35oz0q/Nrj2"

  def app_user_factory(attrs) do
    password = Map.get(attrs, :password, @app_user_test_password)

    # Use pre-computed hash for default, generate for custom passwords
    password_hash = Map.get_lazy(attrs, :password_hash, fn ->
      if password == @app_user_test_password do
        @app_user_test_password_hash  # Fast: pre-computed
      else
        Bcrypt.hash_pwd_salt(password)  # Slow: on-demand
      end
    end)

    %AppUser{
      username: Internet.user_name(),
      email: Internet.email(),
      password_hash: password_hash
    }
  end
end
```

We applied this pattern across all our authentication-related factories: users, affiliates, providers, app users. Each got their own set of default test passwords and pre-computed hashes.

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

**~63% improvement!** We'd cut nearly three minutes off our test suite. Success!

But something nagged at me. We'd added a fair bit of complexity - constants, conditionals, helper functions across multiple factory files. It worked, but it felt... heavy.

## The Question That Changed Everything

After celebrating the initial win, I asked myself: **"Is there a cheaper alternative to `Bcrypt.hash_pwd_salt` for tests?"**

This question led me down a different path - instead of working around Bcrypt, what if I could make Bcrypt itself faster?

That's when I discovered `log_rounds`.

## Understanding the Root Cause

Bcrypt is intentionally slow. That's the whole point - by making password hashing computationally expensive, it protects against brute-force attacks. The `log_rounds` parameter controls this cost:

- `log_rounds: 12` means 2^12 = **4,096 iterations**
- `log_rounds: 10` means 2^10 = **1,024 iterations**
- `log_rounds: 4` means 2^4 = **16 iterations**

Each increment doubles the computational work. The default is 12, which is excellent for production security. But here's the insight: **test data doesn't need production-level security**.

Test passwords are ephemeral. They exist only during test execution and are immediately discarded. We don't need them to resist brute-force attacks. We just need valid hashes that Bcrypt can verify.

And crucially, Bcrypt's `log_rounds` can be configured per environment.

## Second Optimization: Configuration Over Complexity

Armed with this understanding, the solution became obvious. Instead of all that factory complexity, we needed one line:

```elixir
# config/test.exs
config :bcrypt_elixir, :log_rounds, 4
```

That's it. One configuration line.

With this in place, I reverted all the factory changes - removed the pre-computed hash constants, removed the conditional logic, removed the helper functions. The factories went back to their simple, original form:

```elixir
def app_user_factory(attrs) do
  password = Map.get_lazy(attrs, :password, fn -> random_password() end)

  %AppUser{
    username: Internet.user_name(),
    email: Internet.email(),
    password_hash: Bcrypt.hash_pwd_salt(password)  # Now fast!
  }
end
```

Clean. Simple. No special cases.

The results?

```bash
# After second optimization
$ mix test
....................................
Finished in 50.1 seconds
```

**An additional ~52% improvement** on top of the first optimization. In total: **from 285 seconds to 50 seconds - an 82% speedup** (5.7x faster).

And the code was simpler than when we started.

## Why This Works

The math is straightforward:

- **Production** (log_rounds: 12): 4,096 iterations per hash
- **Tests** (log_rounds: 4): 16 iterations per hash
- **Theoretical speedup**: 256x faster hashing

In practice, hashing wasn't our only operation, so we didn't see a full 256x improvement overall. But it was dramatic enough to cut our test suite by more than half from the first optimization.

More importantly, our production configuration remained unchanged:

```elixir
# config/prod.exs
config :bcrypt_elixir, :log_rounds, 12  # Still secure!

# config/dev.exs
config :bcrypt_elixir, :log_rounds, 12  # Still secure!

# config/test.exs
config :bcrypt_elixir, :log_rounds, 4   # Fast for tests
```

No security compromises. Bcrypt is doing exactly what it's designed to do, just with environment-appropriate settings.

## Lessons Learned

Looking back on this journey, several lessons stand out:

1. **Profile before optimizing** - Don't guess where your bottlenecks are. Measure.

2. **Ask "why" not just "how"** - "How do I avoid this?" led to complexity. "Why is this slow?" led to the root cause.

3. **Understand your tools** - Bcrypt wasn't the problem; using production settings in tests was the problem.

4. **First solution isn't always best** - The pre-computed hash approach worked, but understanding the underlying issue led to a better solution.

5. **Configuration can beat code** - Sometimes the most powerful optimization is a single config line.

6. **Test requirements ≠ Production requirements** - Tests need speed. Production needs security. Environment-specific configuration lets you have both.

In hindsight, the first optimization wasn't necessary - we could have gone straight to the config change. But that journey of trying to work around Bcrypt led me to ask the question that revealed the real solution.

## How to Apply This

If your Elixir/Phoenix test suite is slow and uses Bcrypt authentication, here's what to do:

1. **Check if Bcrypt is your bottleneck** - Profile your tests to confirm

2. **Add one line to `config/test.exs`**:
   ```elixir
   config :bcrypt_elixir, :log_rounds, 4
   ```

3. **Verify your production config is unchanged** - Check that `config/prod.exs` and `config/dev.exs` still use secure defaults (10-12)

4. **Run your tests and measure** - Time before and after to see the improvement

5. **Apply the same thinking elsewhere** - Are there other expensive operations in your tests that don't need production-level settings?

## Conclusion

Fast tests are critical for test-driven development and development velocity. When tests take minutes to run, you lose the rapid feedback loop that makes TDD effective.

Our journey from 285 seconds to 50 seconds required understanding that the tools we use often have knobs we can turn. Bcrypt's `log_rounds` was designed precisely for this use case - different environments with different security requirements.

The path to an 82% improvement wasn't a straight line. We tried one approach, got good results, then asked if we could do better. That curiosity led us to a simpler, faster, more maintainable solution.

Sometimes the best optimization comes not from clever code, but from understanding the problem deeply enough to configure your tools appropriately.

---

*Have you found similar configuration-over-code wins in your test suite? I'd love to hear about them in the comments below.*
