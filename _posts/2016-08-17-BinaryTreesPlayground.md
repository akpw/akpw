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
Swift Playgrounds has always been a great showcase for the language, and it is not surprising that one of the recurring topics mentioned by people after WWDC 2016 is the new Playgrounds app for iPad.

After playing with the app in one of the early iOS10 betas, I seriously wondered if that finally will be the key enabler for Apple's efforts in the edu market. Making all these thick books and courses manuals interactive and easy-to-play-with is definitely something that teachers and students are going to like a lot.

As Swift3 got closer to the 'no-source-breaking changes' milestone, I thought it'd be interesting to play with the playgrounds some more and do something edu-related that could also be useful in regular projects.

Since learning how to write code eventually gets to base data structures and algorithms, the idea was to visualize binary trees and its common operations. While there are already tools such as [VisuAlgo.net](http://visualgo.net), having a visual tree representation right in a Swift playground should be useful both for learning and for real work.

So after a few weekends, here is a short video right from the iPad app showing some features such as base tree drawing and visualization of pluggable traversals:
<video width="700" height="526" controls="true">
<source src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/VisualBinaryTrees.mp4" type="video/mp4" />
</video>

The playground can be downloaded from here.


The rest of the series is a dive into Swift 3 implementation, and goes deep into protocols with assosiated types and things like Core Graphics, Core Animation, CALayers, UIScrollView, etc. Oh, and not to forget "Core Crusty" :)<img style="float: right; margin: 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/crusty.png">

Read on to find more.

--------
+ [Part I: Drawable Binary Tree with Pluggable Traversal]({% post_url 2016-08-16-BinaryTreesPlayground-Part-I %})
+ [Part II: Tree Layout Rendering and Core Crusty]({% post_url 2016-08-15-BinaryTreesPlayground-Part-II %})
+ [Part III: Animating Traversals]({% post_url 2016-08-14-BinaryTreesPlayground-Part-III %})

