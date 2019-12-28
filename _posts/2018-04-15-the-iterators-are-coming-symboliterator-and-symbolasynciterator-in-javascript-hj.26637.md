---
title: The Iterators Are Coming! Iterator and asyncIterator in JavaScript
published: true
description: Exploration of synchronous and asynchronous iteration in JavaScript
series: Asynchronous Iterators and Generators
cover_image: /assets/images/2018-04-15-the-iterators-are-coming-symboliterator-and-symbolasynciterator-in-javascript-hj.26637/qajkvzn46l1ql7k1rhtg.jpg
canonical_url: https://nestedsoftware.com/2018/04/15/the-iterators-are-coming-symboliterator-and-symbolasynciterator-in-javascript-hj.26637.html
tags: javascript, iterator, asyncIterator, forof
---

## Introduction

This article goes over two kinds of iterators in JavaScript: Synchronous and asynchronous. The former has been a part of JavaScript for a while. The latter is coming soon in ES2018. 

The [iteration protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols) in JavaScript is pretty basic. For the synchronous version, we just need to define a `next` function that returns a tuple with a `value` and a `done` flag. For example:

```javascript
class SimpleIterable {
	next() {
		return { value: 3, done: true }
	}
}  
```

However, a number of constructs in JavaScript expect an "iterable," and just having a `next` function isn't always good enough. The [`for...of`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of) syntax is a case in point. Let's try to use `for...of` to loop over one of our `SimpleIterable` objects:

```javascript
const iter = new SimpleIterable()
for (const value of iter) {
	console.log('value = ' + value)
}
```

The result is:

```
C:\dev>node iter.js
C:\dev\iter.js:8
for (const value of iter) {
                    ^
TypeError: iter is not iterable
    at Object.<anonymous> (C:\dev\iter.js:8:21)
```

## Synchronous Iterators

We can fix this by supplying a special function. The function is identified by the symbol, `Symbol.iterator`. By adding it to our class, we can make our iterable work with `for...of`:

```javascript
class SimpleIterable {
	next() {
		return { value: 3, done: true }
	}

	[Symbol.iterator]() {
		return {
			next: () => this.next()
		}
	}
}
```
> What is this `[Symbol.iterator]` syntax? Symbol.iterator is a unique identifier (see [Symbol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol) ). Putting it in square brackets makes it a computed property name. Computed properties were added in ES2015 (see [Object initializer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Object_initializer) ). The documentation provides this simple example:
>
> `// Computed property names (ES2015)`
> `var prop = 'foo';`
> `var o = {`
> `  [prop]: 'hey',`
> `  ['b' + 'ar']: 'there'`
> `};`
> `console.log(o) // { foo: 'hey', bar: 'there' }`
>

Let's try it again:

```
C:\dev>node iter.js
```

That fixed our error, but we're still not outputting our value. It looks as though `for...of` ignores the `value` once it encounters a true `done` flag.

Let's make our example slightly more elaborate by actually iterating over a small array of values. When we exceed the bounds of our array, our `value` will become `undefined` and our `done` flag will be set to `true`:

```javascript
class SimpleIterable {
	constructor() {
		this.index = 0
		this.values = [3,1,4]
	}

	next() {
		const value = this.values[this.index]
		const done = !(this.index in this.values)
		this.index += 1
		return { value, done }
	}

	[Symbol.iterator]() {
		return {
			next: () => this.next()
		}
	}	
}

const iter = new SimpleIterable()
for (const value of iter) {
	console.log('value = ' + value)
}
```

Let's try it:

```
C:\dev>node iter.js
value = 3
value = 1
value = 4
```

Great, it worked!

## Asynchronous Iterators

Currently, JavaScript's iterators are synchronous, but [asynchronous iterators](https://github.com/tc39/proposal-async-iteration) are [coming in ES2018](http://2ality.com/2016/10/asynchronous-iteration.html). They are already implemented in recent versions of node, and we can play with them using the `--harmony-async-iteration` flag. Let's modify our existing example to use asynchronous iterators:

```javascript
const timer = () => setInterval(()=>console.log('tick'), 500)

class SimpleAsyncIterable {
	constructor() {
		this.index = 0
		this.values = [3,1,4]
	}

	next() {
		const value = this.values[this.index]
		const done = !(this.index in this.values)
		this.index += 1
		return new Promise(
			resolve=>setTimeout(()=>resolve({ value, done }), 1000))
	}

	[Symbol.asyncIterator]() {
		return {
			next: () => this.next()
		}
	}	
}

const main = async () => {
	const t = timer()

	const iter = new SimpleAsyncIterable()
	for await (const value of iter) {
		console.log('value = ' + value)
	}

	clearInterval(t)	
}

main()
```

What’s different?

* We can see that instead of just returning a `{value, done}` tuple, our `next` method now returns a promise that _resolves_ into a `{value, done}` tuple.
* Also, we now implement a `Symbol.asyncIterator` function instead of `Symbol.iterator`. 
* The syntax of `for...of` has been changed into an asynchronous form: `for await...of`. 

>Since we can only use `await` in a function that is marked `async`, I've moved the driving code into an `async` `main` function. I've also added a timer so that we can clearly see that the `for await...of` construct is non-blocking. 

Let's see our asynchronous iterable in action:
 

```
C:\dev>node --harmony-async-iteration asyncIter.js
tick
value = 3
tick
tick
value = 1
tick
tick
value = 4
tick
tick
```

Great, it worked! We can see that `for await...of` uses `Symbol.asyncIterator` to `await` each promise. If the `done` flag is false, `for await...of` will then retrieve the `value` on each iteration of the loop. Once it hits an object with a `done` flag of true, the loop ends.

> It is possible to achieve a similar effect using synchronous iterators by returning a promise for the `value` attribute. However, `done` would not be asynchronous in that case.

In an upcoming article, I will write a detailed examination of asynchronous generator functions, which can be used with this new `for await...of` syntax.

References:

* [for await...of](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for-await...of)
* [AsyncIterator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol/asyncIterator)
* [Iteration protocols](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols)
* [`for...of`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of)
* [Symbol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol)
* [Object initializer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Object_initializer)
* [Asynchronous iterators](https://github.com/tc39/proposal-async-iteration)
* [ES2018: asynchronous iteration](http://2ality.com/2016/10/asynchronous-iteration.html)

Related:

* [Lazy Evaluation in JavaScript with Generators, Map, Filter, and Reduce]({% link _posts/2018-02-27-lazy-evaluation-in-javascript-with-generators-map-filter-and-reduce--36h5.21002.md %})
* [How to Serialize Concurrent Operations in JavaScript: Callbacks, Promises, and Async/Await]({% link _posts/2018-03-05-how-to-serialize-concurrent-operations-in-javascript-callbacks-promises-and-asyncawait-3ge3.21305.md %})
* [Careful Examination of JavaScript Await]({% link _posts/2018-04-06-careful-examination-of-javascript-await--109.25561.md %})
* [Asynchronous Generators and Pipelines in JavaScript]({% link _posts/2018-04-23-asynchronous-generators-and-pipelines-in-javascript--1h62.26991.md %})
