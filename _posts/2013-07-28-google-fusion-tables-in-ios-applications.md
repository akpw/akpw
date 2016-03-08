---
layout: post
title: "Google Fusion Tables in iOS Applications"
description: "Google Fusion Tables in iOS Applications"
category: articles
tags: [iOS, Objective-C, Obj-C-FusionTables, MobileDevelopment, Google Fusion Tables]
comments: true
---

Based on [recent questions](http://stackoverflow.com/questions/17896012/creating-fusion-table-from-ios/17896079#17896079) of stackoverflow, looks like iOS developers are starting to look at using [Google Fusion Tables](http://www.google.com/drive/apps.html#fusiontables) in their apps. Not a surprise,  as Fusion Tables looks like a promising technology that has reached maturity with the [Fusion Tables API v1.0](https://developers.google.com/fusiontables/).
One potential gotchas along the way though is the fact there is not much of an official Objective-C API for Fusion Tables. Instead iOS developers are pointed towards using lower level solutions like leveraging existing [gtm-oauth2](https://github.com/google/gtm-oauth2) and [gtm-http-fetcher](https://github.com/google/gtm-http-fetcher) Google Objective-C libraries to communicate with Fusion Tables via HTTP requests. While a viable solution, it also puts quite a lot on developers shoulders essentially delaying their apps time-to-market in a non-trivial way.
Based on a few chats and questions from people, thought I'd put together a project to simplify integrating Fusion Tables into iOS apps. In the next blog, will describe on the approach and hopefully present a functional GitHub project. Keep tuned...
