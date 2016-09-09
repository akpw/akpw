---
layout: post
title: "Visual Binary Trees with Swift 3, Part II"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Playgrounds, Mobile Development, Algorithms and Data Structures, PATs, Binary Trees]
comments: false
---


+ [Introduction & Summary]({% post_url 2016-08-26-BinaryTreesPlayground %})
+ [Part I: QuickLook-able Binary Tree with Pluggable Traversals]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %})
+ Part II: The Drawing Architecture, Customization, and Tree Layouts

--------
This blog is a part of the series on visualizing binary trees with Swift 3. [The introduction]({% post_url 2016-08-26-BinaryTreesPlayground %}) provides an overall context and summary, including a short demo taken in the Swift Playground for iPad app. The playground with sample code and practical examples is [available at github](https://github.com/akpw/VisualBinaryTrees) and is ready to run in the latest Xcode 8.0 GM.

In [the previous part of the series]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %}), we defined [base protocol]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html#base-tree-protocol) for a QuickLook-able Binary Swift Tree. Any tree implementation that conforms to that protocol can now be visualized in the playground as well as in the Xcode debugger.

While this is already enough to start using the [playground](https://github.com/akpw/VisualBinaryTrees) with your own tree implementations, what if you need to change the default visualization? Maybe just to use your own presets for things like fonts, lines thickness and colors, turning the grid off, etc. Or, choose a different 2D / 3D technology such as SpriteKit or SceneKit. Or leverage your own favorite algorithms for laying our a binary tree. Speaking of which, who said that the tree needs to be binary and not N-ary?

The good news is all of these options are possible and also relatively straightforward. After reading through this part, you should have a solid understanding of the drawing architecture and be in a good position to customize its components as outlined  above.


**The architecture**

Let's go top-down and start with the high-level drawing architecture first. In a somewhat simplified form, it basically looks like this:

<img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/renderer.png">

`TreeDrawing` there is a struct that conforms to `Drawable` protocol, along with other drawables such as `Grid` or `Rectangle`. Each drawable can draw itself using a provided `Renderer` implementation.

Sounds kind of familiar so far? Well, if you saw the [WWDC 2015 Protocol-Oriented Programming session](https://developer.apple.com/videos/play/wwdc2015/408/) it definitely should be. <img style="float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/crusty.png"> That is also the reason why Crusty's friendly picture is all over this blog series.

To draw a tree, our `TreeDrawing` needs the tree layout information that is provided to it by an implementation of `TreeLayoutBuilder` protocol. `TreeDrawing` then do its thing processing the layout, switching various drawing states and passing on instructions to the `Renderer`.

This base architecture already gives us plenty of flexibility and customization points.

For example, the default `Renderer` implementation uses Core Graphics to draw the tree and a single animated `CAShapeLayer` to visualize traversals. Now simply switching to a different `Renderer` could easily give us things like e.g. 3D visualization with SceneKit. Or, perhaps someone would prefer a plain ASCII art drawings instead? I'm sure Crusty would be most pleased with these... 🤓

While switching `Renderers` is outside of this blog's scope, (if anyone feels like a little exercise -- the contributions to [the playground](https://github.com/akpw/VisualBinaryTrees) most welcomed!), we could also do quite a lot customization of the basic drawing aspects such as fonts, lines thickness, colors, grid, etc.

**Customizing the drawing**

In the previous part of the series, we defined [QuickLookable Binary Tree]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html#quicklookable-binary-tree) protocol along with extensions for all of its requirements. One of these was specifically responsible for the visual tree representation:
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

And now it should be a good time to look at what this weird-looking `DefaultTreeDrawingConfig.configureTreeView` thing really is:

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

So in case you want to change any of these, writing another configuration struct along with overriding the `QuickLookableBinaryTree.quickLookView` variable on your tree type should be real easy now.


**Tree Layout Model**

Now that we covered the overall drawing architecture, let's take a closer look on what's behind laying out an efficient visual tree representation.

In general, the goal of all tree layout algorithms is to build a tree model where each node is assigned a unique `(x,y)` coordinate so that it can then be drawn in a visually meaningful way.

To be a bit more specific, the following are the rules for what is considered to be "visually meaningful":

##### Tree Layout requirements
> * The layout reflects exact hierarchical structure of the tree
* The edges do not cross each other
* A parent node is centered over its children
* The nodes on the same level are as close as possible
* The drawing of a subtree does not depend on its position

Before diving into the next layer of specifics, let see start with the Swift definition of the tree layout model:
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
    public var logicalX = -1, logicalY = -1

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
        default: break
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
    // internal storage used by builders
    internal var extras: Dictionary<String, Any> = [:]
}
{% endhighlight %}

A few things to notice there:

* Unsurprisingly, `TreeLayout` itself is a [Traversable Tree]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html#traversable-tree) that is initialized with a tree node that conforms to the base [BinaryTree protocol]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html#base-tree-protocol). If that tree node also happens to be a [Traversable Tree]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html#traversable-tree), its traversal is copied during initialization. Then, the model simply builds itself after the tree node while assigning itself the initial (non-valid) `(x,y)` coordinates.

* Since the layout model tree structure should not change after initialization, `TreeLayout` overrides the default implementation of its `height` property. That helps avoid quadratic time during initialization as well as in all future usages of the property.

* The layout is meant to be built in logical `Int` coordinates. These can be easily mapped to concrete physical dimensions later, with a few useful extension properties:
{% highlight swift %}
extension TreeLayoutTopology {
    public var maxLogicalX: Int {
        return Swift.max(left?.maxLogicalX ?? 0, logicalX, right?.maxLogicalX ?? 0)
    }

    public var layoutWidth: CGFloat { return (CGFloat(maxLogicalX) + 2) * gridUnitSize }
    public var layoutHeight: CGFloat { return (CGFloat(height) + 2) * gridUnitSize }

    public var origin: CGPoint {
        return CGPoint(x: (CGFloat(logicalX) + 1) * gridUnitSize,
                       y: (CGFloat(logicalY) + 1) * gridUnitSize)
    }
    public var boundingRect: CGRect {
        let offsetOrigin = CGPoint(x: origin.x - gridUnitSize / 2, y: origin.y - gridUnitSize / 2)
        return CGRect(origin: offsetOrigin, size: CGSize(width: gridUnitSize,  height: gridUnitSize))
    }
    public var childLineAnchor: CGPoint {
        return CGPoint(x: boundingRect.minX + gridUnitSize / 2, y: boundingRect.maxY - gridUnitSize / 5)
    }
    public var parentLineAnchor: CGPoint {
        return CGPoint(x: boundingRect.minX + gridUnitSize / 2, y: boundingRect.minY + gridUnitSize / 5)
    }
}
{% endhighlight %}

* Finally, for the astute readers wondering about the purpose of that `extras` var -- some of the more complex algorithms need to define various additional layout properties, and this is a way of enabling just that. Subclassing the model would obviously be another option, however in this case it'd be by far less clean and effective (as should become apparent in next few moments).

**The history of Tree Layouts**

At that point, we've defined our layout model and the only thing remaining is to actually give it some valid `(x,y)` coordinates.

Half of that already looks trivial, as for each node we should be able to easily figure out its `y` coordinate based on the node's depth. So what is all the fuss about the remaining `x`s?

Well, turns out it is quite fascinating by itself and happens to be one of the classic NP-complete problems with a relatively long history and many contributions from leading computer scientists.

One of the first layout algorithms was described by Donald Knuth[^1], and is basically a simple in-order traversal while incrementing a single x-position counter.
{% highlight swift %}
/// Base Layout Builders protocol
public protocol TreeLayoutBuilder {
    mutating func buildLayout<Node: BinaryTree>
                            (rootNode: Node, gridUnitSize: CGFloat) -> TreeLayout<Node>
}
public struct TreeLayoutBuilderKnuth: TreeLayoutBuilder {
    public mutating func buildLayout<Node: BinaryTree>
                            (rootNode: Node, gridUnitSize: CGFloat) -> TreeLayout<Node> {
        xCounter = 0
        let treeLayout = TreeLayout<Node>(rootNode: rootNode, gridUnitSize: gridUnitSize)
        buildLayout(treeLayout: treeLayout)
        return treeLayout
    }
    // MARK: - Private
    private var xCounter = 0
    private mutating func buildLayout<Node: BinaryTree>
                            (treeLayout: TreeLayout<Node>, depth: Int = 0) {
        if let leftLayout = treeLayout.left {
            buildLayout(treeLayout: leftLayout, depth: depth + 1)
        }
        treeLayout.logicalX = xCounter
        treeLayout.logicalY = depth
        xCounter += 1
        if let rightLayout = treeLayout.right {
            buildLayout(treeLayout: rightLayout, depth: depth + 1)
        }
    }
}
{% endhighlight %}

Here is how it looks when used in the playground. <img style="width : 800px; height : 220px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/knuth.png">
While being among the simplest and fastest algorithms, the drawback is that the x-coordinate is never reused and thus the layout is quickly doing wide. It can also easily digress into some weird tree shapes.

A few years after Knuth, Charles Wetherell and Alfred Shannon[^2] came up with another simple and efficient technique for generating minimal width layouts. Instead of a single x-counter, they used independent counters per level. While processing the tree in pre-level order, each counter is updated independently and therefore layout width grows conservatively:
{% highlight swift %}
public struct TreeLayoutBuilderWetherell: TreeLayoutBuilder {
    public mutating func buildLayout<Node: BinaryTree>(rootNode: Node, gridUnitSize: CGFloat) -> TreeLayout<Node> {
        xCounters = Array(repeating: 0, count: rootNode.height + 1)
        let treeLayout = TreeLayout<Node>(rootNode: rootNode, gridUnitSize: gridUnitSize)
        buildLayout(treeLayout: treeLayout)
        return treeLayout
    }
    // MARK: - Private
    private var xCounters = [Int]()
    private mutating func buildLayout<Node: BinaryTree>(treeLayout: TreeLayout<Node>, depth: Int = 0) {
        treeLayout.logicalX = xCounters[depth]
        treeLayout.logicalY = depth
        xCounters[depth] += 1
        if let leftLayout = treeLayout.left {
            buildLayout(treeLayout: leftLayout, depth: depth + 1)
        }
        if let rightLayout = treeLayout.right {
            buildLayout(treeLayout: rightLayout, depth: depth + 1)
        }
    }
}
{% endhighlight %}

<img style="width : 300px; height : 220px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/wetherell.png">

From looking at the generated drawing of the same tree, the immediate observations are:
* The minimal width property is indeed quite impressive!
* It's hard to describe this layout as even remotely "visually meaningful" 😱
* For larger trees, the layout also quickly becomes real hard to follow

Two years later,  Edward Reingold and John Tilford[^3] continue building on the existing research and came up with several new concepts and the algorithm producing nicely shaped layouts according to the above [requirements](#tree-layout-requirements) while still running in O(n) time.

That algorithm is used as the default in [the playground](https://github.com/akpw/VisualBinaryTrees), and can be roughly described as the following:  <img style="width : 500px; height : 229px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/reingold.png">
1. Recursively build the left and right model sub-trees

2. Shift the right model sub-tree until on some layer it is as close to _the right of the left model sub-tree_ as possible

3. Place the root vertically one level above and horizontally half way between its children. If there is only one child, place the root at the same x as the child

While conceptually falling into the "almost simple" category 🤓, the hard problem is how to make this algorithm run in linear time. Shifting subtrees via straightforward recursion would not work, as it would inevitably result in quadratic times.

To solve this, Reingold and Tilford started with breaking the problem into two parts: computation of the new positions for shifted subtrees and then its actual shifting.

To address the first part, they used several clever ideas such as _tree contours_ and _threads_.

Tree contours are sequences of left-most and right-most nodes for each level.

A node's thread represents an additional relationship to the successor node in the same contour. While the name can be somewhat confusing, the threads are just extra links between relevant contour nodes that are not already in direct parent / child relationship. The threads purpose is to help reduce the amount of time needed to scan subtrees for their contours.

Next, to solve moving nodes in a subtree by the same amount they applied the concept of `mods` introduced earlier in the already mentioned paper by Charles Wetherell and Alfred Shannon[^2]. A `mod` is another additional property for each node, used to calculate positions of its children. These are calculated in two passes, first giving each node a preliminary position and a mod during the bottom-up sweep and then adjusting the positions during a top-down traversal via adding  aggregated sum of mods on the path from the root.

This is how all these extra properties look in the `TreeLayout` extension within the `TreeLayoutBuilderReingold` struct:

{% highlight swift %}
fileprivate struct TreeLayoutExtrasKey {
    static let xMod = "xMod"
    static let contourThread = "contourThread"
}
fileprivate extension TreeLayout {
    /// Mods (modiﬁers) allows linear time when moving subtrees
    var xMod: Int {
        get {
            return extras[TreeLayoutExtrasKey.xMod] as? Int ?? 0
        }
        set(newValue) {
            extras[TreeLayoutExtrasKey.xMod] = newValue
        }
    }
    /// Threads help avoid traversing (lots of) the contour nodes that are not in direct parent/child relationship,
    /// via creating links between these nodes
    var contourThread: TreeLayout? {
        get {
            return extras[TreeLayoutExtrasKey.contourThread] as? TreeLayout
        }
        set(newValue) {
            extras[TreeLayoutExtrasKey.contourThread] = newValue
        }
    }
    var children: [TreeLayout] {
        var children: [TreeLayout] = []
        if let left = left { children.append(left) }
        if let right = right { children.append(right) }
        return children
    }
}
{% endhighlight %}

As full `TreeLayoutBuilderReingold` struct listing is a bit on the longish side, and is not shown here for practical purposes. For anyone curious to see how all of the above concepts are implemented, the code lives [here](https://github.com/akpw/VisualBinaryTrees/blob/master/VisualBinaryTrees.playground/Sources/TreeDrawing/Layout/Builders/TreeLayoutBuilderReingold.swift) and should have enough comments for the key parts of the algorithm.

There is a also very detailed description of the Reingold's et al. algorithm in a great paper of C. Buchheim, M. J Unger, and S. Leipert[^4]. Among other things, that paper by itself takes the art of tree drawing to yet another level via describing an efficient, O(n) algorithm of laying out arbitrary N-ary trees.

Another valuable resource on the subject is a Python magazine article by Bill Mill[^5], which is also available online.[^6] In addition to going through the concepts, Bill is providing lots of Python code samples that help understand things from the perspective of a pragmatic developer.


***Conclusion***

This was the final part of the of the series on visualizing binary trees with Swift 3.

At that point, you should be familiar with using the [the playground](https://github.com/akpw/VisualBinaryTrees) with your own tree implementations, as well as with customizing the tree drawings with your own preset configurations and changing the architectural components for specific needs of your project.

* * *
[^1]: [Knuth, D.E. Acta Informatica (1971) 1: `Optimum binary search trees`](http://rd.springer.com/article/10.1007/BF00264289)

[^2]: [C. Wetherell, A. Shannon, `Tidy Drawings of Trees`, IEEE Transactions on Software Engineering.  1979 vol.5  Issue No.05 (September)](https://www.computer.org/csdl/trans/ts/1979/05/01702661-abs.html)

[^3]: [E. Reingold and J. Tilford. Tidier drawings of trees. IEEE Transactions on Software Engineering, 7(2):223–228, 1981.](https://www.researchgate.net/publication/3189395_Tidier_Drawings_of_Trees)

[^4]: [C. Buchheim, M. J Unger, and S. Leipert. Improving Walker's algorithm to run in linear time](https://www.researchgate.net/publication/226950337_Improving_Walker%27s_Algorithm_to_Run_in_Linear_Time)

[^5]: [Bill Mill, Drawing Presentable Trees. Python Magazine for August 2008.](https://doughellmann.com/blog/2008/08/29/python-magazine-for-august-2008/)

[^6]: [Bill Mill, Drawing Presentable Trees. Blog Article](http://billmill.org/pymag-trees/)

