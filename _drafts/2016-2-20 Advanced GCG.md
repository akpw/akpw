---
layout: post
title: "Advanced Grand Central Dispatch"
description: "Swift concurrency series"
category: articles
tags: [iOS, OSX, Apple Swift, GCD, Concurrency, MobileDevelopment]
comments: true
---

Grand Central Dispatch or libdispatch is a  level framework ques, tasks
concurrent code execution on multicore hardware.

libdispatch low level C library, is currently available on all Darwin platforms
Handles priority inversion

From this perspective, one of the most strategic IBM Swift projects are the contributions to the [Grand Central Dispatch project](https://github.com/apple/swift-corelibs-libdispatch) where IBM is accounting from close to 50% of the commits.

Ubuntu https://launchpad.net/ubuntu/+source/libdispatch

concept of queues
    serial
     locking of shared resources

    concurrent

advantage over threading model

five types of queues, QOS

dispatch_get_main_queue

when have a queue, can submit tasks

dispatch_sync
    adding to the queue, scheduler decides, then executes, you have to wait
dispatch_async


Dispatch queues let you execute arbitrary blocks of code either asynchronously or synchronously with respect to the caller. You can use dispatch queues to perform nearly all of the tasks that you used to perform on separate threads. The advantage of dispatch queues is that they are simpler to use and much more efficient at executing those tasks than the corresponding threaded code.

Serial queues (also known as private dispatch queues)


The main dispatch queue is a globally available serial queue that executes tasks on the application’s main thread. This queue works with the application’s run loop (if one is present) to interleave the execution of queued tasks with the execution of other event sources attached to the run loop. Because it runs on your application’s main thread, the main queue is often used as a key synchronization point for an application.


A dispatch group is a way to monitor a set of block objects for completion. (You can monitor the blocks synchronously or asynchronously depending on your needs.) Grou

