---
title: The Geometry of Standard Deviation
published: true
description: A geometric interpretation of variance and standard deviation
cover_image: /assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/hm8is2gccaqkfg9gp1mf.png
canonical_url: https://nestedsoftware.github.io/2018/03/12/the-geometry-of-standard-deviation-3m3o.21736.html
tags: math, geometry, statistics, standard deviation
---

I recently needed to look up the formula for [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation). It struck me that the formula looks a bit mysterious, with its squares and square roots. Here's the basic formula for the standard deviation of a sample of data: 

![standard deviation formula](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/ggzs44981kodjlgn5lml.png "standard deviation formula")

We subtract each measurement from the mean (this is often just called the 'average') and take the square. We add all of these squares up, and divide by n-1. Finally we take the square root. What's going on here?

Looking at this formula for the first time in a while, it occurred to me that the numerator looks a lot like the distance in the [Pythagorean theorem](https://en.wikipedia.org/wiki/Pythagorean_theorem). The diagram below shows the distance `d` between 2 points, `p1` and `p2`:

![pythagorean theorem diagram](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/33kt694ge9m8zhnsp5uc.png "pythagorean theorem diagram")

According to the Pythagorean theorem, this distance is: 

![pythagorean theorem formula](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/t6metdzumfk1k6x3lpml.png "pythagorean theorem formula")

It's similar, right? We have a square root. Inside the square root we sum up some values. Each item in the sum is the square of a difference. It's the same basic operation as in the numerator for our standard deviation. 

Let's explore this with a very basic specific case: Suppose we have two values in a sample of data, say, x₁ = 2.5 and x₂ = 1.5. The mean is (2.5 + 1.5)/2 = 2. 

Now, let's calculate the distance between two points: The first point consists of both sampled measurements. The first measurement is on the x-axis, and the second measurement is on the y-axis. We'll call this point V, since it represents the sampled values. V = (x₁, x₂) = (2.5, 1.5). 

>The measurement x₁ is on the x-axis, but the measurement x₂ is on the y-axis, so I am departing now from the convention that _x_ refers to the x axis. It's just a variable. We could call these values v<sub>1</sub>, v<sub>2</sub> as well.

The second point, which we'll call M for the mean, consists of the mean, x̄, on both axes. M = (x̄, x̄) = (2, 2).

![diagram distance from V to M](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/s23tosdmaq1gapjjqhut.png "diagram distance from V to M")

We can see that the distance between V and M is: 

![distance from V to M](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/41i67fce1yguy171exdo.png "distance from V to M")

Now let's see if we can connect this distance between two points with the formula for standard deviation.

The square of a sample's standard deviation is called the [variance](https://en.wikipedia.org/wiki/Variance) and is denoted `s²`:

![variance formula](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/hpws5pfkw7qfxo4nk56j.png "variance formula")

Let's multiply the variance by `n-1`:

![variance times n-1](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/obmnxnsvuaf4saa3k8pk.png "variance times n-1")

Now let's take the square root:

![sqrt of variance times n-1](https://thepracticaldev.s3.amazonaws.com/i/9mamcy7yh49184en84zj.png
 "sqrt of variance times n-1")

Let's define this value we've just derived as `d`:

![define d](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/mtw1adnp4k4utjy2owjf.png "define d")

We can now see that the distance that we computed earlier, 0.71, is in fact this value `d`!

With just some minor algebra, we can show that the standard deviation is closely related to this distance:

![sqrt of variance times n-1 = d](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/lrowkyw1ydoysitnxkjw.png "sqrt of variance times n-1 = d")

![relationship between standard deviation and distance](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/5t00f4b05jzkaqjv3ay6.png "relationship between standard deviation and distance") 

As we can see, we can get the standard deviation by dividing `d` by `√(n-1)`. In this particular case, `√(n-1)` is just 1. Thus we can say the standard deviation is 0.71! 

This worked well for a case where we had 2 measurements in our sample, but what do we do if we have (as is usually the case) more than 2 data points? If we had 3 measurements, then the our point V would have 3 dimensions, V = (x₁, x₂, x₃). Our point M would also have 3 dimensions, M = (x̄, x̄, x̄). 


The cool part is that we can extend the number of dimensions arbitrarily for each of the measurements in our sample.  V = (x₁, x₂, x₃, ... x<sub>n</sub>), and M = (x̄, x̄, x̄, ... x̄). 

>M will always be a point along the diagonal since it will have the same value, x̄, on every axis. 

The Pythagorean theorem holds for any number of dimensions. In fact, the formula for the distance between 2 points `a` and `b` in `n` dimensions should hopefully look familiar: 

![pythagorean theorem in n dimensions](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/wvztxulijo4udaecvxrj.png "pythagorean theorem in n dimensions") 

Let's compare with `d` that we defined earlier:

![d as distance](/assets/images/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736/2mk56u9y06fj6d4k95bl.png "d as distance")


Using this idea of distance is probably not useful for visualizing the standard deviation for a sample that's larger than 3 data points (i.e. 3 dimensions) but I think it's helpful in building a greater conceptual understanding of what the standard deviation represents. 

With standard deviation, we're trying to measure the 'spread' or 'variability' of some data. If all the values in a sample are the same, then of course the distance between the points V and M will be 0. That means the standard deviation will also be 0. The more variable the data is, the farther away the point V will be from the point M.

When we divide by `√(n-1)`, we are normalizing this distance, essentially averaging out the contribution of each value in the sample to the distance from V to M.

>This idea of geometry in n dimensions may be a bit intimidating.  I think here it makes intuitive sense that each piece of data needs to be on its own axis though: We want each value to contribute to the variability _independently_. We wouldn't want a value of +4 to cancel out a value of -4 when determining the variance or the standard deviation. 

If it was new to you, I hope this geometric perspective has helped to build intuition for what standard deviation really is rather than just being a formula to memorize. Thank you for reading!

>If we are calculating the standard deviation in a case where we've included all of the possible data, then we actually divide by `n` to calculate the variance. This may work, for example, when calculating the statistics for all of the grades on an exam, or when calculating the statistics for a medical trial. 
>
>In most cases though, we take a sample that is just a fraction of the total data. In that case, we usually divide by something like `n-1`. Why we do this is a bit of a mystery of its own. For more information, check out [Bessel's Correction](https://en.wikipedia.org/wiki/Bessel%27s_correction) and [Degrees of Freedom](https://en.wikipedia.org/wiki/Degrees_of_freedom_(statistics)).

Related: 
* [Calculating a Moving Average on Streaming Data]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %})
* [Calculating Standard Deviation on Streaming Data]({% link _posts/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919.md %})
* [Exponential Moving Average on Streaming Data]({% link _posts/2018-04-04-exponential-moving-average-on-streaming-data-4hhl.24876.md %})

