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

In the previous part of the series, we defined [base protocol]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#base-tree-protocol) for a QuickLook-able Binary Swift Tree. Any tree implementation that conforms to that protocol can now be visualized, as described in details in [the previous blog]({% post_url 2016-08-26-BinaryTreesPlayground-Part-I %})

While this is already enough to start using the [playground](https://github.com/akpw/VisualBinaryTrees) for your own tree implementations, what if you need to customize the  visualization? Maybe just use your own presets for things like fonts, lines thickness and colors, drawing grid, etc. Or, choose a different 2D / 3D technology such as SpriteKit or SceneKit. Or leverage your own favorite algorithms for laying our a binary tree -- speaking of which, who said that the tree needs to be binary and not N-ary?

The good news is that all of these options are possible and relatively straightforward. After reading through this part, you should have a solid understanding of the drawing architecture and be in a good position to customize its components as outlined  above.


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

In case you want to change any of these, writing your own configuration struct along with overriding the `QuickLookableBinaryTree.quickLookView` variable on your tree type should be real easy now.


**Tree Layout Model**

Now that we covered the overall drawing architecture, let's take a closer look on what's behind laying out an efficient visual tree representation.

In general, the goal of all tree layout algorithms is to build a tree model where each node is assigned a unique `(x,y)` coordinate so that it then can be drawn in a visually meaningful way.

Here is how our `TreeLayout` model looks like:
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

* Unsurprisingly, `TreeLayout` itself is a [Traversable Tree]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#traversable-tree) that is initialized with a tree node that conforms to the base [BinaryTree protocol]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#base-tree-protocol). If that tree node also happens to be a [Traversable Tree]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/articles/2016/08/26/BinaryTreesPlayground-Part-I.html/#traversable-tree), its traversal is copied during initialization. Then, the initial model simply builds itself after the tree node with the initial non-valid `(x,y)` coordinates.

* Since the layout model tree structure should not change after initialization, `TreeLayout` overrides the default implementation of its `height` property. That helps avoid quadratic time during initialization as well as in future usages of the property.

* The layout is meant to be built in logical `Int` coordinates. These can then be easily mapped to physical dimensions with a few useful extension properties:
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

* Finally, for anyone wondering on the purpose of the `extras` var -- some of the more complex layout algorithms need to define many additional helper properties, and this is a way of enabling just that. Subclassing the model would obviously be another option, however in this case it'd be by far less clean and effective (as should become apparent in a few moments).


**The history of Tree Layouts**

At that point, we've defined our layout model and the only thing remaining is to actually give it some valid `(x,y)` coordinates.

Half of that already looks trivial, as we can simply take nodes' depths as their `y`s. So what is all the fuss about figuring out the remaining `x`s?

Well, turns out it is quite fascinating by itself and happens to be one of the classic NP-complete problems, with a relatively long history and many contributions from leading computer scientists.

One of the first algorithm was described by Donald Knuth[^1], and is basically a simple in-order traversal while incrementing an external x-position counter.
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

Here is how it looks when used in the playground -- <img style="width : 800px; height : 220px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/knuth.png">
while being among the simplest and fastest algorithms, the drawback is that the x-coordinate is never reused and thus the layout is quickly doing wide and can also easily digress into some weird tree shapes.

A few years after Knuth, Charles Wetherell and Alfred Shannon[^2] came up with an efficient technique for generating minimal width layouts. Instead of a single x-counter, they used independent counters per tree level. While processing the tree in pre-level order, each counter is updated per-level and therefore layout width grows conservatively.
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
* It's hard to describe this layout as even remotely "visually appealing" 😱
* For larger trees, the layout also quickly becomes kind of hard to follow

Two years later,  Edward Reingold and John Tilford[^3] continue building on the existing research and came up with lots of new concepts and an algorithm that produces nicely shaped layouts while still running in O(n) time.

Their algorithm is used as the default in [the playground](https://github.com/akpw/VisualBinaryTrees), and can be roughly described as the following:  <img style="width : 500px; height : 229px; float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/reingold.png">
1. Recursively build the left and right models' sub-trees
2. Shift the right model until on some layer it is as close to the right of the left model as possible
3. Place the root vertically one level above and horizontally half way between its children. If there is only one child, place the root at the same x as the child

While conceptually falling into the "almost simple" category 🤓, the hard problem is how to make this algorithm run in linear time. Simply shifting subtrees recursively would not work, as it would inevitably result in quadratic times.

To solve this, Reingold and Tilford started with breaking the problems into two parts: computation of the new positions for shifted subtrees and then its actual shifting.

To address the first part, they then introduced several clever concepts such as tree contours and threads. Contours are sequences of left-most and right most nodes for each level, and a node thread represents an additional relationship to the successor node in the same contour.

To solve moving all nodes in a subtree by the same amount, they then used the concept of `mods` introduced earlier in the already mentioned paper by Charles Wetherell and Alfred Shannon[^2]. A `mod` is an additional property to each node, that is used for calculating position of all the node's children. The positions are calculated in two passes, first giving each node a preliminary position and a mod during the bottom-up sweep and then adjusting their positions during a top-down traversal via adding  aggregated sum of mods on the path from the root.

This is how it looks in the `TreeLayout` extension used by the `TreeLayoutBuilderReingold`:

{% highlight swift %}
/// Additional TreeLayout attributes used for internal purposes
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

Full `TreeLayoutBuilderReingold` listing is a bit on the longish side, and is not shown here for practical purposes. For anyone curious to see how the above concepts are implemented, it lives [here](https://github.com/akpw/VisualBinaryTrees/blob/master/VisualBinaryTrees.playground/Sources/TreeDrawing/Layout/Builders/TreeLayoutBuilderReingold.swift) and should have enough comments for all key parts of the implementation.

There is a also more detailed description of the Reingold's et al. algorithms in a great paper of C. Buchheim, M. J Unger, and S. Leipert[^4]. Among other things, that paper also takes tree drawing to yet another level via describing an efficient, O(n) algorithm of drawing arbitrary N-ary trees.

Another valuable resource on the subject is a Python magazine article by Bill Mill[^5], which is also available online.[^6] In addition to going through the  concepts, Bill is also providing lots of Python code samples that help understand things from the perspective of a pragmatic developer.


***Conclusion***

This was the final part of the of the series on visualizing binary trees with Swift 3. At that point, you should be fully up-to-date on how to use [the playground](https://github.com/akpw/VisualBinaryTrees) with your own tree implementations as well as customizing the tree drawings with your own preset configurations and changing the architectural components for specific needs of your project.

* * *
[^1]: [Knuth, D.E. Acta Informatica (1971) 1: `Optimum binary search trees`](http://rd.springer.com/article/10.1007/BF00264289)

[^2]: [C. Wetherell, A. Shannon, `Tidy Drawings of Trees`, IEEE Transactions on Software Engineering.  1979 vol.5  Issue No.05 (September)](https://www.computer.org/csdl/trans/ts/1979/05/01702661-abs.html)

[^3]: [E. Reingold and J. Tilford. Tidier drawings of trees. IEEE Transactions on Software Engineering, 7(2):223–228, 1981.](https://www.researchgate.net/publication/3189395_Tidier_Drawings_of_Trees)

[^4]: [C. Buchheim, M. J Unger, and S. Leipert. Improving Walker's algorithm to run in linear time](https://www.researchgate.net/publication/226950337_Improving_Walker%27s_Algorithm_to_Run_in_Linear_Time)

[^5]: [Bill Mill, Drawing Presentable Trees. Python Magazine for August 2008.](https://doughellmann.com/blog/2008/08/29/python-magazine-for-august-2008/)

[^6]: [Bill Mill, Drawing Presentable Trees. Blog Article](http://billmill.org/pymag-trees/)

