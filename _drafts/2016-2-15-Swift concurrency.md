---
layout: post
title: "Swift concurrency"
description: "Swift concurrency series"
category: articles
tags: [iOS, OSX, Apple Swift, Concurrency, MobileDevelopment, Darwin, Linux]
comments: true
---

Since its announcement in mid 2014, Swift has been on the roll already jumping up to 18th of the 20 most popular languages and getting even more ground after being oper-sourced in December 2015:
![github stars](https://pbs.twimg.com/media/Cb1aJW4WwAIK5w8.png)

According to RedMon analysts, _Swift is the first language to crack the Top 20 in a year ... there is no debate that Swift is growing faster than anything else we track_.

Interestingly enough, not all of the adopters come from traditional Apple developer crowd. With companies like IBM [enthusiastically embracing](http://www-03.ibm.com/press/us/en/pressrelease/49157.wss) and pushing Swift towards the server side and enterprises, Swift is now starting to get attention from developers with backgrounds in more traditional languages such as Java or C++.

While Swift unarguably brings lots of goods to the table, one recurring question from people exploring it is -- how you go about concurrency there? In today's highly asynchronous, multi-core world this of course is critical for both client and server side code.

***Concurrency, anyone?***

It might come as a shocker, but unlike other major languages Swift does not yet have its native concurrency constructs. Nor it is going to change in the next major version, Swift 3.0. According to the [Swift GitHub Project](https://github.com/apple/swift-evolution):

  > Concurrency: Swift 3.0 relies entirely on platform concurrency primitives (libdispatch, Foundation, pthreads, etc.) for concurrency. Language support for concurrency is an often-requested and potentially high-value feature, but is too large to be in scope for Swift 3.0.

So what does it mean and why should anyone even bother to look any further beyond what sounds like a significant limitation?

Before answering this question, it is important to first understand Apple's overall approach to concurrency and it's core asynchronous design architecture where the OS itself takes care of intelligently managing the threads.

***Swift Concurrency on Darwin platforms***

[Grand Central Dispatch](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) is the foundation library that provides necessary abstractions for writing concurrent code based on tasks, queues, and synchronization operations, such as groups, semaphores and barriers.

GCD abstracts thread creation from the application developer, moving it down to the system level and handling all of the underlying thread management and scheduling, to make sure tasks are executed as quickly and as efficiently as possible. GCD determines the maximum number of concurrent threads for the system and manages the queues for all running applications.

On all Darwin platforms, Grand Central Dispatch is tightly integrated with the operating system kernel to optimize resource management and scheduling.

GCD technology provides foundation to another, yet higher-level approaches such as [NSOperation](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSOperation_class/index.html) and [NSOperationQueue](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/NSOperationQueue_class/)[^1].

While GCD and NSOperations are by far the most common way to deal with concurrency, Apple still recognizes explicit creation and management of threads.

For example, an important GCD design constraint is that it does not guarantee immediate execution of tasks instead taking an effort to run it as a part of optimized system-wide prioritization & scheduling. Threads therefore are still the best way to implement code that need to run in real time. That said, a strong recommendation from Apple is _to create as few threads as possible and use those those only for specific tasks that cannot be implemented any other way_.

***Swift Concurrency on Linux platforms***

As a part of the [Foundation Project](https://github.com/apple/swift-corelibs-foundation), Swift supports using [NSThread](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSThread_Class/) and [NSTask](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTask_Class/index.html#//apple_ref/occ/cl/NSTask) as well as native POSIX threads.

While that alone might be enough to start playing with Swift, dealing with raw threads is hard and given Apple's focus on GCD-based concurrency it is not likely to become much easier with Swift evolution. Might even look as the very point of Swift as a modern language with elegant syntax is at risk here, indeed why bother with adoption if at the end you still have to fall back to complex existing techniques for critical parts of your system?

While that concern not unreasonable at that point, the good news is the [port Grand Central Dispatch project](https://github.com/apple/swift-corelibs-libdispatch) to Linux seems to be a high priority project for multiple industry players, most noticeably Apple and IBM (the latter currently accounting for close to 50% of the commits).

Recently released [IBM's Kitura](https://github.com/IBM-Swift/Kitura?cm_mc_uid=10741446831914349027875&cm_mc_sid_50200000=1458025338), a multi-platform Web Framework, is already relying on Grand Central Dispatch to handle concurrency. That is a promising good news for future Swift on Linux.

***Conclusion***

This series is intended to go over common techniques, covering solution for typical problems like [deadlocks](https://en.wikipedia.org/wiki/Deadlock), [race conditions](https://en.wikipedia.org/wiki/Race_condition#Example), [priority inversion](https://en.wikipedia.org/wiki/Priority_inversion) as well as more specific such as thread explosion etc. It will focus on two main approaches, [NSOperaion](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSOperation_class/index.html) and [Grand Central Dispatch](https://developer.apple.com/library/prerelease/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/) as well as when it's appropriate to use them.


***Notes and References***

[^1]: NSOperation and NSOperationQueue both precede Grand Central Dispatch technology, though as of 10.6 and iOS 4 they was re-implemented using GCD.
