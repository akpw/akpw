---
layout: post
title: "Visual Binary Trees with Swift 3 Playgrounds: Introduction"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Playgrounds, Algorithms and Data Structures, Mobile Development]
comments: true
---

+ Introduction & Summary
+ [Part I: Drawable Binary Tree with Pluggable Traversal]({% post_url 2016-08-16-BinaryTreesPlayground-Part-I %})
+ [Part II: Tree Layout Rendering and Core Crusty]({% post_url 2016-08-15-BinaryTreesPlayground-Part-II %})
+ [Part III: Animating Traversals]({% post_url 2016-08-14-BinaryTreesPlayground-Part-III %})

--------
Swift Playgrounds has always been a great showcase for the language.  After WWDC 2016, this has been elevated even further via the new Playgrounds app for iPad.

Playing with the app for the first time in one of the early iOS10 betas made me seriously wonder if that finally will give Apple the key to the edu market. While not their first dedicated product venture (remember [eMac](https://en.wikipedia.org/wiki/EMac)?), this is  definitely Apple's first serious edu software directly focused on the needs of the market. By all early indications so far, it should get them lots of iPads sales there as well as establishing interesting opportunities  for the technical writers. Making all these thick books and courses manuals interactive and easy-to-play-with is definitely something that both students and their teachers are going to like a lot.

As Swift3 got closer to the 'no-source-breaking changes' milestone, I thought it'd be interesting to play with the playgrounds some more and do something edu-related that could also be useful in regular projects.

Since learning how to write code eventually gets to base data structures and algorithms, the idea was to visualize binary trees and their common operations. While there are tools such as [VisuAlgo.net](http://visualgo.net), having an instant visual tree representation right in a Swift playground would definitely be useful both for learning and for real work.

So after a few weekends, here is a short video right from the iPad app showing some features such as base tree drawing and visualization of pluggable traversals:
<video width="700" height="526" controls="true">
<source src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/VisualBinaryTrees.mp4" type="video/mp4" />
</video>

The playground can be downloaded from here.

The rest of the series is a deep dive into the Swift 3 implementation details, and goes into protocols with assosiated types (PATs), Core Graphics, Core Animation, CALayers, UIScrollView, etc. Oh, and not to forget our Crusty! 👻 <img style="float: right; margin: 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/crusty.png">

Read on to find more.

--------
+ [Part I: Drawable Binary Tree with Pluggable Traversal]({% post_url 2016-08-16-BinaryTreesPlayground-Part-I %})
+ [Part II: Tree Layout Rendering and Core Crusty]({% post_url 2016-08-15-BinaryTreesPlayground-Part-II %})
+ [Part III: Animating Traversals]({% post_url 2016-08-14-BinaryTreesPlayground-Part-III %})

