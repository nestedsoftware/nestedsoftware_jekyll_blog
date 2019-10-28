---
title: Lazy Evaluation in JavaScript with Generators, Map, Filter, and Reduce
published: true
description: A simple wrapper class in JavaScript for map, filter, and reduce
cover_image: /assets/images/2018-02-27-lazy-evaluation-in-javascript-with-generators-map-filter-and-reduce--36h5.21002/qibwx9lwo3mi62m77tbh.jpg
canonical_url: https://nestedsoftware.github.io/2018/02/27/lazy-evaluation-in-javascript-with-generators-map-filter-and-reduce-36h5.21002.html
tags: javascript, map, filter, reduce
---

My friend [edA-qa](https://dev.to/mortoray) was recently doing some programming live using the Rust language on [twitch](https://www.twitch.tv/mortoray). An interesting bit of code came up: 

```rust
(1..).filter(|num| num%2 == 0).take(n).sum() 
```

We can see that some operations are taking place on an unbounded range of numbers: `(1..)`, in other words, starting at 1 and going on forever. This kind of code is part of the functional programming paradigm, and takes advantage of 'lazy evaluation', where an expression is only actually calculated on an as-needed basis.

I have been doing some programming in JavaScript lately, and I became curious if this would work in JavaScript too. I knew JavaScript had functions like [filter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter), [map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map), and [reduce](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce) that worked with arrays, but I wondered if they would work with [generators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_Generators) too.

It turns out they don't right now, at least not out of the box. Let's say we have a generator that just produces integers starting at 1:

```javascript
const numbers = function* () {
	let i = 1
	while (true) {
		yield i++ 
	}
}
```
Can we use this directly to do operations like filter and map?

```javascript
let result = numbers.map(num=>num**2).slice(0,3) //doesn't work :(
console.log('result = ' + result)
```

This produces: 

```
let result = numbers.map(num=>num**2).slice(0,3) //doesn't work :(
                 ^

TypeError: numbers.map is not a function
    at Object.<anonymous> (C:\dev\lazy.js:66:18)
```

Trying to start the generator first also doesn't work:

```javascript
let result = numbers().map(num=>num**2).slice(0,3) //doesn't work :(
console.log('result = ' + result)
```
This produces:

```
TypeError: numbers(...).map is not a function
    at Object.<anonymous> (C:\dev\lazy.js:66:20)
```

I decided to write a simple class wrapper in JavaScript to make functionality similar to the Rust example possible.

The `Lazy` class below acts as a base class for the desired behaviour.

```javascript
class Lazy {
	constructor(iterable, callback) {
		this.iterable = iterable
		this.callback = callback
	}

	filter(callback) {
		return new LazyFilter(this, callback)
	}

	map(callback) {
		return new LazyMap(this, callback)
	}

	next() {
		return this.iterable.next()
	}

	take(n) {
		const values = []
		for (let i=0; i<n; i++) {
			values.push(this.next().value)
		}

		return values
	}
}  
```        

The `Lazy` class just wraps a simple JavaScript iterable (see [iteration protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols) ). By default, if you call its `next` method, it will just delegate that call to the iterable that it's wrapped around.      

Notice that by themselves, calls to `filter` and `map` won't do much: They'll just instantiate an object. Below are the implementations of `LazyFilter` and `LazyMap`:

```javascript
class LazyFilter extends Lazy {
	next() {
		while (true) {
			const item = this.iterable.next()

			if (this.callback(item.value)) {
				return item
			}
		}
	}
}

class LazyMap extends Lazy {
	next() {
		const item = this.iterable.next()

		const mappedValue = this.callback(item.value)
		return { value: mappedValue, done: item.done }
	}
}

```
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
Both of these subclasses also just implement JavaScript's `next` method. 

Now let's see this code in action! Below are some simple examples that run this code:


```javascript

let result = new Lazy(numbers()).map(num=>num*3).take(4).reduce((a,v) => a + v)
console.log('result = ' + result)

result = new Lazy(numbers()).filter(n=>n%2==0).take(4).reduce((a,v) => a + v)
console.log('result = ' + result)

result = new Lazy(numbers()).filter(n=>n%2==0).map(num=>num**2).take(4).reduce((a,v) => a + v)
console.log('result = ' + result)

result = new Lazy(numbers()).map(num=>num**2).filter(n=>n%2==0).take(4).reduce((a,v) => a + v)
console.log('result = ' + result)

```


Here are the results of running this example in node:


```
C:\dev>node lazy.js
result = 30
result = 20
result = 120
result = 120
```

In case you're unfamiliar with this type of code, I'll try to clarify how it works. Let's look at the first example: 

```javascript
let result = new Lazy(numbers()).map(num=>num*3).take(4).reduce((a,v) => a + v)
console.log('result = ' + result)
```

First, let's look at the `take` function. This function starts everything off. Prior to `take` being called, nothing will happen other than some objects getting created. 

The `take` function will call `next` 4 times on the `LazyMap` object returned by `map(num=>num*3)`. This in turn will call `next` 4 times on the generator returned by `numbers()`. `map` will pass each of those numbers from the generator to the `num=>num*3` callback, which will multiply each number by 3 before, in turn, passing the result back to `take`. Take returns a normal JavaScript array. In this case it will contain `[3,6,9,12]`. Now we can call the `Array.reduce` method, which collapses the array to a single value using the supplied callback. In this case all the numbers are added together to produce the final result of '30'. 

>There are a few potential 'gotchas' to be aware of: First, trying to call `reduce` on a generator that doesn't stop would not work, since the `reduce` function would never run out of values to process. However, we could write a version of reduce that iteratively collapses values. Also, it's important to be careful when using `filter`. `filter` won't stop until  it reaches a value that matches its callback. If we try to call `filter` on a generator that runs forever, and it doesn't find any matches, then `filter` will just run forever too, causing our program to hang.

I think it would be more elegant for JavaScript to support any iterable as a target for functions like `map` and `filter`, and possibly even `reduce`, not just arrays. Maybe Mozilla will do that in a subsequent release, along with nice syntactic sugar like the Rust `(1..)` syntax for unbounded lazy ranges.

Related:

* [How to Serialize Concurrent Operations in JavaScript: Callbacks, Promises, and Async/Await]({% link _posts/2018-03-05-how-to-serialize-concurrent-operations-in-javascript-callbacks-promises-and-asyncawait-3ge3.21305.md %})
* [Careful Examination of JavaScript Await]({% link _posts/2018-04-06-careful-examination-of-javascript-await--109.25561.md %})
* [The Iterators Are Coming! [Symbol.iterator] and [Symbol.asyncIterator] in JavaScript]({% link _posts/2018-04-15-the-iterators-are-coming-symboliterator-and-symbolasynciterator-in-javascript-hj.26637.md %})
* [Asynchronous Generators and Pipelines in JavaScript]({% link _posts/2018-04-23-asynchronous-generators-and-pipelines-in-javascript--1h62.26991.md %})