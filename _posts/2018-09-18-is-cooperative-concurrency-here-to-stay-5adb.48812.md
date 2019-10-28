---
title: Is Cooperative Concurrency Here to Stay?
published: true
description: Cooperative concurrency, non-blocking I/O and horizontal scalability
cover_image: /assets/images/2018-09-18-is-cooperative-concurrency-here-to-stay-5adb.48812/ld7s9n3u6mzsm857kgfj.jpg
canonical_url: https://nestedsoftware.github.io/2018/09/18/is-cooperative-concurrency-here-to-stay-5adb.48812.html
tags: concurrency, nonblocking, scalability, architecture
---

## Introduction 

Cooperative concurrency has been gaining momentum in Web applications over the past decade. [Node.js](https://nodejs.org/en/about/) uses it. It's been implemented in Python's [asyncio](https://docs.python.org/3/library/asyncio.html) and is used in many different programming languages and frameworks. In this article, I will discuss the pros and cons of this kind of concurrency and speculate a bit about its future.

There are two ways to handle multi-tasking in software: Cooperative multitasking and preemptive multitasking.

## Preemptive Multitasking: Multithreading

Until fairly recently, concurrency for Web applications has been achieved mostly with preemptive multitasking by using threads: Each request is assigned an operating system thread. When the request is done, the thread can be released back to a pool. 

For Web applications, threads have some nice properties:

* Threads are preemptive, so if a given thread spends a lot of time using the CPU, other threads will still be serviced.
* Threads can be assigned to different CPUs or CPU cores in parallel, which means that if two concurrent requests both use a lot of CPU, multi-threading will deliver a significant speedup.

If threads are so great, then why are technologies like Node.js on the server becoming more popular? After all, Node uses a cooperative multitasking model.

## Cooperative Multitasking: A Bit of History

What is cooperative multitasking anyway? It means that each task runs in the context of an event loop. The event loop gives each task a turn to use the CPU. However, it's each task’s job to release control back to the event loop. If a task fails to release control, there's nothing that can be done about it. 

Cooperative multitasking for Web applications takes us backward in time in some ways. Windows 3.1 and Mac Os 9 both had cooperative multitasking. One of the drawbacks of cooperative multitasking was that it made the whole system fragile. It was very easy for a single application to crash the entire OS. 

By the early 2000s, Microsoft (as of Win 95, I believe) and Apple (OS X) both had preemptive multitasking: The OS would assign time slices to each process. It interrupted, i.e. preempted, each application automatically after each time slice. That way, a given application might freeze or crash, but that would not prevent the system as a whole from working.

## Concurrency without Multithreading

In systems like Node.js, the approach is similar to that of Windows 3.1 and Mac OS 9. Node.js runs in the JavaScript event loop. All requests are handled within a single thread. Node gives control to requests in a queue. Each request does some amount of work and then returns control back to the event loop so progress can be made on other requests. 

This approach definitely has some disadvantages: If a piece of code needs to do a lot of processing on the CPU, or fails to yield for some other reason, that will not only slow down the processing of that particular request, it will also stall all other requests that are currently being processed. _Every user of the application will experience the slowdown_. That's a pretty significant drawback! 

Cooperative concurrency has become quite popular though. Why is that? I think there are two main reasons:

1. It takes a certain amount of time for the operating system to context switch from one thread to another. It's not a lot of time (on the order of microseconds), but since it does involve talking to the OS, it's slower than switching from one task to another within a single thread. 

2. As the number of users accessing a Web app at the same time increases, so does the number of threads being used. A typical linux system should be able to handle tens of thousands of threads pretty easily. However, if the number of threads gets high enough, it can start to impact the performance of the application as well as the operating system itself. Once we do start to hit that limit, a single computer isn't enough anymore and we need to invest in additional hardware.

## Comparison

In looking for a simple comparison between these two approaches, I think I found an interesting candidate in the performance difference between Apache and NGINX when serving static content. Apache still basically uses threads to service requests, whereas in NGINX the standard setup is to assign one process per CPU core. Beyond that, an event loop runs within each process and handles all of the requests assigned to that process internally. The difference is pretty significant. According to this [analysis](https://www.eschrade.com/page/performance-of-apache-2-4-with-the-event-mpm-compared-to-nginx/), and [this one](http://www.speedemy.com/apache-vs-nginx-2015/), NGINX is at least twice as fast. 

## Discussion

If we're choosing whether to use NGINX or Apache to serve static pages, the choice is pretty simple, since the details of how they're implemented don't matter. When it comes to our own software architecture choices, it's a bit tougher though. Clearly the cooperative approach can pay dividends when it comes to performance of I/O-bound tasks. It does however require us to take extra care with our code:

* All I/O must be non-blocking.
* CPU-bound processing may have to be broken up into separate chunks so that other tasks can make progress in between. Alternatively, a CPU-bound task may be sent to run in a separate thread.

In the end, is it likely to be worth it for our own applications? I think the value of a cooperative approach to concurrency increases with scale. For a relatively small application with several thousand concurrent users, I don't think it will make a difference. However, as we scale up to more and more users, our hardware costs will start to go up. Eventually, when we reach the big players like Google, Amazon, Microsoft, shaving several percentage points from the cost of data-centre maintenance by increasing the efficiency of each machine can add up to millions of dollars in savings. In that context, even if more money has to be spent on the development and maintenance of software, the net benefit may make it worthwhile. 

The reason I brought up old operating systems earlier in this article was to emphasize the point that cooperative multitasking does not do well when there are a lot of 3rd party dependencies, such as all of the possible applications a user may install on an OS. In the same vein, the more we intend to use various libraries and frameworks in our applications, the more fraught cooperative concurrency becomes: The chance that at least one of them will behave badly and take down the whole application increases. 

I don't really know, but my guess is that relatively little of the NGINX code relies on external dependencies. Combined with the simple job a Web server does, I think we can see how the use of cooperative concurrency makes sense for that use case: NGINX is a specialized, highly tuned piece of software. 

In the end, every software project has to make its own determination about which concurrency model to choose. I do think it's worth it to realize that both approaches have potential benefits and drawbacks. It's not a matter of choosing an absolute "best" solution. Rather it's a matter of weighing various trade-offs and applying them to the problem at hand. 

## Is It Here to Stay?

Given that it does have drawbacks, I wonder if cooperative concurrency will eventually disappear from server-side programming in the same way it did from operating systems. Perhaps as hardware gets better, and improvements are made to how threads work, the differences in performance will begin to get smaller again. 

On the other hand, the fact that so much computing now happens in the cloud means that scaling across large numbers of concurrent connections will continue to be a priority. That's not a problem for applications running locally on a user's machine. It may be a fundamental difference that could explain why cooperative concurrency disappeared from PCs but is going strong in Web and Internet applications.

I do think this approach is probably here to stay for the foreseeable future in situations where getting the most requests/second possible is critical or where horizontal scalability (supporting more users concurrently) matters a lot.

## Addendum: What is Non-blocking I/O?

I have the impression that the term "non-blocking" can sometimes be a bit confusing. What it means is very simple though. Let's say we have a function that retrieves some data. When we call the function, the data may or may not be available yet. 

If our function is non-blocking, that means it returns right away no matter what. If the data is available, our function will return the desired data. If the data isn't available, then it just returns a status like `NOT_READY`, but either way, it returns. A blocking function on the other hand can block the current thread and force it to wait until the data is available. With cooperative concurrency, we really have to make sure all of our calls to I/O are non-blocking since our entire event loop depends on it.

One way to deal with nonblocking I/O is to keep polling until the data we want becomes available. For example, see something like the [select](https://en.wikipedia.org/wiki/Select_(Unix)) function. Another approach, used in Node.js, is to supply a callback to the non-blocking call. After the data becomes available, the event loop calls the callback, and the request can proceed from there (in the meantime, the non-blocking call returns and the event loop keeps working on other requests). In the latter case, there's still ultimately a loop polling behind the scenes, but the programmer using Node.js doesn't have to worry about how it's implemented.

We often hear about "non-blocking" in the context of cooperative concurrency, but that doesn't have to be the case. For example, Java's [atomic variables](https://docs.oracle.com/javase/tutorial/essential/concurrency/atomicvars.html) allow multiple threads to access shared data without blocking. They do this by trying to perform an atomic operation in a loop: If the operation succeeds, great. If it fails, then we have to keep trying. It's same idea of polling, here in the context of a multithreaded application. Synchronizing on a lock on the other hand is blocking: A thread that wants to modify data protected by a lock has to block until the lock goes away. 


## Addendum: I/O Bound vs. CPU Bound

Since cooperative concurrency means multiple requests are being handled within a single thread, and therefore only one task is using the CPU at any given time, cooperative concurrency works best when the application logic is I/O bound. That means that a given request may require a bit of CPU time, but much of the time will actually be spent waiting for I/O: Accessing a database, connecting to a remote service, that sort of thing. From the point of view of the CPU, I/O takes forever. While a particular request is waiting for I/O, it can yield control back to the event loop so other requests can continue to be processed. As long as all requests are giving up control to wait for I/O frequently, the whole system should run smoothly. Many commonly used applications - e-mail, online shopping, social-networks - are about loading or sending data somewhere. They're great candidates for this kind of concurrency. If our application logic is CPU bound, that is, each request spends most of its time doing actual processing and not waiting for I/O, then this model is probably not a good idea.
