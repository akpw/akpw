---
layout: post
title: "Visual Binary Trees with Swift 3, Part I"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Playgrounds, Mobile Development, Algorithms and Data Structures, PATs, Binary Trees]
comments: false
---


+ [Introduction & Summary]({% post_url 2016-08-26-BinaryTreesPlayground %})
+ Part I:  QuickLook-able Binary Tree with Pluggable Traversals
+ [Part II: The Drawing Architecture, Customization, and Tree Layouts]({% post_url 2016-09-8-BinaryTreesPlayground-Part-II %})

--------
This blog is a part of the series on visualizing binary trees with Swift 3. [The introduction]({% post_url 2016-08-26-BinaryTreesPlayground %}) provides an overall context and summary, including a short demo taken in the Swift Playground for iPad app. The playground with sample code and practical examples is [available at github](https://github.com/akpw/VisualBinaryTrees).

Since visualizing trees requires defining some sort of _quicklookable binary tree_, this part goes into just that. It is not meant to be an exhaustive description of a perfect Swift tree implementation, more like touching on the core principles for specific purposes of the series.

After reading this part, you should be fully up-to-date on how to use [the playground](https://github.com/akpw/VisualBinaryTrees) with your own tree implementations.


**Binary Tree in Swift**

Swift is a rich and flexible language, and it is no different when it comes to implementing binary trees. The classic way is of course via reference types, and in Swift it is also [possible with enums](https://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/).

As both approaches are valid for their use-cases, we want something that would represent a drawable tree regardless of its implementation details.

With that in mind, let's define our tree as the following:

###### Base Tree Protocol
{% highlight swift %}
public protocol BinaryTree: Equatable {
    associatedtype Element: Comparable
    var element: Element { get }
    var left: Self?  { get }
    var right: Self? { get }
{% endhighlight %}

Which gets us right to the main requirement of the series:

###### Requirements
> Visualize any binary tree that conforms to the  [base tree protocol](#base-tree-protocol).

The tree definition above is obviously closer to the reference type approach, on the other hand it is relatively straightforward to make an enum-based tree conform to it as well:

###### Sample Base Tree Implementation with Enum
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
Since our [base tree protocol](#base-tree-protocol) intentionally makes element non-optional, the only design "trade-off" is that the tree should should always be initialized with an element. While this restriction could be avoided via making the tree protocol element optional, this should be a cleaner approach.

With that out of the way, let's define a few common tree properties via Swift protocol extensions:

{% highlight swift %}
extension BinaryTree {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.element == rhs.element && lhs.left == rhs.left && lhs.right == rhs.right
    }

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

These are just a few that can be done at the protocol extension level, and the cool thing is that all of them  will be available to any tree implementation conforming to the base protocol, be it a reference type or enum.

Now that we have our base tree, let's outline the visualization interface for both Swift Playgrounds and the Xcode debugger:

###### QuickLookable Binary Tree
{% highlight swift %}
public protocol QuickLookableBinaryTree: BinaryTree, CustomPlaygroundQuickLookable {
    var quickLookView: (_ rootNode: Self) -> UIView { get }
}
/// CustomPlaygroundQuickLookable
extension QuickLookableBinaryTree {
    /// Playground quick look
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let treeView = quickLookView(self)
        return PlaygroundQuickLook(reflecting: treeView)
    }

    /// Xcode debugger quick look
    public var quickLookObject: PlaygroundQuickLook? {
        return customPlaygroundQuickLook
    }
    public func debugQuickLookObject() -> AnyObject? {
        return quickLookView(self)
    }

    /// Visualization as an image
    public var quickLookImage: UIImage? {
        let treeView = quickLookView(self)

        UIGraphicsBeginImageContextWithOptions(treeView.bounds.size, true, 0)
        defer { UIGraphicsEndImageContext() }

        treeView.drawHierarchy(in: treeView.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return image
    }
}
/// Default Visual Tree Config
extension QuickLookableBinaryTree {
    /// Configures visual tree representation
    public var quickLookView: (Self) -> UIView {
        // Default Tree View configuration
        return DefaultTreeDrawingConfig.configureTreeView
    }
}
{% endhighlight %}

In terms of its usage, `QuickLookableBinaryTree` is a fairly undemanding protocol that has all of its requirements covered by an extension.

The only question at the point might be, what does that `quickLookView` and its weird `DefaultTreeDrawingConfig.configureTreeView` really do?

Well, that is exactly what will uncover in the later parts of the series. But before we go there though, let's bring one more thing to the table.


**Binary tree with pluggable traversals**

By now, we have a definition of a binary tree that is ready to be visualized. However since the power of binary trees comes both from their internal organization and the ways they can be processed, it would be nice to extend our requirements to also include visualizing traversals.

Traversals are often implemented as a part of the tree itself, though they can be viewed as external behavior that thus should be injected rather than hard-coded. That would definitely give us more flexibility in design, so lets follow along these lines and enable pluggable traversals using the [strategy pattern](https://en.wikipedia.org/wiki/Strategy_pattern).

First, let's define a traversal strategy as:
{% highlight swift %}
public protocol TraversalStrategy  {
    static func traversalSequence<Node: BinaryTree>(_ rootNode: Node) -> AnySequence<Node>
}
{% endhighlight %}

The only requirement for our traversal strategy protocol is to implement the `traversalSequence` function, which takes a root tree node and returns a sequence of the child nodes. As an example, here is an implementation of the `pre-order` traversal:
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

Now let's use our base tree protocol to define a tree with pluggable traversals:

###### Traversable Tree
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

With these few lines of code, we did quite a few things. Any tree conforming to this protocol can  now be injected with a traversal strategy of our choosing, and we also made this tree a sequence. So we can iterate over the tree nodes in any order we like and as a bonus there are all these useful std functions as `filter`, `map`, `flatMap`, etc. that are available on any sequence implementation.

As a simple example of that, let makes another quick extension and give our tree a printable representation via its current traversal sequence:
{% highlight swift %}
public protocol TraversableBinaryTree: BinaryTree, Sequence,
                                                   CustomStringConvertible,
                                                   CustomDebugStringConvertible {
    var traversalStrategy: TraversalStrategy.Type?  { get }
}
extension TraversableBinaryTree {
    public var description: String {
        let currentTraversal = self.traversalStrategy == nil ? "" : "\(self.traversalStrategy!): "
        var values = [String]()
        for case let node as Self in self {
            values.append(String(describing: node.element))
        }
        return currentTraversal + values.joined(separator: ", ")
    }
    public var debugDescription: String { return description }
}
{% endhighlight %}

There are many other things that can be done via protocol extensions, but since the primary focus of the blog is visualizing trees that should be already enough to move on to the next part.

As a final touch, let's see how all of that would look like in a sample tree implementation.

**Sample Reference Type Tree implementation**

With lots of things already taken care on the base protocols level, cutting out a concrete tree implementation is now a breeze:

###### Sample Reference Tree
{% highlight swift %}
public final class TreeNodeRef<Element: Comparable>: QuickLookableBinaryTree,
                                                     TraversableBinaryTree  {
    fileprivate(set) public var element: Element
    public var left: TreeNodeRef?
    public var right: TreeNodeRef?

    // default is in-order traversal
    public var traversalStrategy: TraversalStrategy.Type? = InOrderTraversalStrategy.self
    public init(_ element: Element) { self.element = element }
}
extension TreeNodeRef: BinarySearchTree {
    public func insert(_ element: Element) {
        if element < self.element {
            if let l = left { l.insert(element) }
            else { left = TreeNodeRef(element) }
        } else {
            if let r = right { r.insert(element) }
            else { right = TreeNodeRef(element) }
        }
    }
}
{% endhighlight %}

And that's it! Our `TreeNodeRef` comes with all capabilities and properties defined in the protocols, such as `count`, `height`, `isBalanced` as well as ability to print out its elements and all standard functionality of Swift sequences. Finally, free conformance `QuickLookableBinaryTree` makes sure it now can also be visualized both in Xcode and on the iPad.

[The playground](https://github.com/akpw/VisualBinaryTrees) contains more complete examples with added capabilities such as initializing from arrays and sequences, building trees with minimal height, various traversals implementations, etc. Let's already see how things look there:  <img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/tree_playground.png">

Noticed how at line #22 we changed the tree traversal from default `in-order` to `level-order`, subsequently changing the tree's printable representation? While for someone like Crusty <img style="float: right; margin: 0px 0px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/crusty.png"> it's probably already enough to compile the tree shape in his head, for the rest of us visual representation should come in quite handy. And here is how that `level-order` traversal is visualized in the live view:
 <img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/traversal.gif">


**Sample Enum Type Tree implementation**

A sample enum tree implementation follows the same lines, though is a bit longer:

###### Sample Enum Tree with pluggable traversal
{% highlight swift %}
public indirect enum TreeNodeEnumTraversal<Element: Comparable> {
    case empty
    case node(value: Element,
              left: TreeNodeEnumTraversal,
              right: TreeNodeEnumTraversal,
              traversal: TraversalStrategy.Type?)
    public init(_ element: Element,
                left: TreeNodeEnumTraversal = .empty,
                right: TreeNodeEnumTraversal = .empty,
                // default is in-order traversal
                traversal: TraversalStrategy.Type? = InOrderTraversalStrategy.self) {
        self = .node(value: element, left: left, right: right, traversal: traversal)
    }
}
extension TreeNodeEnumTraversal: QuickLookableBinaryTree {
    public var left: TreeNodeEnumTraversal? {
        if case let .node(value: _, left: left, right: _, traversal: _) = self {
            if case .empty = left { return nil }
            return left
        }
        return nil
    }
    public var right: TreeNodeEnumTraversal? {
        if case let .node(value: _, left: _, right: right, traversal: _) = self {
            if case .empty = right { return nil }
            return right
        }
        return nil
    }
    public var element: Element {
        if case let .node(value: value, left: _, right: _, traversal: _) = self {
            return value
        }
        fatalError("element can not be empty")
    }
}
extension TreeNodeEnumTraversal: TraversableBinaryTree {
    public var traversalStrategy: TraversalStrategy.Type? {
        get {
            if case let .node(value: _, left: _, right: _, traversal: traversal) = self {
                return traversal.self
            }
            return nil
        }
        set(newValue) {
            if case let .node(value, left, right, _) = self {
                self = TreeNodeEnumTraversal(value, left: left, right: right, traversal: newValue)
            }
        }
    }
}
extension TreeNodeEnumTraversal: BinarySearchTree {
    public func insert(_ element: Element, traversalStrategy: TraversalStrategy.Type? = nil) -> TreeNodeEnumTraversal {
        switch self {
        case .empty:
            return TreeNodeEnumTraversal(element, left: .empty, right: .empty, traversal: traversalStrategy)
        case let .node(value, left, right, traversal):
            if element < value {
                return TreeNodeEnumTraversal(value, left: left.insert(element), right: right, traversal: traversal)
            } else {
                return TreeNodeEnumTraversal(value, left: left, right: right.insert(element), traversal: traversal)
            }
        }
    }
}
{% endhighlight %}


**Conclusion**

In this part, we defined a _binary tree with pluggable traversals that can be visualized_ both in in Swift playground and the Xcode debugger.

At that point, you should be fully up-to-date on how to use [the playground](https://github.com/akpw/VisualBinaryTrees) with your own tree implementations.

The next part of the series will continue with describing the drawing architecture and various customizations of its components. Starting with things like preset configurations for fonts, lines thickness, colors, grid, etc. and then moving on towards choosing a different 2D / 3D visualization technology, pluggable algorithms for multiple types of tree layouts, and more. [Keep tuned]({% post_url 2016-09-8-BinaryTreesPlayground-Part-II %})!


