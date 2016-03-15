---
layout: post
title: "Obj-C-FusionTables Project"
description: "Obj-C-FusionTables Project"
category: articles
tags: [iOS, Objective-C, Obj-C-FusionTables, Mobile Development, Google Fusion Tables]
comments: true
image: obj-ft-v1.0.png
---

Obj-C-FusionTables
[Google Fusion Tables](http://www.google.com/drive/apps.html#fusiontables) offer a powerful combination of a big web store along with variety of ways to access and visualize the data. While still marked as 'experimental' it has reached its maturity with [Fusion Tables API v1.0](https://developers.google.com/fusiontables/), giving developers a clean & easy way to enrich their apps across variety of development platforms.

[One of my apps](https://itunes.apple.com/us/app/icasualtours/id496551101) has been using Google Fusion Tables since its early stages, following its development and leveraging new features as they were getting available. As with any new technology the process had not been entirely without a few bumps along the way, though great and instant responses from the Google development team has always kept me far from any doubts on Fusion Tables as the ultimate web backend choice for the app.

One potential obstacle for Fusion Tables in iOS apps is there is no official, dedicated Google API Objective-C API. While the existing libraries such as [gtm-oauth2](https://code.google.com/p/gtm-oauth2/) and [gtm-http-fetcher](https://code.google.com/p/gtm-http-fetcher/) are exceptionally well-written and provide all that is needed to work with Fusion Tables, being a general and a bit lower-level solution they can also put a lot of extra weight on developers's shoulders.

Being a happy use of Fusion Tables for a while, thought why not to share the experience and open-source a solution to the problem? So here comes [Obj-C-FusionTables](https://github.com/akpw/Obj-C-FusionTables), a light-weight library for integrating Fusion Tables into iOS apps built on top of the [gtm-oauth2](https://code.google.com/p/gtm-oauth2/) and [gtm-http-fetcher](https://code.google.com/p/gtm-http-fetcher/) libraries.

One of the primary goals of [Obj-C-FusionTables](https://github.com/akpw/Obj-C-FusionTables) was flexibility and easy-of-use. It starts right from adding it to an XCode project, just drag & drop a folder with a few [Obj-C-FusionTables](https://github.com/akpw/Obj-C-FusionTables) classes there and that's pretty much it. In case you are not already using the [gtm-oauth2](https://code.google.com/p/gtm-oauth2/) and [gtm-http-fetcher](https://code.google.com/p/gtm-http-fetcher/), these two Google libraries are not ARC-enabled and therefore their sources needs the -fno-objc-arc compiler flag as described here. All in all, the whole setup should not take more than a few minutes.

To find out more about [Obj-C-FusionTables](https://github.com/akpw/Obj-C-FusionTables), please visit the [project pages](https://github.com/akpw/Obj-C-FusionTables) at GitHub. Along with the core classes, there is a sample app that shows typical usage of [Obj-C-FusionTables](https://github.com/akpw/Obj-C-FusionTables) for common Fusion Tables operations such as listing tables, creating a table, setting Map styles, adding InfoWindow templates, SQL rows operations, etc.



