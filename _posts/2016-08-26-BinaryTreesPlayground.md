---
layout: post
title: "Visual Binary Trees with Swift 3: Introduction"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Playgrounds, Mobile Development, Algorithms and Data Structures]
comments: true
---

+ Introduction & Summary
+ [Part I: QuickLook-able Binary Tree with Pluggable Traversals]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %})

--------
Swift Playgrounds has always been a great showcase for the language, and that has been elevated even further with the new Playgrounds app for iPad.

Playing with the app in one of the early iOS10 betas made me seriously wonder if that finally will give Apple the key to the edu market. While not their first dedicated product (remember [eMac](https://en.wikipedia.org/wiki/EMac)?), this is  Apple's first serious software directly focused on the needs of the educational sector. By all early indications, it should get to lots of iPads sales there and also create some interesting opportunities for the technical writers. Making all these textbooks and manuals interactive and easy-to-mess-with is definitely something that both the students and their teachers are going to like a lot.

As Swift 3 got over its 'no-source-breaking changes' milestone, I thought it'd be interesting to play with the playgrounds some more and do something edu-related that would also be useful in regular projects.

Since learning / teaching how to write code eventually gets you to base data structures and algorithms, the idea was to visualize binary trees along with their common operations. While there are some tools such as [VisuAlgo.net](http://visualgo.net), having an instant visual tree representation right in a Swift playground would surely be handy both for learning and for real-life work.

So after a few weekends, here is a short video right from the iPad app showing some features such as base tree drawing and visualization of pluggable traversals:
<video width="700" height="526" controls="true">
<source src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/VisualBinaryTrees.mp4" type="video/mp4" />
</video>

And a similar screenshot in Xcode: <img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/tree4.png">

Without further ado, the standalone playground[^1] is now [available at github](https://github.com/akpw/VisualBinaryTrees) and ready to run in Xcode 8.0 beta 6.

_Since the Swift Playgrounds for iPad app in iOS10 Beta 8 is still behind the latest Swift 3 syntax, it can not be currently run there till the next (and hopefully last) iOS10 Beta_.

If at that point you are ready to go and play with the [playground](https://github.com/akpw/VisualBinaryTrees), that is completely fine.

If on the other hand you want more details on how to use it with your own trees, or interested in Swift 3 implementation, or perhaps just curious about the general problem of optimal visual layouts for arbitrary trees -- [keep reading]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %}) for a deep dive into things like protocols with associated types (PATs), history of tree layouts, overall architecture (largely attributed to Crusty 👻), <img style="float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/crusty.png"> used technology, etc.

* * *
[^1]: An embeddable framework version under MIT license is TBD after Swift 3 is finalized


