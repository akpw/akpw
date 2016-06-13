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

This article is about extending the concept of section headers via adding a configurable pinnable, stretchable <img style="float: right; margin: 10px 0px 0px 10px;" src="{% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/akp_l.gif"> _global header_. That will allow building UI interfaces as the one shown here, which comes a part of the [sample app](https://github.com/akpw/SwiftNetworkImages). The sample app project relies on a simple, configurable [custom layout](https://github.com/akpw/AKPFlowLayout/blob/master/AKPFlowLayout/AKPCollectionViewFlowLayout.swift) that can be easily dropped into your project to enable same kind of functionality. The layout works with iOS9, and is optimized for performance via
using `invalidation contexts` to rebuild only those parts of UI that actually changed while scrolling.

### Requirements

Collection view flow layouts support the notion of headers and footers, and as of iOS9 also have a built-in support for floating section headers similar to those seen in `UITableView`. In addition to that, we want to be able to optionally add a `global header` that would always stay on top and also be stretchable. When a global header is on, the other sections should be sticking to it, otherwise they should behave exactly as defined by the flow layout `sectionHeadersPinToVisibleBounds` property.


**Getting started**

A good way to get into custom layouts is to start with built-in `UICollectionViewFlowLayout`.  Given Flow Layouts cover a broad range of line-oriented layouts with notion of rows and columns, tweaking UICollectionViewFlowLayout is often the best and fastest way to cover specific custom requirements.

That is no exception for our case as well. Since flow layouts already come with the concept of headers and footers, all we need to do is to leverage it and to build on top.

One additional consideration is what should be the source of data for our global section. Since collection view sections are data driven, shell we count on the data source to provide for our global section as well? Or perhaps shall it rather be treated as a static part of the layout, similar to decoration views?

There are obviously many possible approaches, including the one shown at a [WWDC 2014 session: Advanced User Interfaces with Collection Views](https://developer.apple.com/videos/play/wwdc2014/232/). The session introduces the concept of aggregate data sources, which among many other things include support for global sections.

After some considerations, my preference was towards keeping things simple and flexible. Our custom layout will rely on collection view datasource to provide the global section, and it will simply assume that it is the first section there. This way there is no need for dedicated hierarchy of data sources, and it allows our custom layout to be useful in a smart way without unnecessarily bloating things up.

**Section headers in a rect**

Since we want to base our implementation on subclassing `UICollectionViewFlowLayout`, most of the key ingredients are already provided to us out of the box.

The core idea is to plug into the `layoutAttributesForElementsInRect:` function and simply add our custom sections to the regular layoutAttributes created and handled by `UICollectionViewFlowLayout`
Let's start with writing a few helper functions that will help us deal with custom sections.

First, let's calculate the indexes of all sections confined in a rect. That should include our custom sections, both the global one and the custom headers "sticking" to it according to the [requirements](#requirements):

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
The above code goes through layout attributes, checking if they are associated with a section and adding the matches to a set of indexes. In case of global section, we always want to have it so it adds its index to the set as well.

Now it's trivial to calculate the indexes of just the custom sections in a rect, _excluding_ the regular headers provided by `UICollectionViewFlowLayout`:

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

With this done, we are ready to write our custom `layoutAttributesForElementsInRect(:)` function as the following:

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

The code above adds attributes for the custom sections to array of regular layout attributes, and then adjusts those so the global section is top and all other sections behave according to the [requirements](#requirements). The adjustment code is a bit on the lengthy side though still relatively straightforward:

{% highlight swift %}
// Adjusts frames of section headers
private func adjustLayoutAttributes(
                forSectionAttributes sectionHeadersLayoutAttributes: UICollectionViewLayoutAttributes)
                                                            -> (CGRect, Int) {
    guard let collectionView = collectionView else { return (CGRect.zero, 0) }
    let section = sectionHeadersLayoutAttributes.indexPath.section
    var sectionFrame = sectionHeadersLayoutAttributes.frame

    // 1. Let's establish the section boundaries:
    let (minY, maxY) = boundaryMetrics(forSectionAttributes: sectionHeadersLayoutAttributes)

    // 2. Let's also determine the height and insets of the first section,
    //    in case it's stretchable or serves as a global header
    let (firstSectionHeight, firstSectionInsets) = firstSectionMetrics()

    // 3. If within the above boundaries, the section should follow content offset
    //   (adjusting a few more things along the way)
    var offset = collectionView.contentOffset.y + collectionView.contentInset.top
    if (section > 0) {
        if layoutOptions.contains(.SectionsPinToGlobalHeaderOrVisibleBounds) {
            if layoutOptions.contains(.FirstSectionIsGlobalHeader) {
                // A global header adjustment
                offset += firstSectionHeight + firstSectionInsets.top
            }
            sectionFrame.origin.y = min(max(offset, minY), maxY)
        }
    } else {
        if layoutOptions.contains(.FirstSectionStretchable) && offset < 0 {
            // A stretchy header adjustment
            sectionFrame.size.height = firstSectionHeight - offset
            sectionFrame.origin.y += offset + firstSectionInsets.top
        } else if layoutOptions.contains(.FirstSectionIsGlobalHeader) {
            // A global header adjustment
            sectionFrame.origin.y += offset + firstSectionInsets.top
        } else {
            sectionFrame.origin.y = min(max(offset, minY), maxY)
        }
    }
    return (sectionFrame, section > 0 ? _zIndexForSectionHeader : _zIndexForSectionHeader + 1)
}
{% endhighlight %}

Basically, it establishes the section boundaries of (minY, maxY) and based on that configures `sectionFrame.origin.y` so it tries to follow the content offset. We also need to adjust `zIndex`, so the global header and sticky headers are always on top.


**Invalidation**

The key to building high-performance layout is to recompute only what's really changed. This way when e.g. user scrolls, our layout does not end endlessly calling computationally intensive `layoutAttributesForElementsInRect` but instead just makes a single call directly to `layoutAttributesForSupplementaryViewOfKind` thus minimizing the amount of data it recomputes.

To do that, we need a custom invalidation context to handle our portion of the layout while letting `UICollectionViewFlowLayout` to take care of the rest.

{% highlight swift %}
override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    guard _shouldDoCustomLayout else {
        return super.shouldInvalidateLayoutForBoundsChange(newBounds)
    }
    return true
}
/// Custom invalidation context
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
        // find and invalidate sections that would fall into the new bounds
        guard let sectionIdxPaths = sectionsHeadersIDxs(forRect: newBounds) else {return invalidationContext}

        // then invalidate
        let invalidatedIdxPaths = sectionIdxPaths.map { NSIndexPath(forItem: 0, inSection: $0) }
        invalidationContext.invalidateSupplementaryElementsOfKind(
            UICollectionElementKindSectionHeader, atIndexPaths: invalidatedIdxPaths )
    }
    return invalidationContext
}
{% endhighlight %}

Since we are handling the layout sections, we need to take care of invalidating those affected by relevant changes.  For all other cases, we rely on `UICollectionViewFlowLayout` to do its part of heavy lifting/


***Conclusion***

The article went through major steps of implementing a custom  collection view layout, extending the concept of sections via adding a configurable global section.

The code shown in article is a part of [sample app](https://github.com/akpw/SwiftNetworkImages), which you can download and run / test in Xcode.

* * *
