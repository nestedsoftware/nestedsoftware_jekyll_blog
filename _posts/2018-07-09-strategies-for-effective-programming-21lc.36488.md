---
title: Strategies for Effective Programming
published: true
description: Strategies for effective programming
cover_image: /assets/images/2018-07-09-strategies-for-effective-programming-21lc.36488/u70ql7dx6mdmpg2a9cai.jpg
canonical_url: https://nestedsoftware.github.io/2018/07/09/strategies-for-effective-programming-21lc.36488.html
tags: programming, productivity, motivation, progress
---

Recently I have been working on some projects that have involved a fair amount of learning and working with a variety of different frameworks and languages. Along the way, I've made note of times when I felt discouraged, unmotivated, or unproductive. In this article I'd like to take stock of some of the lessons I've learned along the way.

## Every Journey Begins with a Single Line of Code

Any meaningful project will take some time to get to a polished state. The single most important thing I've learned is that focussing too much on the end result is a bad idea. 

To stay productive, I believe it's best to define achievable goals that can be realized within a week or less: Set one goal, achieve it. Then set the next goal, and so on. Even if the goal is really modest, that's fine. What matters is for it to be very clear whether the goal has or has not been achieved.

Setting granular goals with clear criteria for completion is key. 

## The Agony of Boilerplate 

One of the more frustrating things when starting a new project, especially when using a language or framework for the first time, can be getting the basic boilerplate code and configuration for the project working. 

Rather than trying to do this for an actual project right away, I have found it very helpful to get some basic skeleton projects working first. The idea is to document and automate as much of this boilerplate as possible so that it becomes really easy to clone the project and then change a couple of things to get a new one off the ground right away. 

Often I will start with a project that sets up only one or two things. Then I create several more projects which add additional elements. Finally once I have all of the core elements I need, I clone a starting repository for my "real" project. 

For example, for React development, I started by figuring out the Webpack configuration to build and deploy the standard [tic tac toe](https://reactjs.org/tutorial/tutorial.html) example.  Next I cloned this project and modified the existing code to use Redux for state management. Even with something so simple, I discovered that I had to figure how to do a couple of things in Redux that weren't completely obvious. 

Once I have all of the core pieces in place and I've done a reasonable job of automating the set up with a combination of scripts and pre-configured files in git, I can use this to begin the work on my real code. 

## Step Back and Look at the Big Picture 

There have been times where I've felt that I was hacking my way through some code, or else that I was getting mired in writing abstract framework code without a clear end in sight. To me these problems are two sides of the same coin. In such cases, it has helped a lot to stop and reflect on what I really wanted to accomplish. 

As an example, in one case I started to spin my wheels on some framework code for validation logic in a Web-facing API. What helped was to pause and then sketch out what I wanted the JSON that was sent back to the client to look like. Once I took the time to clarify and simplify this representation, it became much easier to make progress on the logic that performed validations.

## Make a Code Playground

I regularly run into situations where I realize I need to understand something better in order to make progress. It can be how an aspect of a language or library works, or it may be that I need to figure out what kind of algorithm to use to solve a problem. 

It can be tempting to try figure this out right in the project codebase, but I've found this can sometimes lead me to make enough of a mess of the given branch that I end up having to start over. Instead I've created a `dev/playground` directory where I regularly add small programs or scripts to test out ideas. I try to remove all unnecessary dependencies and to carefully isolate the specific issue I'm dealing with. Once I have it figured out, I go back to my work in progress. Here's an example: 

* [Careful Examination of JavaScript Await]({% link _posts/2018-04-06-careful-examination-of-javascript-await--109.25561.md %})

## Research vs. Programming Mode

I've found that sometimes in my haste to make tangible progress, I become reluctant to stop and do some research first. It's good to focus on moving forward, but trying to move ahead while not really understanding what one is doing can be counterproductive. 

I try to be aware of this more now, and to switch to research mode when it's applicable. Of course there is another side to this: Once one is doing research, it can become tempting to go all the way down the rabbit hole never to emerge again! So balance is critical. Do enough research, but not too much. 

As an example, I was getting a little confused recently while implementing login functionality, so I took time to do some reading about [JWT](https://jwt.io/), [OAuth](https://oauth.net/2/), [CAPTCHA](https://en.wikipedia.org/wiki/CAPTCHA), [XSS](https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)), and [CSRF] (https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)).Having understood the lay of the land, I was able to continue.

A lot of programming is about exploring a problem space in one's mind rather than writing code, so research doesn't have to mean looking up information. It can also simply mean visualizing the problem or sketching out various options in a notebook. 

## Progress is not Always Linear

A sense of anxiety can come from getting pulled in different possible directions around how to deal with a problem. It's important to realize that this is part of the process too. 

If I can't make up my mind about the next step, sometimes it's not a bad idea to just set that problem aside as the main focus and concentrate on something else, while still fiddling with the problem in the background. As new ideas come up, I can pick it up again and work it a small bit at a time until it eventually begins to untangle. I've found it surprising how quickly this can happen. I may think I'm still somewhat removed from my goal of completing a given task but after a few tentative steps, the whole thing can suddenly resolve itself.

Another strategy that sometimes works is to choose the simplest way to move forward. Even if this approach may have to change later on, having a basic implementation backed by automated tests may be good enough for the time being. This approach is especially effective if the problem is somewhat tangential to the main goal I’m working toward, but it's still getting in the way.

Regardless of how one deals with obstacles to progress, it's important to understand that progress won't always be a pleasant linear path forward. There will be times when we feel stuck. Allowing ourselves to become overwhelmed by this will only hinder progress further. The key is to stay calm and find constructive ways to continue working toward the objective.
