---
layout: post
title: "Custom UICollectionView: Global Headers"
description: "Swift UICollectionView series"
category: articles
tags: [iOS, Apple Swift, UICollectionView, Mobile Development]
comments: true
---

`UICollectionView` is an extremely powerful UIKit component, which since its introduction in iOS6 has become a typical choice for broad range of UI layouts with non-trivial complexity.

The power of Collection View is in its flexibility, with totally custom layouts and sleek dynamic, interactive transitions between them. This is also the main reason why proper handling of these aspects requires experience and sometimes could be way more complex compared to dealing with the rest of UIKit.

**Advanced Headers**

This article is about extending the concept of section headers via adding a configurable pinnable, stretchable <img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/akp_l.gif"> _global header_. That will allow building UI interfaces as the one shown here, which comes a part of the [sample app](https://github.com/akpw/SwiftNetworkImages). The sample app project relies on a simple, configurable [custom layout](https://github.com/akpw/AKPFlowLayout/blob/master/AKPFlowLayout/AKPCollectionViewFlowLayout.swift) that can be quickly dropped into your project to enable same kind of functionality. The layout works with iOS9, and is optimized for performance via
using `invalidation contexts` to rebuild only those parts of UI that actually changed while scrolling.

**Requirements**

Collection view flow layouts support the notion of headers and footers, and as of iOS9 also have a built-in support for floating section headers similar to those seen in `UITableView`. In addition to that, we want to be able to optionally add a `global header` that would always stay on top and also be stretchable. When a global header is on, the other sections should be sticking to it, otherwise they should behave exactly as defined by the flow layout `sectionHeadersPinToVisibleBounds` property.


**Getting started**

A good way to get into custom layouts is to start with built-in `UICollectionViewFlowLayout`.  Given Flow Layouts cover a broad range of line-oriented layouts with notion of rows and columns, tweaking UICollectionViewFlowLayout is often the best and fastest way to cover specific custom requirements.

That is no exception for our case as well. Since flow layouts already come with the concept of headers and footers, all we need to do is to leverage it and to build on top.

One additional consideration is what should be the source of data for our global section. Since collection view sections are data driven, shell we count on the data source to provide for our global section as well? Or perhaps shall it rather be treated as a static part of the layout, similar to decoration views?

There are obviously many possible approaches, including the one shown at a [WWDC 2014 session: Advanced User Interfaces with Collection Views](https://developer.apple.com/videos/play/wwdc2014/232/). The session introduces the concept of aggregate data sources, which among many other things include support for global sections.

After some considerations, my final preference was towards keeping things simple and flexible. Our custom layout will rely on collection view datasource to provide the global section, and it will simply assume that it is the first section there. This way there is no need for dedicated hierarchy of data sources, and it allows our custom layout to be useful in a smart way without unnecessarily bloating things up.

**Section headers in a rect**

 the key ingredients such layout attributes for cells and sections headers are already provided to us by `UICollectionViewFlowLayout`. All we need to do is to leverage and to build on top.

The core idea is to plug into the layoutAttributesForElementsInRect(:) method and simply add our custom sections to the regular UICollectionViewFlowLayout layoutAttributes.

Before we do that, let's write a few helper functions that will help us deal with custom sections.

First let's calculate the indexes of all sections confined in a rect, including our custom sections:

{% highlight swift %}
/// Given a rect, calculates indexes of confined section headers
/// including the custom headers
private func sectionsHeadersIDxs(forRect rect: CGRect) -> Set<Int>? {
    guard let layoutAttributes = super.layoutAttributesForElementsInRect(rect) else {return nil}

    let assosiatedWithSectionHeader: (attributes: UICollectionViewLayoutAttributes) -> Bool = {
        return  ( self.layoutOptions.contains(.SectionsPinToGlobalHeaderOrVisibleBounds) &&
                                                            $0.representedElementCategory == .Cell )
            || $0.representedElementKind == UICollectionElementKindSectionHeader
    }

    var headersIdxs = Set<Int>()
    for attributes in layoutAttributes
                    where assosiatedWithSectionHeader(attributes: attributes) {
        headersIdxs.insert(attributes.indexPath.section)
    }
    if layoutOptions.contains(.FirstSectionIsGlobalHeader) {
        headersIdxs.insert(0)
    }
    return headersIdxs
}
{% endhighlight %}
The above code simply goes through layout attributes, checking if they are associated with a section and adding the matches to a set of indexes. In case of global section, we always add its index to the set.

Now it's also trivial to calculate the indexes of our custom sections in a rect excluding the regular headers provided by `UICollectionViewFlowLayout`:

{% highlight swift %}
/// Given a rect, calculates the indexes of confined custom section headers
/// excluding the regular headers handled by UICollectionViewFlowLayout
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


With this done, we should be ready to write our custom `layoutAttributesForElementsInRect(:)` function as the following:

{% highlight swift %}
/// Adds custom headers to the  UICollectionViewFlowLayout attributes
override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard _shouldDoCustomLayout else { return super.layoutAttributesForElementsInRect(rect) }

    guard var layoutAttributes = super.layoutAttributesForElementsInRect(rect),
        // calculate custom headers that should be confined in the rect
          let customSectionHeadersIdxs = customSectionHeadersIdxs(rect) else { return nil }

    // now add our custom headers to the regular UICollectionViewFlowLayout layoutAttributes
    for idx in customSectionHeadersIdxs {
        let indexPath = NSIndexPath(forItem: 0, inSection: idx)
        if let attributes = super.layoutAttributesForSupplementaryViewOfKind(
                                                        UICollectionElementKindSectionHeader,
                                                        atIndexPath: indexPath) {
            // add the custom headers to the layout attributes
            layoutAttributes.append(attributes)
        }
    }
    // for section headers in layoutAttributes, now time to adjust their attributes
    for attributes in layoutAttributes where
        attributes.representedElementKind == UICollectionElementKindSectionHeader {
            (attributes.frame, attributes.zIndex) = adjustLayoutAttributes(forSectionAttributes: attributes)
    }
    return layoutAttributes
}
{% endhighlight %}

After figuring out  `customSectionHeadersIdxs(:)` function calculates






{% highlight swift %}
{% endhighlight %}


collectionViewContentSize
layoutAttributesForElementsInRect(:)
layoutAttributesForSupplementaryViewOfKind(:,:)
shouldInvalidateLayoutForBoundsChange:




{% highlight swift %}
{% endhighlight %}

asdasdasd
collectionViewContentSize()
layoutAttributesForElementsInRect(_ rect: CGRect)
layoutAttributesForItemAtIndexPath(_ indexPath: NSIndexPath)


layoutAttributesForElementsInRect: doesn't necessarily call layoutAttributesForItemAtIndexPath:.

In fact, if you subclass UICollectionViewFlowLayout, the flow layout will prepare the layout and cache the resulting attributes. So, when layoutAttributesForElementsInRect: is called, it won't ask layoutAttributesForItemAtIndexPath:, but just uses the cached values.



**Invalidation**
he last piece involves the new stuff from iOS 7, and that’s invalidation. I’m going to go through this pretty quickly, but it’s pretty powerful. Invalidation allows you to invalidate pieces of your layout, and provide new attributes for those pieces of the layout. You can invalidate the layout from your own code, or the layout can be invalidated by other pieces of code as well. In the case of self-sizing cells, which we’re using here, the UITableViewCell is given a chance to say, “I want to be this size, not the size you told me.” When that happens, it calls the layout invalidation methods,and allows you to redo your layout based on the size the cell wants to be.

When you’re doing invalidation, there are a few things you need to override, including shouldInvalidateLayoutForBoundsChange. You would do that if you wanted to do things like have the bounds change when the view scrolls. It would call in every frame as you’re scrolling. But for preferred layout attributes, override shouldInvalidateLayoutForPreferredLayoutAttributes. In the case of the collection view self-sizing cells, the collection view generates a new instance of CollectionViewLayoutAttributes. It then hands you original size you sent and the size that the cell would prefer to use, and allows you to choose which to go with.


***Conclusion***

This introductory part of the series covered Grand Central Dispatch queues and base tasks dispatching, along with common practices for selecting appropriate queue types.

All code examples are available for download in [this playground]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/GCD_Part_I.playground.zip)

The next part will go deeper into QOS features as well as diving into more advanced GCD usage patterns.



======

 Since its introduction in iOS6, UICollectionView has become one of the most essential skill for an experienced iOS developers, and is used all over the place in most attractive and immersive inferfaces of best-selling apps.


In general, a custom UICollectionView layout takes subclassing of UICollectionViewLayout which is an abstract base class for positioning cell views and their supplementary and decoration views.

But rather than subclass this directly, most applications will opt to use or subclass UICollectionViewFlowLayout.

When designing your custom layouts, you can improve performance by invalidating only those parts of your layout that actually changed. When you change items, calling the invalidateLayout method forces the collection view to recompute all of its layout information and reapply it. A better solution is to recompute only the layout information that changed, which is exactly what invalidation contexts allow you to do. An invalidation context lets you specify which parts of the layout changed. The layout object can then use that information to minimize the amount of data it recomputes.


A consize defenition of UICollectionView by Apple:

> The UICollectionView class manages an ordered collection of data items and presents them using customizable layouts. Collection views support customizable layouts that can be used to implement multi-column grids, tiled layouts, circular layouts, and many more. You can even change the layout of a collection view dynamically.
