---
title: Calculating Standard Deviation on Streaming Data
published: true
description: Derivation and sample code for an incremental running variance and standard deviation
series: Moving Average on Streaming Data
cover_image: /assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/10dau4xo3q14winpyy42.jpg
canonical_url: https://nestedsoftware.com/2018/03/27/calculating-standard-deviation-on-streaming-data-253l.23919.html
tags: javascript, math, statistics, standarddeviation
---
>This article is a continuation of the one about the [moving average]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %}), so it’s probably a good idea to read that one first.

In this article we will explore calculating variance and standard deviation incrementally. The idea is to provide a method that:

* Can calculate variance on a stream of data rather than needing all of the data to be available from the start.
* Is "numerically stable," that is, has fewer problems with precision when using floating point numbers. 

>The result I present in this article, known as "Welford's method," is slightly famous. It was originally devised by [B. P. Welford](http://www.jstor.org/stable/1266577?seq=1#page_scan_tab_contents) and popularized by [Knuth](https://en.wikipedia.org/wiki/Donald_Knuth) in [The Art of Computer Programming](https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming) (Volume 2, Seminumerical Algorithms, 3rd edn., p. 232.). 

The math for the derivation takes a bit longer this time, so for the impatient, I've decided to show the JavaScript code first. 

The core logic just requires us to add this extra bit of code to our `update` method:

```javascript
		const dSquaredIncrement = 
			(newValue - newMean) * (newValue - this._mean)

		const newDSquared = this._dSquared + dSquaredIncrement
```

It's interesting, right? In the formula for variance, we normally see the summation Σ(value<sub>i</sub> - mean)<sup>2</sup>. Intuitively, here we're kind of interpolating between the current value of the mean and the previous value instead. I think one could even stumble on to this result just by playing around, without rigorously deriving the formula. 

>What is `dSquared`? It's a term I made up for the variance * (n-1), or just n, depending on whether we're talking about [sample variance or population variance](https://en.wikipedia.org/wiki/Variance#Population_variance_and_sample_variance). We'll see this term in the mathematical derivation section further down in this article. Also see my article [The Geometry of Standard Deviation]({% link _posts/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736.md %}). 

Below is a simple implementation that calculates the mean, the variance, and the standard deviation incrementally as we receive values from a stream of data:

```javascript
class RunningStatsCalculator {
	constructor() {
		this.count = 0
		this._mean = 0
		this._dSquared = 0
	}

	update(newValue) {
		this.count++

		const meanDifferential = (newValue - this._mean) / this.count

		const newMean = this._mean + meanDifferential

		const dSquaredIncrement = 
			(newValue - newMean) * (newValue - this._mean)

		const newDSquared = this._dSquared + dSquaredIncrement

		this._mean = newMean

		this._dSquared = newDSquared
	}

	get mean() {
		this.validate()
		return this._mean
	}

	get dSquared() {
		this.validate()
		return this._dSquared
	}

	get populationVariance() {
		return this.dSquared / this.count
	}

	get populationStdev() {
		return Math.sqrt(this.populationVariance)
	}

	get sampleVariance() {
		return this.count > 1 ? this.dSquared / (this.count - 1) : 0
	}

	get sampleStdev() {
		return Math.sqrt(this.sampleVariance)
	}

	validate() {
		if (this.count == 0) {
			throw new StatsError('Mean is undefined')
		}
	}	
}

class StatsError extends Error {
	constructor(...params) {
		super(...params)

		if (Error.captureStackTrace) {
			Error.captureStackTrace(this, StatsError)
		}
	}
}


```

Let's also write the code for these statistics in the traditional way for comparison:

```javascript
const sum = values => values.reduce((a,b)=>a+b, 0)

const validate = values =>  {
	if (!values || values.length == 0) {
		throw new StatsError('Mean is undefined')
	}
}

const simpleMean = values => {
	validate(values)

	const mean = sum(values)/values.length

	return mean
}

const simpleStats = values => {
	const mean = simpleMean(values)

	const dSquared = sum(values.map(value=>(value-mean)**2))

	const populationVariance = dSquared / values.length
	const sampleVariance = values.length > 1 
		? dSquared / (values.length - 1) : 0

	const populationStdev = Math.sqrt(populationVariance)
	const sampleStdev = Math.sqrt(sampleVariance)

	return {
		mean,
		dSquared,
		populationVariance,
		sampleVariance,
		populationStdev,
		sampleStdev
	}
}
```

Now let's compare the results with a simple demo:

```javascript
const simple= simpleStats([1,2,3])

console.log('simple mean = ' + simple.mean)
console.log('simple dSquared = ' + simple.dSquared)
console.log('simple pop variance = ' + simple.populationVariance)
console.log('simple pop stdev = ' + simple.populationStdev)
console.log('simple sample variance = ' + simple.sampleVariance)
console.log('simple sample stdev = ' + simple.sampleStdev)
console.log('')

const running = new RunningStatsCalculator()
running.update(1)
running.update(2)
running.update(3)

console.log('running mean = ' + running.mean)
console.log('running dSquared = ' + running.dSquared)
console.log('running pop variance = ' + running.populationVariance)
console.log('running pop stdev = ' + running.populationStdev)
console.log('running sample variance = ' + running.sampleVariance)
console.log('running sample stdev = ' + running.sampleStdev)
```

Happily, the results are as expected:

```
C:\dev\runningstats>node StatsDemo.js
simple mean = 2
simple dSquared = 2
simple pop variance = 0.6666666666666666
simple pop stdev = 0.816496580927726
simple sample variance = 1
simple sample stdev = 1

running mean = 2
running dSquared = 2
running pop variance = 0.6666666666666666
running pop stdev = 0.816496580927726
running sample variance = 1
running sample stdev = 1
```

Okay, now let's move on to the math. Even though the derivation is longer this time around, the math is not really any harder to understand than for the [previous article]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %}), so I encourage you to follow it if you're interested. It's always nice to know how and why something works!

Let's start with the formula for variance (the square of the standard deviation):

![variance formula](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/wzguiyf0c3jtu3api0xi.png "variance formula")


Next we multiply both sides by n-1 (or n in the case of population variance):

![variance times n-1](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/5w4k4qf0ltjwruub7ket.png "variance times n-1")

I'll define this value as `d²` (see my article on the [geometry of standard deviation]({% link _posts/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736.md %})):

![d squared](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/ucyr0v35zg1r5q61ysns.png "d squared")

We can expand this using the following identity:

![(a-b)^2](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/2ch48vlwcm90gei6jo3v.png "(a-b)^2")

Applying this substitution, we get:

![expand d squared](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/xs6v3nhi14rpnypfzvpo.png "expand d squared")

Let's break up the summation into three separate parts:
 
![separate summation into parts](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/gyqik7gplkkgc42qic83.png "separate summation into parts")

Now we can factor out the constants:

![factor out constants](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/akys1qiet14t1ldns7sz.png "factor out constants")

As with the [previous article]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %}), we'll use the following identity (total = mean * count):

![total = mean &#42; count](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/pe36aaojidy23ziujtl1.png "total = mean &#42; count")

Substituting this for the summation in the second term of our earlier equation produces:

![sustitute mean &#42; count for total](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/q1j2dfa8nmzmr9c2bsxs.png "sustitute mean &#42; count for total")

The sum of 1 from i=1 to i=n is just n:

![summation of 1](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/ltorvgrtj31xs5pkagx2.png "summation of 1")

Therefore, we can simplify our equation as follows:

![simplify previous step](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/ptbihvpuzdu7heh003dj.png "simplify previous step")


We can combine the last two terms together to get the following:

![reduce](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/hp2klsp3q6s65vi7oq4s.png "reduce")

Now that we have this result, we can use the same equation to obtain `d²` for the first `n-1` terms, that is for all the values except the most recent one:

![d^2 for n-1](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/fwz2lq5b0fv6emq050gm.png "d^2 for n-1")

Let's subtract these two quantities:

![d_n^2 - d_(n-1)^2](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/pwgi0ucpef3rzar710br.png "d_n^2 - d_(n-1)^2")

Multiplying the -1 through the expression in parentheses, we get:

![multiply -1 through](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/ay9t7p0g014pmxk413pq.png "multiply -1 through")

When we subtract ∑x²<sub>i</sub> up to n - ∑x²<sub>i</sub> up to n-1, that leaves just the last value, x<sub>n</sub><sup>2</sup>:

![subtract summations](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/i92vj2h64mgrc0rbjofy.png "subtract summations")

This allows us to remove the two summations and simplify our equation:

![simplified](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/3opp6jsc5lolyy78ljf0.png "simplified")

Multiplying out the last term gives:

![simplified](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/ma1y8wpoyf8ufk6xg3dq.png "simplified")

Rearranging the order, we get:

![rearrange order](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/8tw3661pf0ah92m9r23s.png "rearrange order")

Factoring out the n in the last two terms, we have:

![rearrange order](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/vf03hlzyzr35d9w3mjmq.png "rearrange order")

We know that:

![a^2 - b^2 = (a-b)&#42;(a+b)](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/3cafat4hhkq2vvqbsn4k.png "a^2 - b^2 = (a-b)&#42;(a+b)")

Let's apply this to the expression in parentheses in our equation:

![apply a^2 - b^2 = (a-b)&#42;(a+b)](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/827vbfcmpqnmuuiyq6du.png "apply a^2 - b^2 = (a-b)&#42;(a+b)")

We're almost there! Now it's time to apply the following identity, which was derived at the very end of the [last article]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %}):

![identity from previous article](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/hrgt967ztsg56xltxyfj.png "identity from previous article")

Applying this identity, gives us:

![apply identity from previous article](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/36kseu0aouinzvchm1vk.png "apply identity from previous article")

Multiplying through, we have:

![multiply through](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/t7ttyorx8dc3chbtvp9f.png "multiply through")

We can cancel out the subtraction of identical values and rearrange a bit to obtain the following: 

![simplify and rearrange](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/nrmapfrq80udjx20by5r.png "simplify and rearrange")

We know that:

![(x-a)&#42;(x-b) = x^2 - bx - ax + ab](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/5pwfchg4at8q3itmar2w.png "(x-a)&#42;(x-b) = x^2 - bx - ax + ab")

This allows us to simplify our equation nicely:

![simplify](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/130yhyqnsbyc7cn81ton.png "simplify")

We can now add d<sup>2</sup><sub>n-1</sub> to both sides to get our final result!

![final result](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/27ou4zgk6ir2ox8gj2b5.png "final result")

It was a bit of a long trek, but we now have the jewel that we've been looking for. As in the previous article, we have a nice recurrence relation. This one allows us to calculate the new d<sup>2</sup> by adding an increment to its previous value. 

To get the variance we just divide d<sup>2</sup> by n or n-1:

![variance](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/usmpzl2hsr60v5nfbvmh.png "variance")

Taking the square root of the variance in turn gives us the standard deviation:

![standard deviation](/assets/images/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919/tr8dnk8m18sl8nb235a5.png "standard deviation") 

References:

* [Incremental calculation of weighted mean and variance](http://people.ds.cam.ac.uk/fanf2/hermes/doc/antiforgery/stats.pdf), by [Tony Finch](http://dotat.at/)
* [Accurately computing running variance](https://www.johndcook.com/blog/standard_deviation/), by [John D. Cook](https://www.johndcook.com/blog/top/)
* [Comparing three methods of computing standard deviation](https://www.johndcook.com/blog/2008/09/26/comparing-three-methods-of-computing-standard-deviation/), by [John D. Cook](https://www.johndcook.com/blog/top/)
* [Theoretical explanation for numerical results](https://www.johndcook.com/blog/2008/09/28/theoretical-explanation-for-numerical-results/), by [John D. Cook](https://www.johndcook.com/blog/top/)

Related: 
* [Calculating a Moving Average on Streaming Data]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %})
* [Exponential Moving Average on Streaming Data]({% link _posts/2018-04-04-exponential-moving-average-on-streaming-data-4hhl.24876.md %})
* [The Geometry of Standard Deviation]({% link _posts/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736.md %})
