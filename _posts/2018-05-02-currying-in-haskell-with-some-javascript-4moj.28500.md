---
title: Currying in Haskell (With Some JavaScript)
published: true
description: Discussion of Haskell's currying of functions and comparison with javascript
cover_image: /assets/images/2018-05-02-currying-in-haskell-with-some-javascript-4moj.28500/yf9e5yfkmxc99o6t5kh8.jpg
canonical_url: https://nestedsoftware.com/2018/05/02/currying-in-haskell-with-some-javascript-4moj.28500.html
tags: haskell, currying, javascript 
---

I've been delving a bit into the functional language [Haskell](https://www.haskell.org/) recently, and I discovered that it has a somewhat unusual way of handling function parameters. Usually, you supply the arguments and call a function, and that's the end of the story. 

For example, the following trivial JavaScript `sub` function just subtracts its two arguments:

```javascript
const sub = (first, second) => first - second
```

We can call it as follows:

```javascript 
sub(7,2)
```
Let's write `sub` in Haskell and find out how it is different from the JavaScript version:

```haskell
main = print (sub 7 2) 

sub :: (Num a) => a -> a -> a
sub first second = first - second
```

Let's see the result:

```
C:\dev>ghc sub.hs
[1 of 1] Compiling Main             ( sub.hs, sub.o )
Linking sub.exe ...
C:\dev>sub.exe
4
```

This looks as though it's the same function. The signature seems to be saying: Take two numbers as parameters and return a third number as a result. However, notice how there are no parentheses in `a -> a -> a`? One might expect something more like `(a, a) -> a`. That's actually a clue that something slightly different is going on. 

Below I've tried to come up with a way to show this:

```haskell
main = print finalresult
    where finalresult = partialresult 3
          partialresult = sub 7
```

If we modify the main function as above, we can see that calling sub with just a single argument, `7`, returns a function. We call this intermediate function with `3`, which then returns `4`, the actual result of the subtraction.

>Each time a function is returned, it retains access to the parameters that were passed in to its calling function. Functions that can retain enclosing scope like this, even once execution has moved out of the block associated with that scope, are called [_closures_](https://en.wikipedia.org/wiki/Closure_(computer_programming)). 

So, what is really happening then? In fact, the `sub` function takes a single number as a parameter and returns a function. That function also takes a number as a parameter, and returns the result of the subtraction. This idea of decomposing a function that takes multiple arguments into a nesting of functions where each function just has one argument is called [_currying_](https://en.wikipedia.org/wiki/Currying).

Let's try to simulate this behaviour with JavaScript:

```javascript
const sub = first => {
	const intermediateResult = second => {
		return first - second
	}

	return intermediateResult
}
``` 

Here's how we'd call this type of function in JavaScript:

```javascript
const result = sub (7) (3) 
console.log('subtraction result = ' + result)
```

We call `sub` with `7` as an argument and then we call the function that it returns with `3`. This intermediate function is the one that actually computes the difference between the two values.

In Haskell, currying is built into the language. Any function in Haskell can be called with partial arguments, and the remaining arguments can be applied later.  

Is currying useful?

```haskell
map (+3) [1,5,3,1,6]
```

In Haskell we can just call the `+` function with a single argument, `3` in this case. `map` then then calls the intermediate function with each of the items in the list as parameters. 

In something like JavaScript, we can't do this directly, but we can get around the problem easily enough with a lambda:


```javascript
[1,5,3,1,6].map(x=>x+3)
```

While currying doesn't strike me as being essential to functional programming in the same way that the concepts of [first-class functions](https://en.wikipedia.org/wiki/First-class_function) and [closures](https://en.wikipedia.org/wiki/Closure_(computer_programming)) are, I have to admit there is a certain orthogonality and conceptual purity to the way Haskell handles arguments. 

In particular, currying fits in well with the fact that most everything in Haskell is [evaluated lazily](https://en.wikipedia.org/wiki/Lazy_evaluation). In that context currying makes some sense, since most functions evaluate to a _thunk_ anyway and the underlying logic is not fully processed until a complete result is required.

If you're interested in learning more about Haskell, I highly recommend getting started with the tutorial [Learn You a Haskell for Great Good!](http://learnyouahaskell.com/).
