---
title: Incremental Average and Standard Deviation with Sliding Window
published: true
description: Incremental statistics on streaming data using a sliding window
series: Moving Average on Streaming Data
cover_image: /assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/kkdze89gfbuxe3gwfzl3.jpg
canonical_url: https://nestedsoftware.com/2019/09/26/incremental-average-and-standard-deviation-with-sliding-window-470k.176143.html
tags: javascript, math, statistics, sliding_average
---

I was pleasantly surprised recently to get a question from a reader about a couple of my articles, [Calculating a Moving Average on Streaming Data]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %}) and [Calculating Standard Deviation on Streaming Data]({% link _posts/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919.md %}). The question was, _instead of updating the statistics cumulatively, would it be possible to consider only a window of fixed size instead?_

In other words, say we set the window size to _20_ items. Once the window is full, each time a new value comes along, we include it as part of the updated average and standard deviation, but the oldest value is also removed from consideration. Only the most recent _20_ items are used (or whatever the window size happens to be).

I thought this was an interesting question, so I decided to try to figure it out. It turns out that we only have to make some small changes to the logic from the earlier articles to make this work. I'll briefly summarize the derivation and show example code in JavaScript as well.

The diagram below shows the basic idea. We initially have values from _x<sub>0</sub>_ to _x<sub>5</sub>_ in our window, which has room for 6 items in this case. When we receive a new value, _x<sub>6</sub>_, it means we have to remove _x<sub>0</sub>_ from the window, since it's currently the oldest value. As new values come in, we keep sliding the window forward:

![sliding window of values](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/x990ut3oilhljzi8eo22.png)

## Sliding Average

Let’s start by deriving the moving average within our window, where _N_ corresponds to the window size. The average for values from _x<sub>1</sub>_ to _x<sub>n</sub>_ is as follows:

![average from x_1 to x_n](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/5vcf5n26a7pghghwzrzy.png)

It's basically unchanged from the first article in this series, [Calculating a Moving Average on Streaming Data]({% link _posts/2018-03-20-calculating-a-moving-average-on-streaming-data-5a7k.22879.md %}). However, since the size of our window is now fixed, the average up to the previous value, _x<sub>n-1</sub>_ is:

![average from x_0 to x_n-1](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/xgveudg9s7d84ihs2hi9.png)

Subtracting these two averages, we get the following expression:

![x̄_n - x̄_n-1](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/qrrcnic8nyd33pphbask.png)

The first average consists of a sum of values from _x<sub>1</sub>_ to _x<sub>n</sub>_. From this, we subtract a sum of values from _x<sub>0</sub>_ to _x<sub>n-1</sub>_. The only values that don't cancel each other out are _x<sub>n</sub>_ and _x<sub>0</sub>_. Our final recurrence relation for the incremental average with a sliding window of size _N_ is therefore:

![incremental average recurrence relation](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/tqd4wec1gu2g15nw3o3u.png)

That's all we need to compute the average incrementally with a fixed window size.  The corresponding code snippet is below:

```javascript
const meanIncrement = (newValue - poppedValue) / this.count
const newMean = this._mean + meanIncrement
```

## Sliding Variance and Standard Deviation

Next, let's derive the relation for _d<sup>2</sup><sub>n</sub>_.

>What is _d<sup>2</sup>_? It's a term I made up for the variance * (n-1), or variance * n, depending on whether we're talking about [sample variance or population variance](https://en.wikipedia.org/wiki/Variance#Population_variance_and_sample_variance). For more background on the naming, see my article [The Geometry of Standard Deviation]({% link _posts/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736.md %}).

From [Calculating Standard Deviation on Streaming Data]({% link _posts/2018-03-27-calculating-standard-deviation-on-streaming-data-253l.23919.md %}), we've already derived the following:

![d^2 for n](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/z0qgsmyqtk51mhu7sgkv.png)

Again, since our window size remains constant, the equation for _d<sup>2</sup><sub>n-1</sub>_ has the same form, with the only difference being that it applies to the range of values from _x<sub>0</sub>_ to _x<sub>n-1</sub>_:

![d^2 for n-1](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/lmsgywfd2qotovar1k2h.png)

When we subtract these two equations, we get:

![d^2_n - d^2_n-1](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/81wo3c3ck7ki0jhmag3v.png)

Since the two summations overlap everywhere except at _x<sub>n</sub>_ and _x<sub>0</sub>_, we can simplify this as follows:

![d^2_n - d^2_n-1 simplify summations](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/277ncxfdha50l4gw5x2o.png)

We can now factor this expression into the following form:

![d^2_n - d^2_n-1 factor](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/1dtryozc0oj5lzuv6nxs.png)

We can also factor the difference of squares on the right:

![d^2_n - d^2_n-1 ](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/qkkwy8hzsxf2u10pxk3b.png)

Next, we notice that the difference between the current average and the previous average, _x̄<sub>n</sub> - x̄<sub>n-1</sub>_, is (_x<sub>n</sub> - x<sub>0</sub>)/N_, as derived earlier:

![d^2_n - d^2_n-1 simplify difference between current and previous average](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/5gsr9p3rdockbtf1i9ne.png)

We can cancel the _N_'s to get the following nicely simplified form:

![d^2_n - d^2_n-1 cancel out the n's](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/3yhd7bsxt2g7lbnhbzya.png)

To reduce the number of multiplications, we can factor out _x<sub>n</sub> - x<sub>0</sub>_:

![d^2_n - d^2_n-1 factor out x_n-x_0](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/zytuml4su0ynio6qnxnl.png)

Lastly, to get our final recurrence relation, we add _d<sup>2</sup><sub>n-1</sub>_ to both sides. This gives us the new value of _d<sup>2</sup>_ in terms of the previous value and an increment:

![d^2_n final recurrence relation](/assets/images/2019-09-26-incremental-average-and-standard-deviation-with-sliding-window-470k.176143/0rk8thrj30lf1r8llx9x.png)

The corresponding code is:

```javascript
const dSquaredIncrement = ((newValue - poppedValue)
                * (newValue - newMean + poppedValue - this._mean))
const newDSquared = this._dSquared + dSquaredIncrement
```

## Discussion

We now have a nice way to incrementally calculate the mean, variance, and standard deviation on a sliding window of values. With a cumulative average, which was described in the first article in this series, we have to express the mean in terms of the total number of values received so far - from the very beginning.

That means we will get smaller and smaller fractions as time goes on, which will eventually lead to floating point precision problems. Even more importantly, after a large number of values has come along, a new value will just no longer represent a significant change, regardless of the precision. Here that issue doesn't come up: Our window size is always the same, and we only need to make adjustments based on the oldest value that is leaving the window, and the new value coming in.

This approach also requires less computation than re-calculating everything in the current window from scratch each time. However, for many real-world applications, I suspect this may not make a huge difference. It should become more useful if the window size is large and the data is streaming in rapidly.

## Code

A demo with full source code for calculating the mean, variance, and standard deviation using a sliding window is available on github:

* [https://github.com/nestedsoftware/iterative_stats](https://github.com/nestedsoftware/iterative_stats)

## Related

* [The Geometry of Standard Deviation]({% link _posts/2018-03-12-the-geometry-of-standard-deviation--3m3o.21736.md %})
