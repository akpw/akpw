---
layout: post
title: "Visual Binary Trees with Swift 3, Part II"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Playgrounds, Mobile Development, Algorithms and Data Structures, PATs]
comments: false
---


+ [Introduction & Summary]({% post_url 2016-08-26-BinaryTreesPlayground %})
+ [Part I: QuickLook-able Binary Tree with Pluggable Traversals]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %})
+ Part II: Tree Layout Rendering and Core Crusty

--------
This blog is a part of the series on visualizing binary trees with Swift 3. [The introduction]({% post_url 2016-08-26-BinaryTreesPlayground %}) provides an overall context and summary, including a short demo taken in the Swift Playground for iPad app. The playground with sample code and practical examples is [available at github](https://github.com/akpw/VisualBinaryTrees) and is ready to run in the latest Xcode 8.0 beta 6.

In the earlier part of the series, we defined [base protocol]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#base-tree-protocol) for a QuickLook-able Binary Swift Tree. Any implementation that conforms to that protocol can now be visualized, as described in details in [the previous blog]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %})

While this is already enough to start using the [playground](https://github.com/akpw/VisualBinaryTrees) for your own tree implementations, what if you say need to customize the  visualization? Maybe just use your own presets for things like fonts, lines thickness and colors, drawing grid, etc. Or, choose a different 2D / 3D technology such as SpriteKit or SceneKit. Or leverage your own favorite algorithms for laying our a binary tree -- speaking of which, who said that the tree needs to be binary and not N-ary?

The good news is that all of these are possible and relatively straightforward. After reading through this part, you should have a solid understanding of the drawing architecture and be in a good position to customize its  components as outlined  above.

**Tree Drawing**

Tree-drawing is one of the classic NP-complete problems with a long history and multiple contributions from leading computer scientists.

The general goal of tree-drawing algorithms is to build a tree layout model where each node is assigned a unique `(x,y)` coordinate so that it then can be drawn in a visually meaningful way.

While the tree-drawing problem is quite fascinating by itself, for the sake of brevity this blog is not going to deep dive into the algorithmic part. Instead we will focus on building a Swift3 solution for drawing binary trees, with pluggable architecture that supports using various specific methods for building tree layout model.

As a proof of concept, we will use two different tree layout algorithms - one described by Donald Knuth[^1] and another by Charles Wetherell and Alfred Shannon[^2]. buchmaier[^3]


***Conclusion***

The article went through major steps of implementing a custom collection view flow layout, extending the concept of sections headers according to specific [requirements](#requirements).

The custom layout code shown in article is available as [an open source framework](https://github.com/akpw/AKPFlowLayout), accompanied by the [sample app](https://github.com/akpw/SwiftNetworkImages) that you can download and run / test in Xcode.

* * *
[^1]: [Knuth, D.E. Acta Informatica (1971) 1: `Optimum binary search trees`](http://rd.springer.com/article/10.1007/BF00264289)


[^2]: [C. Wetherell, A. Shannon, `Tidy Drawings of Trees`, IEEE Transactions on Software Engineering.  1979 vol.5  Issue No.05 (September)](https://www.computer.org/csdl/trans/ts/1979/05/01702661-abs.html)

[^3]: [C. Buchheim, M. J Unger, and S. Leipert. Improving Walker's algorithm to run in linear time](https://www.researchgate.net/publication/226950337_Improving_Walker%27s_Algorithm_to_Run_in_Linear_Time)

