---
layout: post
title: "Visualizing Binary Trees with Swift 3 Playgrounds, Part III"
description: "Swift 3 Playgrounds"
category: articles
tags: [iOS, Apple Swift, Algorithms and Data Structures, Playgrounds, PATs, ScrollView, CoreGraphics, Mobile Development]
comments: true
---

It's been well over a month past WWDC 2016, and as the dust has been settling a lot of people has been covering all the majour announcements. One of the most recurring topics is playgrounds on iPad

Given Swift3 is accepting breaking code changes and Xcode beta3 is relatively stable, thought it'd be interesting


**Playgrounds for iPad**
primarily for education, to teach people how torwrite code. Since , ... visualizing data structures.
<img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/tree1.png">



<iframe width="895" height="656" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/VisualBinaryTrees.mp4?autoplay=false&cc_load_policy=0" frameborder="0" allowfullscreen></iframe>

**Binary Tree**
To visualize a binary tree, we need to first have one

Protocol:
{% highlight swift %}
public protocol BinaryTreeType: class, Equatable {
    associatedtype Element: Comparable
    var element: Element { get }
    var left: Self?  { get }
    var right: Self? { get }
    var height: Int { get }
    var traversalSequence: (Self) -> AnySequence<Element> { get set }
}
public func ==<T: BinaryTreeType where T.Element: Equatable>(lhs: T, rhs: T) -> Bool
{ return lhs.element == rhs.element }
{% endhighlight %}

{% highlight swift %}
public final class TreeNode<Element: Comparable>: BinaryTreeType {
    private(set) public var element: Element
    private(set) public var left: TreeNode?
    private(set) public var right: TreeNode?

    public init(_ element: Element) { self.element = element }
    // default is in-order traversal
    public var traversalSequence: (TreeNode) -> AnySequence<Element> = InOrderTraversalStategy.traversalSequence
}
{% endhighlight %}


**Tree Traversal**
{% highlight swift %}
public protocol Traversable  {
    static func traversalSequence<Node: BinaryTreeType>(_ rootNode: Node) -> AnySequence<Node.Element>
}

extension Traversable {
    // Default is in-order traversal
    public static func traversalSequence<Node: BinaryTreeType>(_ rootNode: Node) -> AnySequence<Node.Element> {
        return AnySequence {  Void -> AnyIterator<Node.Element> in
            var currentNode: Node? = rootNode
            var stack = [Node]()
            return AnyIterator {
                while !(currentNode == nil && stack.isEmpty) {
                    if let node = currentNode {
                        stack.append(node)
                        currentNode = node.left
                    } else {
                        let node = stack.removeLast()
                        currentNode = node.right
                        return node.element
                    }
                }
                return nil
            }
        }
    }
}
{% endhighlight %}

We can now define a inline traversal strategy as
{% highlight swift %}
public struct InOrderTraversalStategy: Traversable {}
{% endhighlight %}

and make it a default :
{% highlight swift %}
public final class TreeNode<Element: Comparable>: BinaryTreeType {
    private(set) public var element: Element
    private(set) public var left: TreeNode?
    private(set) public var right: TreeNode?

    public init(_ element: Element) { self.element = element }
    // default is in-order traversal
    public var traversalSequence: (TreeNode) -> AnySequence<Element> = InOrderTraversalStategy.traversalSequence
}
{% endhighlight %}

{% highlight swift %}
{% endhighlight %}


{% highlight swift %}
{% endhighlight %}


{% highlight swift %}
{% endhighlight %}


{% highlight swift %}
{% endhighlight %}


**Drawing Model**


**Core Graphics**
UIBezierPath is the UIKit wrapper around CGPath




**Global Header**

This article is about extending the concept of collection view section headers via adding a configurable, pinnable, and stretchable <img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/akp_l.gif"> _global header_. That will allow building UI interfaces like the one shown here, which comes a part of the [sample app](https://github.com/akpw/SwiftNetworkImages). The sample app project relies on a simple, configurable [custom layout](https://github.com/akpw/AKPFlowLayout/blob/master/AKPFlowLayout/AKPFlowLayout.swift) that is available as [an open source framework](https://github.com/akpw/AKPFlowLayout) and can used in your project to enable the same kind of functionality. The layout works with both iOS8 and iOS9, and is optimized for performance via
using invalidation contexts to rebuild only those parts of UI that actually changed during scrolling.

### Requirements

> The build-in collection view Flow Layout has the notion of section headers and footers, and as of iOS9 also provides built-in support for floating section headers similar to those seen in table views. In addition to that, we want to be able to optionally add a _global header_ that would always stay on top and be stretchable. When a global header is turned on, the other sections should be sticking to it when scrolling otherwise they should behave exactly as defined by the Flow Layout's `sectionHeadersPinToVisibleBounds` property. The layout should work for both iOS8 and iOS9.

**Getting started**

In general, a good way to get into custom layouts is to start with built-in Flow Layout.  Given it covers a large range of line-oriented layouts with notion of rows and columns, tweaking `UICollectionViewFlowLayout` is often the best and fastest way to achieve desired customizations. Apple strongly recommends this approach, and provides [specific scenarios for subclassing](https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/UsingtheFlowLayout/UsingtheFlowLayout.html#//apple_ref/doc/uid/TP40012334-CH3-SW4).

That is clearly no exception for our case. Since the Flow Layout already comes with support for section headers and footers, all we need to do is to leverage it and to build on top.

Before diving into implementation, there are a few things to consider regarding the concept of global section header. Since collection view sections are data driven, shell we count on the data source to provide for our global section as well? Or perhaps shall it rather be treated as a static part of the layout, similar to decoration views?

There are obviously multiple possible approaches, including the one shown at a [WWDC 2014 session: Advanced User Interfaces with Collection Views](https://developer.apple.com/videos/play/wwdc2014/232/). The session introduced the idea of aggregate data sources, which among many other things include support for global sections.

After some thinking on the subject, my preference was towards keeping things simple and flexible. Our custom layout will rely on collection view datasource to provide the global section, and it will simply assume that it will be the first section there. This way there is no need for dedicated hierarchy of data sources, and it will allow our custom layout to be useful in a smart way without unnecessarily bloating things up.

**Custom Layout Attributes**

Since the [requirements](#requirements) include section header stretching, our custom layout will have to manipulate the headers' frames. The dynamic height changes should be propagated back to collection view items, so that they can adjust their UI in corresponding `applyLayoutAttributes:` methods. In order to enable such communication, let's subclass `UICollectionViewLayoutAttributes` and define the `stretchFactor` property:
{% highlight swift %}
public class AKPFlowLayoutAttributes: UICollectionViewLayoutAttributes {
    /// Set by AKPFlowLayout when managing section headers stretching
    public var stretchFactor: CGFloat = 0

    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let aCopy = super.copyWithZone(zone) as! AKPFlowLayoutAttributes
        aCopy.stretchFactor = stretchFactor
        return aCopy
    }

    override public func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? AKPFlowLayoutAttributes {
            if attributes.stretchFactor == stretchFactor {
                return super.isEqual(object)
            }
        }
        return false
    }
}
{% endhighlight %}
As collection view copies layout attribute objects, we also have to conform to the NSCopying protocol and implement its methods.

**Section headers in a rect**

The central place for a custom layout implementation is typically in the `layoutAttributesForElementsInRect:` function, which  returns an array of layout attributes containing a layout attribute for each cell, supplementary, or decoration view that should be displayed in the passed rectangle.

Since we're going to move forward with our implementation via subclassing `UICollectionViewFlowLayout`, most of the key ingredients there should already be provided to us out of the box.

The main idea is to simply add our custom sections' layout attributes to those already handled by the Flow Layout.

Before we do that, let's first write a few helper functions that will help us deal with collection view sections.

First, let's calculate the indexes of _all sections confined in a rect_. That should include both regular sections and the custom sections, i.e the global header and the headers that are currently "sticking" to it:

{% highlight swift %}
// Given a rect, calculates indexes of all confined section headers
// _including_ the custom headers
private func sectionsHeadersIDxs(forRect rect: CGRect) -> Set<Int>? {
    guard let layoutAttributes = super.layoutAttributesForElementsInRect(rect)
                                                as? [AKPFlowLayoutAttributes] else {return nil}
    let sectionsShouldPin = layoutOptions.contains(.SectionsPinToGlobalHeaderOrVisibleBounds)

    var headersIdxs = Set<Int>()
    for attributes in layoutAttributes
            where attributes.visibleSectionHeader(sectionsShouldPin) {
        headersIdxs.insert(attributes.indexPath.section)
    }
    if layoutOptions.contains(.FirstSectionIsGlobalHeader) {
        headersIdxs.insert(0)
    }
    return headersIdxs
}
private extension AKPFlowLayoutAttributes {
    // Determines if element is a section, or is a cell in a section with custom header
    func visibleSectionHeader(sectionsShouldPin: Bool) -> Bool {
        let isHeader = representedElementKind == UICollectionElementKindSectionHeader
        let isCellInPinnedSection = sectionsShouldPin && ( representedElementCategory == .Cell )
        return isCellInPinnedSection || isHeader
    }
}
{% endhighlight %}
The code above builds a set of all section indexes, via going through layout attributes and searching for elements that are:

- regular sections
- cells that are in a section with custom header

The sections indexes of all matching elements are added to the set of unique indexes. In case of the global section, we always want to have it so it is added there as well.

Now it's trivial to calculate the indexes of only _the custom sections in a rect_, i.e. excluding the regular headers provided by `UICollectionViewFlowLayout`:

{% highlight swift %}
// Given a rect, calculates the indexes of confined custom section headers
// _excluding_ the regular headers handled by UICollectionViewFlowLayout
private func customSectionHeadersIdxs(rect: CGRect) -> Set<Int>? {
    guard let layoutAttributes = super.layoutAttributesForElementsInRect(rect),
          var sectionIdxs = sectionsHeadersIDxs(forRect: rect)  else {return nil}

    // remove the sections that should already be taken care of by UICollectionViewFlowLayout
    for attributes in layoutAttributes
        where attributes.representedElementKind == UICollectionElementKindSectionHeader {
            sectionIdxs.remove(attributes.indexPath.section)
    }
    return sectionIdxs
}
{% endhighlight %}


**Layout Attributes headers in a rect**

Now we are ready to write our `layoutAttributesForElementsInRect(:)` function as the following:

{% highlight swift %}
/// Returns layout attributes for specified rectangle, with added custom headers
override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard shouldDoCustomLayout else { return super.layoutAttributesForElementsInRect(rect) }

    guard var layoutAttributes = super.layoutAttributesForElementsInRect(rect) as? [AKPFlowLayoutAttributes],
          // calculate custom headers that should be confined in the rect
          let customSectionHeadersIdxs = customSectionHeadersIdxs(rect) else { return nil }

    // add the custom headers to the regular UICollectionViewFlowLayout layoutAttributes
    for idx in customSectionHeadersIdxs {
        let indexPath = NSIndexPath(forItem: 0, inSection: idx)
        if let attributes = super.layoutAttributesForSupplementaryViewOfKind(
                                                UICollectionElementKindSectionHeader,
                                                atIndexPath: indexPath) as? AKPFlowLayoutAttributes {
            layoutAttributes.append(attributes)
        }
    }
    // for section headers, need to adjust their attributes
    for attributes in layoutAttributes where
        attributes.representedElementKind == UICollectionElementKindSectionHeader {
            (attributes.frame, attributes.zIndex) = adjustLayoutAttributes(forSectionAttributes: attributes)
    }
    return layoutAttributes
}
{% endhighlight %}

The code above adds our custom sections attributes to the array of regular layout attributes, and then adjusts those so that the global section is always top and all other sections behave according to the [requirements](#requirements).

The `adjustLayoutAttributes:` function is a bit on the lengthy side though still relatively straightforward:

{% highlight swift %}
// Adjusts layout attributes of section headers
private func adjustLayoutAttributes(forSectionAttributes
                                        sectionHeadersLayoutAttributes: AKPFlowLayoutAttributes)
                                                                                         -> (CGRect, Int) {
    guard let collectionView = collectionView else { return (CGRect.zero, 0) }
    let section = sectionHeadersLayoutAttributes.indexPath.section
    var sectionFrame = sectionHeadersLayoutAttributes.frame

    // 1. Establish the section boundaries:
    let (minY, maxY) = boundaryMetrics(forSectionAttributes: sectionHeadersLayoutAttributes)

    // 2. Determine the height and insets of the first section,
    //    in case it's stretchable or serves as a global header
    let (firstSectionHeight, firstSectionInsets) = firstSectionMetrics()

    // 3. If within the above boundaries, the section should follow content offset
    //   (adjusting a few more things along the way)
    var offset = collectionView.contentOffset.y + collectionView.contentInset.top
    if (section > 0) {
        // The global section
        if layoutOptions.contains(.SectionsPinToGlobalHeaderOrVisibleBounds) {
            if layoutOptions.contains(.FirstSectionIsGlobalHeader) {
                // A global header adjustment
                offset += firstSectionHeight + firstSectionInsets.top
            }
            sectionFrame.origin.y = min(max(offset, minY), maxY)
        }
    } else {
        if layoutOptions.contains(.FirstSectionStretchable) && offset < 0 {
            // Stretchy header
            if firstSectionHeight - offset < firsSectionMaximumStretchHeight {
                sectionFrame.size.height = firstSectionHeight - offset
                sectionHeadersLayoutAttributes.stretchFactor = fabs(offset)
                previousStretchFactor = sectionHeadersLayoutAttributes.stretchFactor
            } else {
                // need to limit the stretch
                sectionFrame.size.height = firsSectionMaximumStretchHeight
                sectionHeadersLayoutAttributes.stretchFactor = previousStretchFactor
            }
            sectionFrame.origin.y += offset + firstSectionInsets.top
        } else if layoutOptions.contains(.FirstSectionIsGlobalHeader) {
            // Sticky header position needs to be relative to the global header
            sectionFrame.origin.y += offset + firstSectionInsets.top
        } else {
            sectionFrame.origin.y = min(max(offset, minY), maxY)
        }
    }
    return (sectionFrame, zIndexForSection(section))
}
{% endhighlight %}

Basically, the function first establishes the section boundaries of (minY, maxY) and then based on that configures `sectionFrame.origin.y` so it intelligently follows the collection view content offset.

If stretching a header, the section frame height is set accordingly and the stretch information is recorded in our custom layout attributes `stretchFactor` property.

Finally, we also need to manage sections' `zIndex`, so that the global header and sticky headers are always on top.


**Custom Layout Invalidation**

The key to building high-performance layout is to recompute only those parts that actually changed. This way when a user scrolls, we will not end up repeatedly calling computationally intensive `layoutAttributesForElementsInRect:` but instead whenever possible just be calling `layoutAttributesForSupplementaryViewOfKind` directly. According to Apple's documentation:

> an invalidation context lets you specify which parts of the layout changed. To define a custom invalidation context for your layout, subclass the UICollectionViewLayoutInvalidationContext class. In your subclass, define custom properties that represent the parts of your layout data that can be recomputed independently.

For our case the Flow Layout is already using its invalidation context for optimized layout updates. Therefore, instead of creating our own custom invalidation context class it is sufficient to simply plug into the existing invalidation process.

Since we are handling the layout for collection view sections, we should also take care of invalidating those that are affected by the bounds changes:

{% highlight swift %}
override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    guard _shouldDoCustomLayout else {
        return super.shouldInvalidateLayoutForBoundsChange(newBounds)
    }
    return true
}
/// Custom invalidation
override public func invalidationContextForBoundsChange(newBounds: CGRect)
                                    -> UICollectionViewLayoutInvalidationContext {
    guard _shouldDoCustomLayout,
        let invalidationContext = super.invalidationContextForBoundsChange(newBounds)
                                    as? UICollectionViewFlowLayoutInvalidationContext,
        let oldBounds = collectionView?.bounds
                                    else { return super.invalidationContextForBoundsChange(newBounds) }
    // Size changes?
    if oldBounds.size != newBounds.size {
        // re-query the collection view delegate for metrics such as size information etc.
        invalidationContext.invalidateFlowLayoutDelegateMetrics = true
    }

    // Origin changes?
    if oldBounds.origin != newBounds.origin {
        // find and invalidate the sections that would fall into the new bounds
        guard let sectionIdxPaths = sectionsHeadersIDxs(forRect: newBounds) else {return invalidationContext}

        // then invalidate
        let invalidatedIdxPaths = sectionIdxPaths.map { NSIndexPath(forItem: 0, inSection: $0) }
        invalidationContext.invalidateSupplementaryElementsOfKind(
            UICollectionElementKindSectionHeader, atIndexPaths: invalidatedIdxPaths )
    }
    return invalidationContext
}
{% endhighlight %}

**Just one more thing**

At that point, we are almost done! However the [requirements](#requirements) mention `sectionHeadersPinToVisibleBounds`, which is a boolean property of `UICollectionViewFlowLayout` that enables out-of-the-box sticky headers in iOS9. Since we are now explicitly managing the sections headers, we also need to make sure there is no interference with the built-in implementation. The easiest way around that might be doing something along of lines of:
{% highlight swift %}
override public var sectionHeadersPinToVisibleBounds: Bool {
    didSet {
        if sectionHeadersPinToVisibleBounds {
            print("NO!!! 🙀")
            sectionHeadersPinToVisibleBounds = false
        }
    }
}
{% endhighlight %}

The problem is that the `sectionHeadersPinToVisibleBounds` property is not available in iOS8, and so far there seems to be no reasonable way to use Swift property observers with conditional compilation. Luckily, we can still fall back to using KVO:

{% highlight swift %}
override public init() {
    super.init()
    if #available(iOS 9.0, *) {
        addObserver(self, forKeyPath: "sectionHeadersPinToVisibleBounds",
                                                options: .New, context: &AKPFlowLayoutKVOContext)
    }
}
deinit {
    if #available(iOS 9.0, *) {
        removeObserver(self, forKeyPath: "sectionHeadersPinToVisibleBounds", context: &AKPFlowLayoutKVOContext)
    }
}
override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                            change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if context == &AKPFlowLayoutKVOContext {
        if let newValue = change?[NSKeyValueChangeNewKey],
            boolValue = newValue as? Bool where boolValue {
            print("AKPFlowLayout supports sticky headers by default, therefore " +
                "the built-in functionality via sectionHeadersPinToVisibleBounds has been disabled")
            if #available(iOS 9.0, *) { sectionHeadersPinToVisibleBounds = false }
        }
    } else {
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
}
{% endhighlight %}

This way our custom layout will work both for iOS8 and iOS9, and there will be no collision with the iOS9 built-in sticky headers functionality.


***Conclusion***

The article went through major steps of implementing a custom collection view flow layout, extending the concept of sections headers according to specific [requirements](#requirements).

The custom layout code shown in article is available as [an open source framework](https://github.com/akpw/AKPFlowLayout), accompanied by the [sample app](https://github.com/akpw/SwiftNetworkImages) that you can download and run / test in Xcode.

* * *




Apart from usual beta-related glitches, I really enjoyed working with Swift 3 and playgrounds both in Xcode8 and on iPad.

