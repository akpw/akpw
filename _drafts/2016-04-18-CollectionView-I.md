---
layout: post
title: "UICollectionView Custom Layouts, Part I"
description: "Swift UICollectionView series"
category: articles
tags: [iOS, Apple Swift, UICollectionView, Mobile Development]
comments: true
---

UICollectionView is an extremely powerfull UIKit component and typically my first choice for UI layouts of non-trivial complexity. Since its introduction in iOS6, UICollectionView has become one of the most essential skill for an experienced iOS developers, and is used all over the place in most attractive and immersive inferfaces of best-selling apps.

**The Basics**

A consize defenition of UICollectionView by Apple:

> The UICollectionView class manages an ordered collection of data items and presents them using customizable layouts. Collection views support customizable layouts that can be used to implement multi-column grids, tiled layouts, circular layouts, and many more. You can even change the layout of a collection view dynamically.

{% highlight swift %}
{% endhighlight %}



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
