---
title: "Type Narrowing with Custom Functions in Typescript"
date: 2023-02-12 22:30:00 +1000
tags: Typescript type-narrowing tiny-tips
header:
  image: /assets/images/2023-02-13/road_in_forest.jpg
  image_description: "Talimena Scenic Drive - Road in autumn forest"
  teaser: /assets/images/2023-02-13/road_in_forest.jpg
  overlay_image: /assets/images/2023-02-13/road_in_forest.jpg
  overlay_filter: 0.2
  caption: >
    Image by [Brendan Steeves](https://unsplash.com/@brendan_k_steeves?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/photos/G-YAJ61qIuU?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
excerpt: Typescript has union types and there are many ways to narrow the types
---

Typescript has union types. For example:

```typescript
  type StringOrNumber = string | number
```

Here the `StringOrNumber` type can be either `string` or `number` as expected.
The member types do not have to be primitive types and they can be custom types
as well.

When dealing with union types, before we can apply operations or functions that
are specific to one member type, we would need to figure out which member type
we have and that's called type narrowing.

There are many ways to narrow the type, but in this post I specifically want to
cover the syntax for creating a custom function to do type narrowing. I found
myself referring back to the "Using type predicates" section on [the Narrowing
page in Typescript documentation][narrowing-page], so I figure it might be a
good idea to make it slightly easier to find and potentially easier to remember
by writing a post about it.

Let's say we want to create a type narrowing function for the `StringOrNumber`
type above, it would look like this:

```typescript
function isString(input: StringOrNumber): input is string {
  return typeof input === 'string'
}
```

Here, `input is string` is called a type predicate and it is the return type of
the `isString` function. In the function body, it needs to return a boolean
value: `true` means `input` is the expected type and `false` means it is not.
The function's logic can be as complex as it needs to be. As long as it returns
a boolean value in the end, it'll work fine as a type narrowing function or say
a type guard.

In this example, returning `true` means `input` is a string, otherwise it's a
number, considering it can only be either a string or a number.

We can use it like the following:

```typescript
// assuming we have a function that returns a string or a number
let a: StringOrNumber = getStringOrNumber()

if (isString(a)) {
  a.length
} else {
  a + 3
}
```

Of course, this is just a contrived example to demonstrate the correct syntax.
In a real world application, we would most likely just do `typeof input ===
'string'` instead of creating a function to do it.

One more thing worth noting is that when we create a custom type guard,
Typescript would treat us as adults and completely trust that it will do the
right thing. For example, we can define a nonsensical type guard like this:

```typescript
function isString(input: StringOrNumber): input is string {
  return typeof input === 'number'
}
```

And Typescript would happily accept it and gives no compiler error or warning,
but since it's narrowing the type incorrectly, some runtime errors should be
expected after using this type guard.

In this post, I briefly talked about what type narrowing is and then looked into
how to define our own type guard. As usual, the hope is to help my future self
and potentially be of service to other people who are starting their Typescript
journey as well.

[narrowing-page]: https://www.typescriptlang.org/docs/handbook/2/narrowing.html
