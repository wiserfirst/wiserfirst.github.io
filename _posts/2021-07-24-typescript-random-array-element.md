---
title: "Get Random Array Element in Typescript"
date: "2021-07-24 16:35:00 +1000"
tags: Javascript Typescript mini-patterns array lodash
header:
  image: /assets/images/2021-07-25/dice_1440_400.jpg
  image_description: "Random array of dice"
  teaser: /assets/images/2021-07-25/dice_1440_400.jpg
  overlay_image: /assets/images/2021-07-25/dice_1440_400.jpg
  overlay_filter: 0.5
  caption: >
    Image by [Mick Haupt](https://unsplash.com/@rocinante_11?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/s/photos/random?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
excerpt: Typescript Mini-patterns
---

Recently I needed to be able to get a random element from an array. It was
slightly surprising to me that the [Javascript Array
class][javascript-array-class] doesn't provide a built-in function for that.

In this post I talks about how I built a function to do that and also compared
with the `_.sample` function from the popular Javascript library [lodash][].

## Initial Implementation

I'm building it in Typescript, since the project I am working on already uses
Typescript.

The function takes an array and returns a random element from it. The type of
array element doesn't matter here. So the function signature should be something
like this:

```typescript
(arr: any[]) => any
```

For an array, the lowest valid index is `0` and the highest valid index is
`arr.length - 1`. I could generate an random integer between `0` and
`arr.length - 1`. Then if I use that number as index for the array, I could get
back a random element. That should look like this:

```typescript
Math.floor(Math.random() * arr.length)
```

So we have our function:

```typescript
const getRandomElement = (arr: any[]) =>
  arr[Math.floor(Math.random() * arr.length)]
```

It does the job and it's fairly straightforward. But there is actually a small
issue, which I'll address in later.

## Comparison with `_.sample`

After implementing it, I thought that there is a `_.sample` function from the
popular library [lodash][], it would be interesting to see how it was
implemented.

I'm going to look at the latest version of lodash, which is 4.17.21 as of this
writing.

The [`_.sample`][sample] function looks like this:

```javascript
/**
 * Gets a random element from `collection`.
 *
 * @static
 * @memberOf _
 * @since 2.0.0
 * @category Collection
 * @param {Array|Object} collection The collection to sample.
 * @returns {*} Returns the random element.
 * @example
 *
 * _.sample([1, 2, 3, 4]);
 * // => 2
 */
function sample(collection) {
  var func = isArray(collection) ? arraySample : baseSample;
  return func(collection);
}
```

Apparently it handles not only arrays but also collections in general.

I won't worry about `baseSample` for collections that are not array in this
article. But if you like, feel free to check out [its source][baseSample].

For arrays, it delegates to a [`arraySample`][arraySample] function, which looks
like this:

```javascript
/**
 * A specialized version of `_.sample` for arrays.
 *
 * @private
 * @param {Array} array The array to sample.
 * @returns {*} Returns the random element.
 */
function arraySample(array) {
  var length = array.length;
  return length ? array[baseRandom(0, length - 1)] : undefined;
}
```

So it checks the array length, and if length is `0` it returns `undefined`.
Otherwise it's very similar to my implementation: it calls `baseRandom` with `0`
and `length - 1` to (presumably) get a random integer, then use it as index for
the array and gets a random element from the array.

In order for this to work, the [`baseRandom`][baseRandom] function must generate
a random integer between its two arguments.

```javascript
/**
 * The base implementation of `_.random` without support for returning
 * floating-point numbers.
 *
 * @private
 * @param {number} lower The lower bound.
 * @param {number} upper The upper bound.
 * @returns {number} Returns the random number.
 */
function baseRandom(lower, upper) {
  return lower + nativeFloor(nativeRandom() * (upper - lower + 1));
}
```

And looks like it does!

[`nativeFloor`][nativeFloor] and [`nativeRandom`][nativeRandom] in here are just
aliases for the built-in methods `Math.Floor` and `Math.random`.

## Improvement

I'm glad to see that the core logic of `_.sample` for arrays is very similar to
the `getRandomElement` function I got. However, it did check the array length,
which I forgot to do.

In my use case, `getRandomElement` is just used as a test helper and the same
non-empty array constant is always passed in, so omitting the array length check
isn't causing any issue for now.

But for completeness' sake and also to allow it to be used in other scenarios in
the future, I should add the array length check. So the function becomes:

```typescript
const getRandomElement = (arr: any[]) =>
  arr.length ? arr[Math.floor(Math.random() * arr.length)] : undefined
```

## Summary

In this article, I walked through how to implement a function for getting a
random element from an array, had a tour in lodash source code around `_.sample`
and improved the initial implementation by adding an array length check to make
it more complete and robust.

Open source not only come in handy when we need to use them directly in our
projects, but also serve as a great resource for learning.

I definitely should look more into source code of open source libraries and
frameworks. Maybe you should too :smile:

[arraySample]: https://github.com/lodash/lodash/blob/4.17.21/lodash.js#L2452-L2462
[baseRandom]: https://github.com/lodash/lodash/blob/4.17.21/lodash.js#L3910-L3921
[baseSample]: https://github.com/lodash/lodash/blob/4.17.21/lodash.js#L3986-L3995
[javascript-array-class]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array
[lodash]: https://www.npmjs.com/package/lodash
[nativeFloor]: https://github.com/lodash/lodash/blob/4.17.21/lodash.js#L1532
[nativeRandom]: https://github.com/lodash/lodash/blob/4.17.21/lodash.js#L1542
[sample]: https://github.com/lodash/lodash/blob/4.17.21/lodash.js#L9820-L9837
