---
title: Recursion with the Y Combinator
published: true
description: Using the Y combinator to implement recursion
tags: ycombinator, functional, beginners, javascript
cover_image: /assets/images/2021-08-04-recursion-with-the-y-combinator-ai4.780603/ghbkv1ofsoa8v8riqzfr.jpg
---
In this article, we'll introduce a higher-order function called the Y combinator. It's immediately recognizable thanks to the famous [startup incubator](https://www.ycombinator.com/) of the same name, but what is this strange sounding term all about? 

In most languages, recursion is supported directly for named functions. For example, the following `factorial` function written in JavaScript calls itself recursively: 

```javascript
const factorial = n => n > 1 ? n * factorial(n-1) : 1
factorial(5) // 120
```
Lambdas, i.e. anonymous functions, generally don't have built-in support for recursion, but since they should be used when the logic is simple (and extracted to a named function otherwise), it's unlikely one would want to make a recursive call in a lambda. 

Therefore, making recursive calls as above is the way to go. However, let's pretend we can't use recursion directly. As long as our language has support for functions as first-class citizens (they can be assigned to variables, passed in as arguments, and returned like any other object), we can still implement recursion ourselves. One nice way to do so is with a higher-order function called the Y combinator. The name sounds intimidating, but it's just a higher-order function, a function that wraps around another function.

Instead of making a recursive call directly as we did earlier, we will modify our `factorial` function so that is calls a callback function. This callback function will be responsible for calling back into the `factorial` function to complete a recursive call. Our `factorial` function will therefore now have an additional parameter, `recurse`:

```javascript
const factorial => recurse => n => n > 1 ? n * recurse(n-1) : 1;
```

In the above function, instead of calling `factorial` directly, we call the `recurse` callback.

What should this callback look like? Supposing we have already arranged to provide a handle to the `factorial` function and its argument, we can consider a `callRecursively` function that looks something like the following:

```javascript
const callRecursively = target => args => 
                            target(args2 => 
                                target(args3 => target(...)...));
```
When we call our target (the `factorial` function in our case), we need to pass a callback to it that accepts the next parameter that the target will be called with. However, we run into a problem of infinite regress. For each call, we have to to keep supplying a new callback. 

It turns out there is a clever trick that helps us get around this limitation. We can create a function and then call that function with itself as its own argument! In JavaScript, we use an [IIFE](https://developer.mozilla.org/en-US/docs/Glossary/IIFE) to do so. Below is an example of the mechanism we'll use:

```javascript
(f => f(f))(self => console.log(self));
```
We supply the lambda `self => console.log(self)` as an argument to the self-executing lambda `(f => f(f))`. When we run this code (e.g. in the browser console), we see that the variable `self` refers to the very function it is being passed into as a parameter:

```javascript
> (f => f(f))(self => console.log(self));
self => console.log(self)
```
We will use this idea to solve our problem of infinite regress. We define a function we'll call Y (for Y combinator) that takes a target function (e.g. `factorial`) and the parameters for that target function as arguments. Our Y combinator function will then call the target function, supplying a callback for the target function to invoke when it wants to make a recursive call. The complete code is below:

```javascript
const Y = target => 
              args => 
                  (f => f(f))(self => target(a => self(self)(a)))(args);

const factorial = recurse => n => n > 1 ? n * recurse(n-1) : 1;

Y(factorial)(5); //120
```

In the above code, when the target, e.g. `factorial`, is passed into the Y combinator function, the Y combinator will immediately execute `self => target(a => self (self)(a))`. The callback `a => self(self)(a)` is passed to `target` so it can initiate the next recursive call. Keep in mind that `self` is a reference to the function `self => target(a => self(self)(a))`. 

When our `factorial` function receives the additional argument `5` (note that our target is [curried](https://en.wikipedia.org/wiki/Currying) in this example), it will execute the callback, passing in `4` for the argument `a`. This will trigger a recursive call back into the target, and so on, until the terminating condition for the target function is reached. When our callback code executes, we need to pass a reference to to the handler as the first argument, hence the `self(self)` fragment in the above code. 

The Y combinator function is not something we expect to see being used in modern programming languages, since they have built-in support for recursion (at least for named functions). However, higher-order functions are an important part of the functional programming paradigm, so working out the details of how such a function behaves can still be a useful exercise. The general idea of composing functions along these lines is commonly applied in functional programming across a wide range of use-cases. 

We also gain insight into [lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus), a powerful mathematical framework for understanding computation. For example, We can completely inline the code we've written to show there are no free variables. While the code is not exactly readable when inlined this way, this gets us very close to the pure lambda calculus form for this logic:

```javascript
(target =>  args => (f => f(f))(self => target(a => self(self)(a)))(args))(recurse => n => n > 1 ? n * recurse(n-1) : 1)(5); //120
```
## References
* [Y combinator](https://en.wikipedia.org/wiki/Fixed-point_combinator#Y_combinator)
* [Currying](https://en.wikipedia.org/wiki/Currying)
* [Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus)
* [IIFE](https://developer.mozilla.org/en-US/docs/Glossary/IIFE)