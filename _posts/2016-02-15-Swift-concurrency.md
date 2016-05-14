---
layout: post
title: "Swift concurrency series: bird's-eye view "
description: "Swift concurrency series"
category: articles
tags: [iOS, OSX, Apple Swift, Concurrency, Mobile Development, Linux]
comments: false
---

Since its announcement in mid 2014, Swift has been on the roll already jumping up to 18th of the 20 most popular languages and getting even more ground after being open-sourced in December 2015:
![github stars](https://pbs.twimg.com/media/Cb1aJW4WwAIK5w8.png)

According to RedMon analysts, _Swift is the first language to crack the Top 20 in a year_ and _... there is no debate that Swift is growing faster than anything else we track_.

While there are multiple theories on Swift explosive growth, for the purpose of this article an interesting observation is that not all of these early adopters come from the traditional Apple developer crowd. With companies like IBM [enthusiastically embracing](http://www-03.ibm.com/press/us/en/pressrelease/49157.wss) and pushing Swift towards the server side and enterprises, Swift is also starting to get attention from developers with backgrounds in back-ends and more traditional languages such as Java or C++.

While Swift unarguably brings lots of goods to the table, one recurring question seems to be: how you go about concurrency there? In today's highly asynchronous, multi-core world this of course is critical for both client and server side apps.

***Concurrency, anyone?***

It might come as a shocker, but unlike other major languages Swift does not yet have its own concurrency constructs. Nor it is going to change in the next major version, Swift 3.0. According to the [Swift GitHub Project](https://github.com/apple/swift-evolution):

  > Concurrency: Swift 3.0 relies entirely on platform concurrency primitives (libdispatch, Foundation, pthreads, etc.) for concurrency. Language support for concurrency is an often-requested and potentially high-value feature, but is too large to be in scope for Swift 3.0.

So what does it mean and why should anyone even bother to look any further beyond what sounds like a significant limitation?

![aa]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/farley-weekend-update.gif)

Before answering this question, it is actually important to understand Apple's overall approach to concurrency and it's core asynchronous design architecture.

***Swift Concurrency on the Darwin platforms***

libdispatch, or [Grand Central Dispatch](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) is a low level C library that provides abstractions for writing concurrent code based on tasks and queues.

GCD abstracts thread creation, moving it down to the system level and handling all of the thread management and scheduling so that tasks are executed as quickly and as efficiently as possible. GCD automatically determines the maximum number of concurrent threads for the system and manages queues for all running applications. Beyond this base functionality, it supports many advanced synchronization operations and constructs such as groups, semaphores and barriers.

On all Darwin platforms, Grand Central Dispatch is tightly integrated with the operating system kernel and is highly optimized for effective resource management and scheduling.

In addition to the GCD functionality, the libdispatch library is also behind yet another, higher-level abstraction[^1].   [NSOperation](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSOperation_class/index.html) represents an abstract unit of parallelizable work, while the associated [NSOperationQueue](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/NSOperationQueue_class/) accepts and runs specific instances of NSOperations. This model supports many advanced features such as e.g. operation dependencies across multiple queues or number of concurrent operations per a given queue.

While GCD and NSOperations are by far the most common way to deal with concurrency in iOS and OSX, Apple still recognizes explicit creation and management of threads.

An important GCD design constraint is that it does not guarantee immediate execution of tasks. Instead it takes its best effort to run submitted tasks as a part of larger system-wide prioritization & scheduling. That might not always be sufficient, so sometimes threads are still the best way to implement code that e.g. needs to run in real time.

A strong recommendation from Apple is _to create as few threads as possible and use those those only for specific tasks that cannot be implemented any other way_.

Later parts of this series will cover iOS / OSX concurrency in depth, going over common techniques and practical solutions for typical problems like [deadlocks](https://en.wikipedia.org/wiki/Deadlock), [race conditions](https://en.wikipedia.org/wiki/Race_condition#Example), [priority inversion](https://en.wikipedia.org/wiki/Priority_inversion) as well as more specific challenges such as thread explosion etc.

Following Apple's recommendation, the focus primarily will be on NSOperaion and Grand Central Dispatch, including when it's appropriate to use one over another.

***Swift Concurrency on Linux***

As a part of the [Foundation Project](https://github.com/apple/swift-corelibs-foundation), Swift supports using [NSThread](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSThread_Class/) and [NSTask](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTask_Class/index.html#//apple_ref/occ/cl/NSTask) as well as native POSIX threads.

That alone might be enough to start playing with Swift, though dealing with threads is hard and given Apple's focus on GCD-based concurrency it is not likely to become any easier with evolution of Swift. This somewhat contradicts the very point of Swift being a modern, elegant and safe language. Indeed, why at all bother with switching if at the end you still have to fall back to old-fashioned techniques for critical parts of your system?

While this concern is not unreasonable at that moment, the good news is that the [port of Grand Central Dispatch](https://github.com/apple/swift-corelibs-libdispatch) to Linux seems to be a high priority project for multiple industry players, most noticeably Apple and IBM (the latter currently accounting for close to 50% of the commits).

Recently released [IBM's Kitura](https://github.com/IBM-Swift/Kitura?cm_mc_uid=10741446831914349027875&cm_mc_sid_50200000=1458025338) is a multi-platform Web Framework that already uses Grand Central Dispatch to handle concurrency. That is a promising good news for the future of Swift on Linux.

***Conclusion***

If you develop for iOS or OSX, adopting Swing is not really an _if_ question and speaking of the good time to switch Swift 2.0 provides a reasonable level of stability for production time. Specifically for concurrency, Swift does not add much to the previous Objective-C approach though it does give you a nicer syntax and more elegant ways to solve some of the challenges. More on that in later parts, where the focus will be on practical solutions to common concurrency problems.

For Linux and the server-side, it's probably a good time to start experimenting and follow what people do with Swift there. Not really production-time yet IMO but things do look promising and IBM's involvement definitely helps keep it on the bright side.



* * *

[^1]: NSOperations precede Grand Central Dispatch technology, though as of OSX 10.6 and iOS 4 they were re-implemented using GCD.

[^2]: [Concurrency programming guide](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)

[^3]: [Threading Programming Guide](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i)
