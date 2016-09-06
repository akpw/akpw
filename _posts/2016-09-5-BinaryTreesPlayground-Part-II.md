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
+ Part II: The tree drawing architecture and customization of its components

--------
This blog is a part of the series on visualizing binary trees with Swift 3. [The introduction]({% post_url 2016-08-26-BinaryTreesPlayground %}) provides an overall context and summary, including a short demo taken in the Swift Playground for iPad app. The playground with sample code and practical examples is [available at github](https://github.com/akpw/VisualBinaryTrees) and is ready to run in the latest Xcode 8.0 beta 6.

In the earlier part of the series, we defined [base protocol]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#base-tree-protocol) for a QuickLook-able Binary Swift Tree. Any tree implementation that conforms to that protocol can now be visualized, as described in details in [the previous blog]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %})

While this is already enough to start using the [playground](https://github.com/akpw/VisualBinaryTrees) for your own tree implementations, what if you need to customize the  visualization? Maybe just use your own presets for things like fonts, lines thickness and colors, drawing grid, etc. Or, choose a different 2D / 3D technology such as SpriteKit or SceneKit. Or leverage your own favorite algorithms for laying our a binary tree -- speaking of which, who said that the tree needs to be binary and not N-ary?

The good news is that all of these are possible and relatively straightforward. After reading through this part, you should have a solid understanding of the drawing architecture and be in a good position to customize its components as outlined  above.


**The architecture**

Let's go top-down and start with a high-level drawing architecture. In a somewhat simplified form, it basically looks like this:

<img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/renderer.png">

`TreeDrawing` there is a struct that conforms to `Drawable` protocol, along with other drawables such as `Grid` or `Rectangle`. Each drawable can draw itself using a provided `Renderer` implementation.

Sounds familiar so far? Well, if you saw the [WWDC 2015 Protocol-Oriented Programming session](https://developer.apple.com/videos/play/wwdc2015/408/) it definitely should be. <img style="float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/crusty.png"> That is also the reason why Crusty's friendly picture is all over this blog series.

To draw a tree, our `TreeDrawing` needs tree layout information that is provided to it by an implementation of `TreeLayoutBuilder` protocol. `TreeDrawing` then do its thing, processing the layout and passing on instructions to the `Renderer`.

This architecture should give us plenty of flexibility and customization points.

For example, the default `Renderer` implementation uses Core Graphics to draw the tree, and a single animated `CAShapeLayer` to visualize traversals. Now simply switching to a different `Renderer` would easily give us things like e.g. 3D visualization with SceneKit. Or, perhaps someone prefers a plain ASCII art drawing? I'm sure Crusty would be most pleased with that one... 🤓

And while switching `Renderers` is outside of this blog's scope, (if anyone feels like a little exercise -- the contributions to [the playground](https://github.com/akpw/VisualBinaryTrees) are definitely most welcomed!), we could also do quite a lot customization of the base drawing aspects such as fonts, lines thickness, colors, grid, etc.

**Customizing the drawing**

In the previous part of the series, we defined [QuickLookable Binary Tree]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#quicklookable-binary-tree) protocol along with extensions for all of its requirements. One of these was responsible for visual tree representation:
{% highlight swift %}
/// Default Visual Tree Config
extension QuickLookableBinaryTree {
    /// Configures visual tree representation
    public var quickLookView: (Self) -> UIView {
        // Default Tree View configuration
        return DefaultTreeDrawingConfig.configureTreeView
    }
}
{% endhighlight %}

And now it should be a good time to look at what this wierd-looking `DefaultTreeDrawingConfig.configureTreeView` thing really is:

{% highlight swift %}
/// Provides default tree drawing configuration
public struct DefaultTreeDrawingConfig {
    public static func configureTreeView<Node: BinaryTree>(rootNode: Node) -> UIView {
        let layoutBuilder = TreeLayoutBuilderReingold()
        return configureTreeView(rootNode: rootNode,
                                 layoutBuilder: layoutBuilder,
                                 visualizeTraversal: false)
    }
    public static func configureTreeView<Node: BinaryTree>(rootNode: Node,
                                                           layoutBuilder: TreeLayoutBuilder,
                                                           visualizeTraversal: Bool) -> UIView {
        let drawingAttributes =
            TreeDrawingAttributes(gridUnitSize: DrawingSizes.Grid.GridUnitSize,
                                  gridLineWidth: DrawingSizes.Grid.GridLineWidth,
                                  treeLineWidth: DrawingSizes.TreeLineWidth,
                                  treeFontSize: DrawingSizes.TreeNodeFontSize,
                                  gridColor: DrawingColors.GridColor,
                                  treeNodeColor: DrawingColors.TreeNodeColor,
                                  treeLineColor: DrawingColors.TreeLineColor,
                                  backGroundColor: DrawingColors.BackGroundColor)
        let treeDrawing = TreeDrawing(rootNode: rootNode,
                                      drawingAttributes: drawingAttributes,
                                      layoutBuilder: layoutBuilder,
                                      visualizeTraversal: visualizeTraversal)
        let treeRenderer = CoreGraphicsTreeRenderer(frame: CGRect(x: 0, y: 0,
                                                                  width: treeDrawing.width,
                                                                  height: treeDrawing.height ))
        treeRenderer.view.backgroundColor = drawingAttributes.backGroundColor
        treeRenderer.draw = treeDrawing.draw
        return treeRenderer.view
    }
}
{% endhighlight %}

Well, turns out it is nothing more than a little configuration helper that assembles the key pieces of the above architecture and feeds values to available customization points.

In case you want to change any of these, writing your own configuration struct along with overriding the `QuickLookableBinaryTree.quickLookView` variable on your tree type should be real easy now.


**Tree Layouts**

Now that we covered the overall drawing architecture, let's take a closer look on what's behind laying out an efficient visual tree representation.

It turns out tree layouts are actually quite fascinating by itself and happen to be one of the classic NP-complete problems, with a relatively long history and multiple contributions from leading computer scientists.

The general goal of related algorithms is to build a tree layout model where each node is assigned a unique `(x,y)` coordinate so that it then can be drawn in a visually meaningful way.

One of the first algorithm was described by Donald Knuth[^1], and is basically a simple in-order traversal while incrementing an external x-position counter. Here is how it looks when used in the playground: <img style="width : 800px; height : 220px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/knuth.png">
While being among the simplest and fastest algorithms, the drawback is that the x-coordinate is never reused and thus the layout is quickly doing wide and the layout can also easily digress into some weird tree shapes.

A few years after Knuth, Charles Wetherell and Alfred Shannon[^2] came up with an efficient technique for generating minimal width layouts. Instead of a single x-counter, they used a list of counters per tree level. <img style="width : 300px; height : 220px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/wetherell.png"> While processing the tree in pre-level order, each counter is updated per-level and therefore layout width grows conservatively.

From looking at the drawing of the same tree, there are two immediate observations. First, the minimal width property is quite impressive. Second, it's hard to describe this layout as even remotely "visually appealing" 😱.

For larger trees, this layout also quickly becomes kind of hard to follow.

Finally, the third layout that (used as the default in the [playground](https://github.com/akpw/VisualBinaryTrees)) is based on "almost simple divide and conquer" algorithm by Edward Reingold and John Tilford[^3]. <img style="width : 500px; height : 229px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/reingold.png"> The algorithm is based on moving the drawings of subtrees, and comes with a few helper concepts such as mods, tree contours, threads, etc. As the prior two simple algorithms, it runs in O(n) time and produces nicely shaped trees.



Let's see how this translates to (a shortened version of) our `TreeLayout`:
{% highlight swift %}
/// Tree Layout Topology protocol
protocol TreeLayoutTopology: TraversableBinaryTree {
    var gridUnitSize: CGFloat { get }
    var logicalX: Int { get set }
    var logicalY: Int { get set }
}

public final class TreeLayout<Node: BinaryTree>: TreeLayoutTopology {
    private(set) public var element: Node.Element
    private(set) public var left: TreeLayout?
    private(set) public var right: TreeLayout?
    private(set) public var height: Int
    public var traversalStrategy: TraversalStrategy.Type?

    private(set) public var gridUnitSize: CGFloat

    public var logicalX = -1
    public var logicalY = -1

    convenience public init(rootNode: Node, gridUnitSize: CGFloat) {
        let rootHeight = rootNode.height
        self.init(rootNode: rootNode, gridUnitSize: gridUnitSize, nodeHeight: rootHeight)
    }

    public init(rootNode: Node, gridUnitSize: CGFloat, nodeHeight: Int) {
        height = nodeHeight
        self.element = rootNode.element
        self.gridUnitSize = gridUnitSize

        switch rootNode {
        case let traversableNode as TraversableBinaryTree:
            self.traversalStrategy = traversableNode.traversalStrategy
        default:
            break
        }

        if let left = rootNode.left {
            self.left = TreeLayout(rootNode: left,
                                         gridUnitSize: gridUnitSize,
                                         nodeHeight: nodeHeight - 1)
        }
        if let right = rootNode.right {
            self.right = TreeLayout(rootNode: right,
                                          gridUnitSize: gridUnitSize,
                                          nodeHeight: nodeHeight - 1)
        }
    }
}
{% endhighlight %}

As a proof of concept, we will use two different tree layout algorithms - one described by Donald Knuth[^1] and another by Charles Wetherell and Alfred Shannon[^2]. buchmaier[^3]


***Conclusion***

The article went through major steps of implementing a custom collection view flow layout, extending the concept of sections headers according to specific [requirements](#requirements).

The custom layout code shown in article is available as [an open source framework](https://github.com/akpw/AKPFlowLayout), accompanied by the [sample app](https://github.com/akpw/SwiftNetworkImages) that you can download and run / test in Xcode.

* * *
[^1]: [Knuth, D.E. Acta Informatica (1971) 1: `Optimum binary search trees`](http://rd.springer.com/article/10.1007/BF00264289)


[^2]: [C. Wetherell, A. Shannon, `Tidy Drawings of Trees`, IEEE Transactions on Software Engineering.  1979 vol.5  Issue No.05 (September)](https://www.computer.org/csdl/trans/ts/1979/05/01702661-abs.html)

[^3]: [E. Reingold and J. Tilford. Tidier drawings of trees. IEEE Transactions on Software Engineering, 7(2):223–228, 1981.](https://www.researchgate.net/publication/3189395_Tidier_Drawings_of_Trees)


[^4]: [C. Buchheim, M. J Unger, and S. Leipert. Improving Walker's algorithm to run in linear time](https://www.researchgate.net/publication/226950337_Improving_Walker%27s_Algorithm_to_Run_in_Linear_Time)

