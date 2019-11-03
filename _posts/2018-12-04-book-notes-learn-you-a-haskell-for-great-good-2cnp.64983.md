---
title: Book Notes&#58; Learn You a Haskell for Great Good!
published: true
description: Brain dump after reading Learn You a Haskell for Great Good!
cover_image: /assets/images/2018-12-04-book-notes-learn-you-a-haskell-for-great-good-2cnp.64983/nm9q01coa2gzmuxeoa8z.jpg
canonical_url: https://nestedsoftware.com/2018/12/04/book-notes-learn-you-a-haskell-for-great-good-2cnp.64983.html
tags: haskell, functional, monad, javascript
---

In the past few weeks I've gone over the book [Learn You a Haskell for Great Good!](http://learnyouahaskell.com/) by Miran Lipovača. I'd been curious, but also a bit intimidated by the idea of learning Haskell. Perusing it at random, Haskell code doesn't look much like the code many of us are used to in Java, JavaScript, C#, Python, Ruby, etc. Terms like _functor_, _monoid_, and _monad_ can add to the impression that it's something really complicated.

Luckily I ran across Miran’s tutorial. It's definitely the friendliest introduction to Haskell out there. While the book isn't perfect - nothing is - I found it to be quite accessible in introducing the core concepts behind Haskell. 

These notes are not comprehensive - they're just kind of a brain dump of the things that stood out for me, either for being interesting, useful, or tricky. I also included some of my own thoughts, observations, and code samples. Discussion, as always, is welcome!

_LYAHFGG!_ is available for free online, or can be purchased as an e-book from the official Web site. Used [print versions](https://www.amazon.com/Learn-You-Haskell-Great-Good/dp/1593272839/ref=sr_1_1?ie=UTF8&qid=1543472622&sr=8-1&keywords=learn+you+a+haskell) are also available at Amazon.

_LYAHFGG!_ has a flat structure of 14 chapters, but I tend to think of it more in terms of 3 big parts:

1. Chapters 1-7: Intro to types and typeclasses; pattern matching; recursion; higher-order functions; modules
2. Chapters 8-10: Making our own types and typeclasses; I/O; solving problems
3. Chapters 11-14: Monoids; functors; applicative functors; monads; zippers 

I found the first two parts fairly easy to get through, but on my first attempt I ran out of steam when I reached the chapters about functors and monads (11 and 12). I took some time away and returned to it later, determined to make it to the end this time. On the second try, it wasn't so bad. I just had to take my time and work through everything carefully and in detail.

## Part I

These early chapters are about getting started. Miran does a great job of jumping right into Haskell code in a gentle way that avoids intimidating theory or notation. We are introduced to functions, pattern matching, and conditional logic. 

### Recursion and Higher-Order Functions

There is also an introduction to recursive functions and the holy trinity of higher-order functions, `map`, `filter` and `fold` (also known as `reduce` in some languages). 

### Pattern Matching

For me, the pattern matching was the most unusual feature in this part of the book. Since values in Haskell are immutable, it is possible to match a value against the way it was constructed in the first place! This feature is used a lot in Haskell.

For example, we can define a custom list type and use it to create a list consisting of the values 3, 4, and 5 as follows:

```haskell
Prelude> data List a = EmptyList | Cons a (List a) deriving (Show, Read, Eq)
Prelude> items = Cons 3 (Cons 4 (Cons 5 EmptyList))
```

We can pattern match as follows to get the second item in a list:

```haskell
Prelude> secondItem (Cons first (Cons second rest)) = second
Prelude> secondItem items
4
```

### 100% Pure

The introduction mentions that all functions in Haskell are _pure_. It’s easy to miss the significance of this though. That means functions can never have any direct side effects at all. If a function looks as though it’s doing I/O, don’t be fooled, it's not - at least not directly! 

Instead such functions return _actions_. We can imagine these as data structures that describe what the desired side effects are. When the Haskell runtime executes an action, that’s when it will actually perform the I/O, but it's done as a separate step. I think it’s worth emphasizing this point. It strikes me as the most distinctive aspect of Haskell.

### Lazy Evaluation

Another very unusual core aspect of Haskell is _laziness_. In Haskell a function is only evaluated enough to satisfy the demands of the `main` action (by default, at least). That means we can write functions that recurse forever without a base case, like the following:

```haskell
Prelude> recurseForever n = n  : recurseForever (n+1)
Prelude> print $ take 3 $ recurseForever 5
[5,6,7]
```

> We can omit `print` in [ghci](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/ghci.html) and the result will be the same. The [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) will automatically make this into a print action for us.

To satisfy the action returned by `print`, we need to get 3 items from `recurseForever`. Once we have these items, the evaluation stops. If we call a function, but its result is never actually used by an action, then the function call is not evaluated at all. 

When we call a function in Haskell, we don't get the final result of the call directly the way we might expect. Instead, we get an unevaluated expression, sometimes called a _thunk_. The evaluation of thunks is driven by the Haskell runtime when it is executing the actions produced by `main`.

### Currying

Also of note is the fact that, in Haskell, all functions are automatically _curried_. A function that seems to take three arguments actually takes a single argument and returns a function with a single argument, which finally returns a function with a single argument!

Each of these functions captures the parameter passed in from the enclosing scope when it is returned. Because of this, I think it may help to be already familiar with _closures_ from another language like JavaScript or Python. 

Currying in Haskell allows writing code in a very terse _point free_ notation. It also means that parameters can be partially applied to a function without the need to first wrap it in a lambda.

> Point free notation can be nice, but it can also be misused to make code harder to understand. Converting _everything_ indiscriminately to point free form is an anti-pattern and should be avoided.

In the code below, `2` is partially applied to the multiplication function `(*)`. `map` then completes the job by applying each of the items in the list as a second parameter to the multiplication:

```haskell
Prelude> print $ take 5 $ map (*2) [0..]
[0,2,4,6,8]
```
### Composition

Currying makes it rather easy to compose functions, that is to generate a single function that combines a bunch of functions together. To compose functions, we use the higher-order function `.`. Here's an example of how composition can be used to quickly wrap the previous example into a single function:

```haskell
Prelude> composed = print . take 5 . map (*2)
Prelude> composed [0..]
[0,2,4,6,8]
```

### Type Variables

Haskell makes it easy to create parameterized types. These are similar to templates in C++ or generics in Java.

### Type Inference

One really cool thing about Haskell is its use of type inference. This means that  we don't have to explicitly define types everywhere. The compiler can, in many cases, figure it out for us from the way the code is used. This feature, in addition to the repl, makes Haskell feel more like JavaScript or Python than a typical statically typed language. 

## Part II

This part of the book includes creating custom types and typeclasses (_interfaces_ are the analogous concept in languages like Java and C++). How I/O works in Haskell is also discussed. Lastly, a couple of problems are worked out, an RPN calculator and a path-finding algorithm.

### I/O 

The idea of _actions_ is introduced here. Basically `main` produces an action - which could be a compound of several other actions. The Haskell runtime then actually executes this action. Everything else that happens derives from the evaluation of functions needed to complete this action.

### Types and Typeclasses

To me, the detailed discussion of types and typeclasses is the most significant part of this section of the book. In particular, Miran mentions that value constructors in Haskell are also just functions. For instance, the `Just` in `Just 3` is a function. I missed that on first reading and became a bit confused later on in the `State` monad discussion.

Along the same lines, it's useful to keep in mind that functions are first-class citizens in Haskell, so a value constructor can contain functions just as well as any other values.

Record syntax is another area where I found it was easy to get confused. It's helpful to remember that record syntax is just syntactic sugar around regular value constructors. It automatically adds functions that produce the desired values.

To illustrate the above points, I've created a small example. `TypeWithFunctions` is a data type that contains two functions as a values. `Val` is the value constructor. The function `getF1` extracts the first function, and `getF2` extracts the second function from a `TypeWithFunctions` value:

```haskell
Prelude> data TypeWithFunctions = Val (Int->Int) (Int->Int)
Prelude> getF1 (Val f _) p = f p
Prelude> getF2 (Val _ f) p = f p
Prelude> vwf = Val (\x->x+1) (\x->x*2)
Prelude> getF1 vwf 3
4
Prelude> getF2 vwf 3
6
```

Alternatively, we can use record syntax to accomplish the same result. Here we create our custom `TypeWithFunctions` using record syntax. Haskell will automatically create the functions `getF1` and `getF2` to return their corresponding values (also functions). The code below is equivalent to the previous example:

```haskell
Prelude> data TypeWithFunctions = Val { getF1 :: Int->Int, getF2 :: Int->Int }
Prelude> vwf = Val {getF1 = \x->x+1, getF2 = \x->x*2}
Prelude> getF1 vwf 3
4
Prelude> getF2 vwf 3
6
```

Another interesting idea is that value constructors can reference their own type, which lets us build recursive data structures. For instance: 

```haskell
data Tree a = EmptyTree | Node a (Tree a) (Tree a) deriving (Show, Read, Eq) 
```

Here the `Node` value constructor has three parameters: A value of type `a` that represents the value of the current node, as well as two values of type `Tree a`, which point us to more trees! These trees will resolve themselves into either `EmptyTree` values or they will become further nodes with two more trees branching from them. That's how a binary tree can be implemented in Haskell.

## Part III

This is the meatiest part of the book. It covers monoids, as well as functors, applicative functors, and monads. 

The last chapter shows how a _zipper_ can be used to traverse data structures.

### Partial Application of Type Constructors

There's a neat trick that's mentioned in the chapter about [`newtype`](http://learnyouahaskell.com/functors-applicative-functors-and-monoids#the-newtype-keyword) regarding typeclasses. Just as we can partially apply functions, we can partially apply type constructors. Here I've worked it out in a bit more detail than that book does. Let's start with the definition of the `Functor` typeclass:

```haskell
class Functor f where  
    fmap :: (a -> b) -> f a -> f b  
```

We can see here that `f` has to be a type with a single type parameter. 

Suppose we have a tuple representing a pair of values and each value in the pair may be of a different type. Let's try to make this tuple into a functor.

```haskell
Prelude> newtype Pair s n = Pair (s, n) deriving Show
Prelude> Pair ("hello", 3)
Pair ("hello", 3)
```

Since the tuple is parameterized to two types `s` and `n`, we can't use it directly to implement the `Functor` typeclass. However, we can partially bind its type to a single parameter so that `fmap` is free to operate over the other value in the tuple. Below we partially apply `s` (the type of the first value in the tuple) to `Pair`. The result is a type that needs one more type parameter. We can therefore implement the `Functor` typeclass for this type:


```haskell
Prelude> instance Functor (Pair s) where fmap f (Pair(x,y)) = Pair(x, f y)
Prelude> fmap (+3) (Pair("hello", 1))
Pair ("hello", 4)
```

What do we do if we want to map over the first value in the tuple rather than the second one? This is where the trick comes into play. We can reverse the order of the type parameters in the value constructor. This allows us to map over the first value in the tuple:

```haskell
Prelude> newtype Pair s n = Pair (n, s) deriving Show -- flipped order in value constructor
Prelude> Pair (3, "hello")
Pair (3, "hello")
Prelude> instance Functor (Pair s) where fmap f (Pair(x,y)) = Pair(f x, y)
Prelude> fmap (+3) (Pair(1, "hello"))
Pair (4, "hello")
```

### The Infamous `>>=` Function and `do` Notation

`do` notation is introduced earlier in the book in chapter 9 in the context of I/O. Here we learn that the `do` syntax is only syntactic sugar for an expression that returns a monad. 

I/O actions happen to be one type of monad but the `do` syntax can be used to _sequentially_ chain together functions that operate on any monads we like. 

Let's take a look at an action `multWithLog` that produces a monad called `WWriter`. We'll avoid the built-in `Writer` in Haskell and roll our own for this example:

```haskell
import Control.Monad (liftM, ap)

main = print $ runWriter $ multWithLog

multWithLog = do
    a <- logNumber 3
    b <- logNumber 5
    c <- logNumber 8
    tell ["Let's multiply these numbers"]
    return (a * b * c)

tell xs = WWriter ((), xs)

logNumber n = WWriter (n, ["Got number: " ++ show n])

newtype WWriter logs result = WWriter { runWriter :: (result, logs) }

instance (Monoid w) => Functor (WWriter w) where
    fmap = liftM

instance (Monoid w) => Applicative (WWriter w) where
    pure = return
    (<*>) = ap

instance (Monoid w) => Monad (WWriter w) where
    return result = WWriter (result, mempty)
    (WWriter (r, l)) >>= f = let (WWriter (r', l')) = f r in WWriter (r', l <> l')
```

> When _LYAHFGG!_ was written, I think that the `Monad` typeclass did not explicitly extend `Applicative`. Now it does, so if we want to turn a type into a Monad, we also have to implement `Functor` and `Applicative` for it. It turns out that this is easy to do using `liftM` and `ap`.

The result of running this code looks _kind of_ as expected:

```
C:\Dev\haskell>ghc writer_example.hs
[1 of 1] Compiling Main             ( writer_example.hs, writer_example.o )
Linking writer_example.exe ...

C:\Dev\haskell>writer_example.exe
(120,["Got number: 3","Got number: 5","Got number: 8","Let's multiply these numbers"])
```

It's easy to imagine that this code is equivalent to the following JavaScript:

```javascript
console.log(multWithLog())

const multWithLog = () => {
    a = logNumber(3)
    b = logNumber(5)
    c = logNumber(8)
    console.log("Let's multiply these numbers")
    return a * b * c
}

const logNumber = n => {
    console.log("Got number: " + n)
    return n
}
```

It's not, though: We can't do I/O directly in Haskell. `do` notation can easily be converted into calls to `bind` aka `>>=`. The Haskell `do` notation code in `multWithLog` can be rewritten as follows:

```haskell
multWithLog = logNumber 3 >>=
  \a -> logNumber 5 >>=
    \b -> logNumber 8 >>=
      \c -> tell ["Let's multiply these numbers"] >>=
        \_ -> return (a * b * c)
``` 

What's going on here? To try to make it more clear, I've translated the example as closely as I could into JavaScript below:

```javascript
const multWithLog = () => {
  const w = chain (logNumber(3), a =>
    chain(logNumber(5), b =>
      chain(logNumber(8), c =>
        chain(tell(["Let's multiply these numbers"]), _ =>
          monad(a*b*c)))))

  return w
}

const Writer = function (result, logs) {
  this.result = result
  this.logs = logs
}

// equivalent of Haskell "return"
const monad = n => new Writer(n, [])

//equivalent of Haskell ">>="
const chain = (writer, f) => {
  const r = writer.result
  const l = writer.logs
  const newWriter = f(r)
  return new Writer(newWriter.result, l.concat(newWriter.logs))
}

const logNumber = n => new Writer(n, ["Got number: " + n])

const tell = logs => new Writer([], logs)

console.log(multWithLog())
```

> The `>>=` function is called _bind_ in Haskell, but here I've named it `chain` since JavaScript has its own, unrelated, `bind` function. Haskell also uses the (really poorly named) `return` function to put a value into a minimal monadic context. Of course `return` is reserved, so I've called this function `monad` instead. 

Now all of the Javascript functions are pure, like the Haskell code, and getting `w` doesn't produce any side effects. The result is just a `Writer` object:

```
C:\Dev\js\fp>node monad_writer.js
Writer {
  result: 120,
  logs:
   [ 'Got number: 3',
     'Got number: 5',
     'Got number: 8',
     'Let\'s multiply these numbers' ] }
```

We made all of our functions pure, but we can also clearly see the emergence of the dreaded _callback hell_ in this JavaScript code: We pass a callback to `chain`, and in this callback, we do another _chain_ that takes another callback, and so on. What's worse, since we need the parameters `a`, `b`, `c` etc. to be visible in each nested scope, the callbacks have to remain inlined. They can't simply be extracted into separate named functions. It's rather a mess, and I think it shows why Haskell introduced the `do` syntax. 

The upshot of all this seems to be that we can kind of contort Haskell into looking like everyday procedural code! 😊 We do this at the expense of a higher level of complexity. Granted, we can cover up some of that complexity with syntactic sugar, but it's still there. 

> I believe this kind of Haskell code does impose a greater mental burden on the programmer to accomplish tasks that would be pretty simple in an imperative language. If I understand correctly, the tradeoff is that we get purity in exchange. I'm not convinced this tradeoff is always worthwhile. I'm sure there are cases where it does offer significant benefits, but it's not obvious to me that it's something we should be aiming for all the time. 
> 
> I can understand the value of separating _business logic_ into pure functions and having the I/O code call these functions. What's less clear to me is the value of every piece of code that does I/O returning an action that gets executed later. 
> 
> At the very least, I think the greater levels of indirection make such Haskell code harder to maintain. In fact, that's not even the end of the story. _LYAHFGG!_ doesn't cover monad transformers, which add an additional level of indirection! 

### Functions _as_ Functors, Applicatives, and Monads

While the terms _monoid_, _functor_, _applicative_, and _monad_ may sound foreign and complicated, for the most part this book does a good job of taking the mystery out of them. First we learn about how to think of simple types like `Maybe`, `Either`, and lists as functors, applicative functors, and monads. In this sense, they are nothing more than container types that allow us to apply mappings to the values they contain in a standardized, predictable way. 

Things got a bit trickier for me when it turned out that the concept of a function itself, `(->) r`, could be treated as a functor, applicative functor, and monad. The book doesn't show the derivations in detail, so I ended up working this stuff out for myself in a lot more detail. For me, it was the most challenging part of the whole experience. 

Below are all of the implementations:

```haskell
instance Functor ((->) r) where  
    fmap = (.)  

instance Applicative ((->) r) where  
    pure x = (\_ -> x)  
    f <*> g = \x -> f x (g x)  

instance Monad ((->) r) where  
    return x = \_ -> x  
    g >>= f = \x -> f (g x) x 
```

The idea here is that the function becomes the context or container for values. In the same way that we can extract `3` from `Just 3`, we can extract a value from a function `(->) r` by calling it. 

When all is said and done, `fmap` (aka `<$>`) for functions is implemented as function composition. `<*>` turns out to be a rather odd function I was unfamiliar with. I looked it up, and it is apparently called an [S combinator](https://en.wikipedia.org/wiki/SKI_combinator_calculus). And, that last one, it looks familiar, doesn't it? Indeed, it's our S combinator with the arguments flipped around!

```haskell
Prelude> f <*> g = \x -> f x (g x)
Prelude> a = \x->(\y->x+y)
Prelude> b = \x->x*2
Prelude> resultingF = a <*> b
Prelude> resultingF 12
36
Prelude> g >>= f = \x -> f (g x) x
Prelude> resultingF = b >>= a
Prelude> resultingF 12
36
```

For functions, we can also just implement `<*>` as: 

```haskell
Prelude> (<*>) = flip (>>=)
```

The funny thing is that while these results for `(->) r` are interesting, I don't think they come up in real-world programming problems much. However, I do think it's worth it to make the effort to develop a decent understanding of this aspect of Haskell. For one thing, it makes it clear how orthogonal Haskell is, and how central functions are to everything in Haskell. In that sense, realizing that functions can be implemented as instances of these typeclasses is important. 

> In fact, both lists and functions can be implemented as monads in more than one way (`newtype` can be used when we want to create multiple implementations of a given typeclass for the same underlying type, e.g. see [ZipList](http://learnyouahaskell.com/functors-applicative-functors-and-monoids#the-newtype-keyword) ).

I think this topic that functions can be functors, applicatives, and monads could have been placed into its own chapter. As it stands, it's discussed separately in the chapters about functors, applicatives, and monads. As I was reading, there was nothing to emphasize that this was something a bit harder to digest than the material around it and I almost missed it. I remember that I was going along a bit complacently with my reading at the time, and suddenly went, "wait, what?" 😊

### Monads &gt; Applicatives &gt; Functors

It turns out that as we go from functors, to applicative functors, to monads, we get increasingly powerful constructions. If we have implemented the `Monad` typeclass for a given type, then we can use it to implement the functor and applicative functor typeclasses.

I'm not sure that the way this is presented in _LYAHFGG!_ is as clear as it could be. I found [this explanation](https://en.wikibooks.org/wiki/Haskell/Applicative_functors#A_sliding_scale_of_power) from the [Haskell Wikibook](https://en.wikibooks.org/wiki/Haskell) to be both clear and concise: 

> _The day-to-day differences in uses of Functor, Applicative and Monad follow from what the types of those three mapping functions allow you to do. As you move from fmap to (<*>) and then to (>>=), you gain in power, versatility and control, at the cost of guarantees about the results._

I've already shown an example for `WWriter` that demonstrates how, once we implement the `Monad` typeclass, we get `Functor` and `Applicative` for free. Below is a another working example for a _state_ monad. I've called it `SState` to distinguish it from the built-in `State` type:

```haskell
import System.Random

import Control.Applicative
import Control.Monad (liftM, ap)

main = print $ runState threeCoins (mkStdGen 33)

threeCoins :: SState StdGen (Bool, Bool, Bool)
threeCoins = do
    a <- randomSt
    b <- randomSt
    c <- randomSt
    return (a,b,c)

randomSt :: (RandomGen g, Random a) => SState g a  
randomSt = SState random

newtype SState s a = SState { runState :: s -> (a,s) }  

instance Functor (SState s) where
    fmap = liftM
       
instance Applicative (SState s) where
    pure = return
    (<*>) = ap

instance Monad (SState s) where  
    return x = SState $ \s -> (x,s)  
    (SState h) >>= f = SState $ \s -> let (a, newState) = h s  
                                          (SState g) = f a  
                                      in  g newState 
```
 
> Note how `SState` is just a wrapper around a function. This threw me for a loop when I first encountered it, and I don't think it's directly mentioned in _LYAHFGG!_ prior to this. That's why I discuss `TypeWithFunctions` in a bit more detail earlier in this article.

Let's compile and run it:

```
C:\Dev\haskell>ghc random_state.hs
[1 of 1] Compiling Main             ( random_state.hs, random_state.o )
Linking random_state.exe ...

C:\Dev\haskell>random_state.exe
((True,False,True),680029187 2103410263)
```

Below are the implementations for `liftM` and `ap`:

```haskell
liftM :: (Monad m) => (a -> b) -> m a -> m b  
liftM f m = m >>= (\x -> return (f x))

ap :: (Monad m) => m (a -> b) -> m a -> m b  
ap mf m = mf >>= \f -> m >>= \x -> return (f x)  
```

### The Laws

For each of the big 3 typeclasses, `Functor`, `Applicative`, and `Monad`, in addition to the type definition, there are rules that should be followed when implementing them. These are called the _laws_ for functors, applicatives, and monads. Haskell doesn't enforce these laws, so it's possible to implement these typeclasses in a way that doesn't conform to them. However these rules should be followed. Otherwise a programmer using a given typeclass can end up running into unexpected behaviours. 

_LYAHFGG!_ tends to intersperse these laws in between examples. I understand that the goal of the book is to focus on practical use rather than theory or exposition, but I did find this a bit confusing. Here are all of the typeclasses and related laws all in one place: 

{% gist 8d1ac438dec30027e304c489fca23cfb %}

### Zippers

The last chapter in _LYAHFGG!_ covers _zippers_. In Haskell, there isn't the concept of a variable that can reference a value. This is something that's pretty fundamental to most programming languages, but it just doesn't exist in Haskell! That's the extent to which Haskell emphasizes statelessness and purity. 

For example, say we have a linked list that we want to traverse. Normally we might create a variable that points to the front of the list and then we re-assign that variable in a loop to point to each successive node. That idea doesn't exist in Haskell. 

Instead we end up creating a completely new copy of our list each time. We have a value that represents our _current_ list, and we also keep around a list that represents the nodes that we've visited so far, in order of most recent to least recent. Moving back and forth across the list involves shuffling items between these two values. Each move creates a completely new copy of both lists. 

Since this can obviously be terribly inefficient, I looked into it, and Haskell does have libraries that allow for higher performance when working with data structures, though I don't think _LYAHFGG!_ goes into this topic at all. 

I found this comment from a [reddit thread](https://www.reddit.com/r/haskell/comments/4j9n9a/is_haskell_able_to_deal_with_big_data_structures/) about data structures in Haskell instructive:

> _So the vector package implements sorting with mutable arrays to circumvent this problem, and it's possibly the fastest implementation around. It's able to do this without really "cheating" — it uses the ST monad, so it's still pure and safe from perspective of the caller — but it's certainly not simple, and I'm not sure I can call it elegant either, except in the sense that it's able to do this with the power of the tools that Haskell and various libraries gives you._

## What's Broken?

There are some examples in _LYAHFGG!_ that don't work as-is, although fixing them was not a big problem. There are mainly two things that have changed in Haskell since this book was written:

1. Monads now also have to be applicative functors. This was the case in practice at the time the book was written, but it was not formally required. Now the code won't compile if we try to implement something as `Monad` but we don't make it an `Applicative` and a `Functor` also.
2. The value constructors for built-in monads like `State` or `Writer` are no longer exported for public use. Instead we have to use functions like `state` and `writer` to produce these monads. It has to do with the fact that the built-in monads now appear to be wrapped in _monad transformers_, which are not covered in the book (they must be something more recent in Haskell). 

Here's an example:

```haskell
Prelude> import Control.Monad.Writer
Prelude Control.Monad.Writer> w = writer (3, ["hello"]) :: Writer [String] Int
Prelude Control.Monad.Writer> w >>= \_ -> tell ["goodbye"]
WriterT (Identity ((),["hello","goodbye"]))
Prelude Control.Monad.Writer> w >>= \x -> writer(x+1, ["goodbye"])
WriterT (Identity (4,["hello","goodbye"]))
```

Above we can see that we have to use the `writer` function to create a `Writer` monad. We can also see that `>>=` produces, `WriterT`, a monad transformer rather than just a regular monad. 

## Pet Peeves

My biggest pet peeve with _LYAHFGG!_ is that there are several places in the book that suddenly start listing a whole bunch of standard functions. I found this very annoying. It would have been nice for that kind of thing to have been moved into a separate glossary.

## Conclusion

While _LYAHFGG!_ isn't enough to really start doing serious programming in Haskell, I do think it establishes a good foundation from which to go further. I found the [Haskell Wikibook](https://en.wikibooks.org/wiki/Haskell) to be a helpful resource for more in-depth background information. While I haven't read it yet, [Real World Haskell](http://book.realworldhaskell.org/read/), seems to be a good way to get started writing practical code in Haskell. 

Overall, while I'm not convinced such a purely functional language as Haskell is appropriate for many everyday programming tasks, I'm glad it exists. It's _really_ pure and very orthogonal: Any piece of code can be decomposed into function calls. Functions can also be treated like any other values. We can't change a value once it's been created. We can't directly produce any side effects, etc. I think Haskell is at the very least a good playground from which to learn lessons about ways that the functional/declarative approach can be helpful and also to find out more about the kinds of situations in which it may be a hindrance. 

Because the core syntax of Haskell is quite minimal, I think it's a good platform on which to learn about things like functors and monads, and to understand the context 😊 in which they're used. Learning Haskell could also be a good first step before getting into other languages, like Clojure, Scala, Elm, F#, and Erlang/Elixir, that are known for taking significant inspiration from functional programming.

## Related

* [Currying in Haskell (With Some JavaScript)]({% link _posts/2018-05-02-currying-in-haskell-with-some-javascript-4moj.28500.md %})

## Links

* [Learn You a Haskell for Great Good!](http://learnyouahaskell.com/)
* [Haskell Wikibooks](https://en.wikibooks.org/wiki/Haskell)
* [Real World Haskell](http://book.realworldhaskell.org/read/)
* [Hoogle](https://www.haskell.org/hoogle/)
* [Hackage](https://hackage.haskell.org/)
