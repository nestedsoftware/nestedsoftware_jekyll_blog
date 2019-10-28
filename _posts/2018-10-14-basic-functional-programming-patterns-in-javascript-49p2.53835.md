---
title: Basic Functional Programming Patterns in JavaScript
published: true
cover_image: /assets/images/2018-10-14-basic-functional-programming-patterns-in-javascript-49p2.53835/yy0mf7thtohs0ov0o99v.jpg
description: Using functional programming patterns for iteration
canonical_url: https://nestedsoftware.github.io/2018/10/14/basic-functional-programming-patterns-in-javascript-49p2.53835.html
tags: javascript, functional, beginners, reduce
---

Several years ago, I found a helpful [tutorial](https://github.com/tokland/tokland/wiki/RubyFunctionalProgramming) by [Arnau Sanchez](https://github.com/tokland) that showed how common procedural programming patterns could be replaced with a functional approach. The tutorial is in Ruby. Recently I was reminded of it, and I thought I'd convert some examples from that tutorial to JavaScript (the text of this article, however, is original content).

## Pure Functions

At the core of functional programming is the notion of a [pure function](https://www.sitepoint.com/functional-programming-pure-functions/). Pure functions have a couple of characteristics:

* We can call a pure function over and over again, and as long as the parameters are the same, it will always return the same value. That means a function that gets a user's input, or obtains the current system time, or retrieves the value of a particular stock is not pure: These functions aren't guaranteed to return the same information every time, even if we call them with the same arguments.
* A pure function doesn't have side effects: If a function prints something to the screen, or saves to the database, or sends a text message, then it's not pure. Another example is statefulness: If calling a function changes a variable outside the scope of that function, that's also a side effect: The world isn't the same after that function has been called, so it isn't pure. 

Because they're so simple, pure functions have a lot of potential [benefits](https://alvinalexander.com/scala/fp-book/benefits-of-pure-functions): They're easier to understand and test. They're also easy to cache (memoize). Having pure functions is helpful in multithreading/multiprocessing since they don't need to synchronize on shared state. There are other benefits as well, including possible compiler optimizations. The main benefit we'll explore in this article is how we can take advantage of functional techniques to reduce duplication and make our code cleaner and more maintainable. However, achieving this benefit may automatically yield some of the others.

So, pure functions are nice, but they are clearly limited: They can't be the totality of a software system. The big idea in functional programming is to take the more complicated and messier aspects of programming, such as dealing with state and side effects, and to define a clear interface between these messy parts and the rest of the code: We write pure functions and wrap some higher level code around them to take care of impure aspects of programming.

## Declarative vs. Imperative

Another characteristic that distinguishes functional from procedural programming is its emphasis on a declarative style of programming. In procedural programming, we often see imperative code that shows us how to do something. The declarative approach tells us what the result should look like. We will see this difference show up in the examples in this article. 

> People can and do write imperative code in functional languages, as well as declarative code in procedural languages! So this is more of a difference of emphasis than anything else. Functional programming tends to emphasize the declarative approach more.

## The Holy Trinity of Functional Programming

Iteration is in many ways the bread and butter of programming. In the examples below, we'll explore how to transform some familiar procedural iteration patterns using loops into a functional approach. The simplicity of these examples makes them great for a tutorial, but the core idea - that we can plug our pure functions into higher order abstractions - is at the very heart of functional programming.

>A higher order function is a function that takes another function as a parameter and/or returns another function. In JavaScript, functions are "first-class citizens." That means we can assign them to variables, create them inside of other functions, and pass them as arguments like any other object. If you're familiar with callbacks, then you've worked with higher order functions!

Iteration in functional programming relies on a holy trinity of higher order functions: [map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map), [filter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter), and [reduce](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce). Let's explore each in turn. Then we'll also look at a couple of simple variations:

## Init+each+push -> map

Let's convert a list to another list. For each item in our source list, we will apply some function to the item before putting it in our target list. For example, let’s take a list of strings and produce a list of the same strings in uppercase.

**Procedural**: We create an empty list that will hold our results. We loop through our source list. For each item, we apply a function to it and append that to our result list. 

```javascript
let uppercaseNames = []
for (let name of ['milu', 'rantanplan']) {
  uppercaseNames.push(name.toUpperCase())
}
console.log(uppercaseNames) // ['MILU', 'RANTANPLAN']
```

**Functional**: We execute a `map` operation on our source list. We supply a callback function to `map`. Behind the scenes, `map` will iterate through the source list and call our callback function with each item, adding it to the result list. The goal here is to extract the `for` loop boilerplate and to hide it behind a higher order function. What remains is for us just to write a pure function that contains the actual logic that we care about. 

```javascript
const uppercaseNames = ['milu', 'rantanplan'].map(name => name.toUpperCase())
console.log(uppercaseNames) // ['MILU', 'RANTANPLAN']
```

## Init+each+conditional push -> filter

Here we start with a source list and apply a filter to it: For each item, if it matches the criteria, we keep it, otherwise we exclude it from our result list.

**Procedural**: We set up an empty result list, then iterate through a source list and append matching items to our result list.

```javascript
let filteredNames = []
for (let name of ['milu', 'rantanplan']) {
  if (name.length === 4) {
    filteredNames.push(name)
  }
}
console.log(filteredNames) // ['milu']
```

**Functional**: We supply our matching logic in a callback to `filter`, and we let `filter` do the work of iterating through the array and applying the filtering callback as needed.

```javascript
const filteredNames = ['milu', 'rantanplan'].filter(name => name.length === 4)
console.log(filteredNames) // ['milu']
```

## Init+each+accumulate -> reduce

Let's take a list of strings and return the sum of the lengths of all of the strings. 

**Procedural**: We iterate in a loop, adding the length of each string to our `sumOfLengths` variable. 

```javascript
let sumOfLengths = 0
for (let name of ['milu', 'rantanplan']) {
  sumOfLengths += name.length
}
console.log(sumOfLengths) // 14
```

**Functional**: First we `map` our list to a list of lengths, then we pass that list to `reduce`. For each item, `reduce` runs the reducer callback that we supply, passing an accumulator object and the current item as parameters. Whatever we return from our reducer will replace the accumulator that's passed in for the next iteration. Again, we just supply a simple pure function as a callback and let reduce do the rest.

```javascript
const total = (acc, len) => len + acc

const sumOfLengths = ['milu', 'rantanplan'].map(v=>v.length).reduce(total, 0)
console.log(sumOfLengths) // 14
```

> `reduce` is very powerful. In fact, we can use it to write implementations of both `map` and `filter`. 

## Init+each+accumulate+push -> scan

Let's say instead of just getting the final total length, we want to keep track of the intermediate values also. In Haskell, we can use `scan`, but JavaScript doesn't have a built-in `scan` function. Let's build our own!

**Procedural**: We update a list with the running total in each iteration of a `for` loop.

```javascript
let lengths = [0]
let totalLength = 0
for (let name of ['milu', 'rantanplan']) {
  totalLength += name.length
  lengths.push(totalLength)
}
console.log(lengths) // [0, 4, 14]
```

**Functional**: The code looks very similar to the version using `reduce`. 

```javascript
const total = (acc, item) => acc + item.length

const lengths = ['milu', 'rantanplan'].scan(total, 0)
console.log(lengths) //[0, 4, 14]
```

Below is a possible implementation of `scan`: This time instead of just passing our callback to reduce directly, we wrap a new reducer, `appendAggregate`, around the callback. `appendAggregate` takes the array containing the running totals from the accumulator and creates a copy which includes the running total for the latest value. That way instead of getting a single value back from `reduce` at the end, we get an array of all the intermediate totals.

```javascript
Array.prototype.scan = function (callback, initialValue) {
  const appendAggregate = (acc, item) => {
    const aggregate = acc[acc.length-1] //get last item
    const newAggregate = callback(aggregate, item)
    return [...acc, newAggregate]
  }

  const accumulator = [initialValue]

  return this.reduce(appendAggregate, accumulator)
}
```

## Init+each+hash -> mash

Let's look at one last example. Suppose we want to convert a list to a map of key-value pairs. For each item, the key will be the item, and the value will be the result of processing that item somehow. In the following example we'll convert a list of strings to an object that has each string as a key and its length as the value. 

**Procedural**: We create an empty object. For each item in the list, we add that item to our object as a key along with its corresponding value. 

```javascript
const items = ['functional', 'programming', 'rules']

const process = item => item.length

let hash = {}
for (let item of items) {
  hash[item] = process(item)
}
console.log(hash) //{functional: 10, programming: 11, rules: 5}
```

**Functional**: We convert each item into an array that contains the key and the value. `mash` folds these tuples into an object where they become the actual key/value pairs.

```javascript
const items = ['functional', 'programming', 'rules']

const mashed = items.mash(item => [item, item.length])
console.log(mashed) // {functional: 10, programming: 11, rules: 5}

//also works: 
const alsoMashed = items.map(item => [item, item.length]).mash()
console.log(alsoMashed) // {functional: 10, programming: 11, rules: 5}
```

Let's look at a possible implementation of `mash`: We use the same trick we used for `scan`. This time we supply `addKeyValuePair` to `reduce`. Each time `reduce` executes this callback, it will create a new object that includes the existing values in the accumulator along with a new one corresponding to the current key-value pair.

```javascript
Array.prototype.mash = function(callback) {
    const addKeyValuePair = (acc, item) => {
        const [key, value] = callback ? callback(item) : item
        return {...acc, [key]: value}
    }

    return this.reduce(addKeyValuePair, {})
}
```
>The above two examples modify `Array.prototype` to support `scan` and `mash`. I don't recommend doing this kind of monkey patching in practice. Here I've done it for simplicity to make all of the examples look the same. In real applications, we could replace the array functions with versions that take the array as a parameter. These could be chained together with a `compose` function. To avoid reinventing the wheel, we could also use a 3rd party functional utility library such as [Ramda](https://ramdajs.com/).

## Discussion

The examples above hopefully were able to show how we can use functional programming to reduce boilerplate in everyday code, keeping it [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). Note that all of the callbacks in these examples are pure functions. That means they don't change the state of the outside world. In particular, `appendAggregate` and `addKeyValuePair` don't modify the accumulator object they receive as a parameter. Instead they create a copy of the object that has whatever changes are needed. 

> I won't elaborate on this point in this article, but this may be a good place to at least mention the difference between [deep and shallow copy](https://we-are.bookmyshow.com/understanding-deep-and-shallow-copy-in-javascript-13438bad941c). The example code using the spread syntax `...` is performing a shallow copy. In general, we should think about whether a function is creating side effects and also whether somehow the state that is passed in to a function could be altered by the outside world while the function is in progress. Since our reducers are not mutating the parameters that are passed in, and since JavaScript is single-threaded/non-preemptive, shallow copy should be ok here. However, this is an issue we should always take some care with.  

Using pure functions generally makes our lives as programmers easier. One downside however is that it can impact performance in certain cases: In our examples, when processing large lists, we would be creating a lot of short-lived objects that keep the garbage collector busy. Often, in this day and age of powerful computers with large amounts of RAM, this isn't a problem in practice. However, if it does become a problem, then we may have to make some design compromises.  

>Haskell, which is quite a pure functional language, takes advantage of the guaranteed purity and laziness of its functions to [optimize garbage collection](https://wiki.haskell.org/GHC/Memory_Management). However, since purity is not enforced in languages like JavaScript, that seems less likely to be feasible in, say, the V8 engine. 

## References

* [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
* [Pure Functions](https://www.sitepoint.com/functional-programming-pure-functions/)
* [The Benefits of Pure Functions](https://alvinalexander.com/scala/fp-book/benefits-of-pure-functions)
* [Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map), [filter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter), [reduce](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce)
* [Ruby Functional Programming](https://github.com/tokland/tokland/wiki/RubyFunctionalProgramming)
* [Ramda Functional JS Library](https://ramdajs.com/)
* [Shallow and Deep Copy in JavaScript](https://we-are.bookmyshow.com/understanding-deep-and-shallow-copy-in-javascript-13438bad941c)
* [Garbage Collection in Haskell](https://wiki.haskell.org/GHC/Memory_Management)


## Related

* [Functional Programming with Forms in React]({% link _posts/2018-10-02-forms-in-react-a-functional-programming-primer-183.52688.md %})

## More Advanced Applications of Functional Concepts

* [Redux](https://redux.js.org/introduction/motivation)
* [MapReduce](https://en.wikipedia.org/wiki/MapReduce)
* [Functional Reactive Programming](https://en.wikipedia.org/wiki/Functional_reactive_programming)
