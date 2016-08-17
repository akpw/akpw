---
layout: post
title: "Visual Binary Trees with Swift 3 Playgrounds, Part I"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Playgrounds, Mobile Development, Algorithms and Data Structures, PATs]
comments: true
---

This blog is a part of the series about visualizing binary trees with Swift 3. [The introduction to the series]({% post_url 2016-08-17-BinaryTreesPlayground %}) provides an overall summary and the context including a short demonstration video taken in the Swift Playground for iPad app.

This part touches on the general problem of tree drawing, and then goes into defining the Drawable Tree protocol that defines a binary tree that can be visualized. Additionally, since we also want to visualize tree traversal this part outlines a solution to pluggable traversal strategy that can be plugged into our drawable tree.


**Tree Drawing**

Tree-drawing is one of the classic NP-complete problems with a long history and multiple contributions from leading computer scientists.

The general goal of tree-drawing algorithms is to build a tree layout model where each node is assigned a unique `(x,y)` coordinate so that it then can be drawn in a visually meaningful way.

While the tree-drawing problem is quite fascinating by itself, for the sake of brevity this blog is not going to deep dive into the algorithmic part. Instead we will focus on building a Swift3 solution for drawing binary trees, with pluggable architecture that supports using various specific methods for building tree layout model.

As a proof of concept, we will use two different tree layout algorithms - one described by Donald Knuth[^1] and another by Charles Wetherell and Alfred Shannon[^2].


**Binary Tree in Swift**

Swift is a rich and flexible language, and it is no different when it comes to implementing trees. A classic way is of course via reference types, and it is also [possible with Swift enums](https://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/). While both are valid for their specific purposes, here we want something that would be able to draw both. With that in mind, let's define our `drawable binary tree` as the following:

### Base Tree protocol
{% highlight swift %}
public protocol BinaryTree: Equatable {
    associatedtype Element: Comparable
    var element: Element { get }
    var left: Self?  { get }
    var right: Self? { get }
{% endhighlight %}

This is obviously closer to the reference type approach, on the other hand it is relatively straightforward to have an enum-based tree to conform to this protocol as well:
{% highlight swift %}
public indirect enum TreeNodeEnum<Element: Comparable> {
    case empty
    case node(value: Element, left: TreeNodeEnum, right: TreeNodeEnum)
    public init(_ element: Element,
                  left: TreeNodeEnum = .empty, right: TreeNodeEnum = .empty) {
        self = .node(value: element, left: left, right: right)
    }
}
extension TreeNodeEnum: BinaryTree {
    public var left: TreeNodeEnum? {
        if case let .node(value: _, left: left, right: _) = self {
            if case .empty = left { return nil }
            return left
        }
        return nil
    }
    public var right: TreeNodeEnum? {
        if case let .node(value: _, left: _, right: right) = self {
            if case .empty = right { return nil }
            return right
        }
        return nil
    }
    public var element: Element {
        if case let .node(value: value, left: _, right: _) = self {
            return value
        }
        fatalError("element can not be empty")
    }
}
{% endhighlight %}
The only trade-off is that the root enum node should never be '.empty', in other words a tree node should always have its element.

With that out of the way, we should be already able to define a few common binary tree properties via Swift protocol extensions:

{% highlight swift %}
extension BinaryTree {
    public static func ==(lhs: Self, rhs: Self) -> Bool { return lhs.element == rhs.element }

    public var count: Int { return (left?.count ?? 0) + 1 + (right?.count ?? 0) }

    public var height: Int {
        var (leftHeight, rightHeight) = (0, 0)
        if let left = left { leftHeight = left.height + 1 }
        if let right = right { rightHeight = right.height + 1 }
        let height = Swift.max(leftHeight, rightHeight)
        return height
    }

    public var isBalanced: Bool {
        guard checkBalancedHeight() != -1 else { return false }
        return true
    }
    private func checkBalancedHeight() -> Int {
        // bottom-up, O(n) time + O(tree height) space
        var (leftBalancedHeight, rightBalancedHeight) = (0, 0)
        if let left = left {
            leftBalancedHeight = left.checkBalancedHeight()
            guard leftBalancedHeight != -1 else { return leftBalancedHeight }
        }
        if let right = right {
            rightBalancedHeight = right.checkBalancedHeight()
            guard rightBalancedHeight != -1 else { return rightBalancedHeight }
        }
        guard abs(leftBalancedHeight - rightBalancedHeight) <= 1 else { return -1 }
        return Swift.max(leftBalancedHeight, rightBalancedHeight) + 1
    }
}
{% endhighlight %}

The cool thing is that these properties will be available on any tree implementation conforming to the base protocol, be it a reference type or enum.

**Binary tree with pluggable traversals**

Since we also want to visualize tree traversal, lets enable plugging various traversal strategies into our tree.

First, let's define what traversal strategy is:
{% highlight swift %}
public protocol TraversalStrategy  {
    static func traversalSequence<Node: BinaryTree>(_ rootNode: Node) -> AnySequence<Node>
}
{% endhighlight %}

The only requirement for traversal strategy is to implement the `traversalSequence` function, which given a tree node would return a sequence of nodes of the same type.Here is an example of a specific pre-order traversal:
{% highlight swift %}
public struct PreOrderTraversalStrategy: TraversalStrategy {
    public static func traversalSequence<Node: BinaryTree>(_ rootNode: Node) -> AnySequence<Node> {
        return AnySequence {  Void -> AnyIterator<Node> in
            var stack = [rootNode]
            return AnyIterator {
                while !stack.isEmpty {
                    let node = stack.removeLast()
                    if let right = node.right { stack.append(right) }
                    if let left = node.left { stack.append(left) }
                    return node
                }
                return nil
            }
        }
    }
}
{% endhighlight %}

Now we can define a traversable tree as:
{% highlight swift %}
public protocol TraversableBinaryTree: BinaryTree, Sequence {
    var traversalStrategy: TraversalStrategy.Type?  { get }
}
extension TraversableBinaryTree {
    public func makeIterator() -> AnyIterator<Self> {
        guard let traversalStrategy = traversalStrategy else { return AnyIterator { nil } }
        return traversalStrategy.traversalSequence(self).makeIterator()
    }
}
{% endhighlight %}




It is a simple in-order traversal of a tree, with a global counter that is used as the x variable, then incremented at each node



A short definition of a binary tree is that it's a tree which is binary. In Swift terms, we can express this in a few lines of code:

{% highlight swift %}
public protocol BinaryTree: Equatable {
    associatedtype Element: Comparable
    var element: Element { get }
    var left: Self?  { get }
    var right: Self? { get }
{% endhighlight %}


{% highlight swift %}
extension BinaryTree {
    public static func ==<T: BinaryTree>(lhs: T, rhs: T) -> Bool { return lhs.element == rhs.element }

    public var count: Int { return (left?.count ?? 0) + 1 + (right?.count ?? 0) }

    public var height: Int {
        var (leftHeight, rightHeight) = (0, 0)
        if let left = left { leftHeight = left.height + 1 }
        if let right = right { rightHeight = right.height + 1 }
        let height = Swift.max(leftHeight, rightHeight)
        return height
    }
}
{% endhighlight %}


{% highlight swift %}
public protocol TraversableBinaryTree: BinaryTree, Sequence {
    var traversalStrategy: TraversalStrategy.Type?  { get set }
}
extension TraversableBinaryTree {
    public func makeIterator() -> AnyIterator<Self> {
        guard let traversalStrategy = traversalStrategy else { return AnyIterator { nil } }
        return traversalStrategy.traversalSequence(self).makeIterator()
    }
}
{% endhighlight %}

**Tree Traversal**
{% highlight swift %}
public protocol TraversalStrategy  {
    static func traversalSequence<Node: TraversableBinaryTree>(_ rootNode: Node) -> AnySequence<Node>
}
public struct PreOrderTraversalStrategy: TraversalStrategy {
    public static func traversalSequence<Node: TraversableBinaryTree>(_ rootNode: Node) -> AnySequence<Node> {
        return AnySequence {  Void -> AnyIterator<Node> in
            var stack = [rootNode]
            return AnyIterator {
                while !stack.isEmpty {
                    let node = stack.removeLast()
                    if let right = node.right { stack.append(right) }
                    if let left = node.left { stack.append(left) }
                    return node
                }
                return nil
            }
        }
    }
}
{% endhighlight %}


***Conclusion***

The article went through major steps of implementing a custom collection view flow layout, extending the concept of sections headers according to specific [requirements](#requirements).

The custom layout code shown in article is available as [an open source framework](https://github.com/akpw/AKPFlowLayout), accompanied by the [sample app](https://github.com/akpw/SwiftNetworkImages) that you can download and run / test in Xcode.

* * *
[^1]: [Knuth, D.E. Acta Informatica (1971) 1: `Optimum binary search trees`](http://rd.springer.com/article/10.1007/BF00264289)


[^2]: [C. Wetherell, A. Shannon, `Tidy Drawings of Trees`, IEEE Transactions on Software Engineering.  1979 vol.5  Issue No.05 (September)](https://www.computer.org/csdl/trans/ts/1979/05/01702661-abs.html)

