---
layout: post
title: "Grouped UITableViews with no impact on your sanity"
description: "Grouped UITableViews in code"
category: articles
tags: [iOS, Objective-C, MobileDevelopment]
comments: true
---

UITableViews are ubiquitous  in almost any iOS app. Grouped table views show information in distinct sections, making it a clean visual interface for many different cases.

Grouped table views are useful though not always as trivial to implement and maintain. The main problem is, depending of individual sections complexity, trying to handle all of their (often unrelated) logic in a single ViewController can get quite messy. And when you're finally done with long switch statements, arrays of arrays of dictionaries, custom cells, various section logic handlers, etc. -- things are far from over. Just wait till you need to come back in a few weeks to fix a bug or implement an additional feature...


The main idea behind [GroupedUITableViews](https://github.com/akpw/Obj-C-FusionTables/tree/master/Example/Obj-C-FusionTablesSampleApp/View%20Controllers/Detail/GroupedUITableViews) was in moving the logic of individual sections to small dedicated controller classes. The main ViewController now just dispatches its TableView Data Source / Delegates methods to those classes and let them handle whatever needs to happen on individual sections levels. While there is some initial work creating the sections controllers, when things are set up everything becomes simple and real easy to maintain.

[GroupedUITableViews](https://github.com/akpw/Obj-C-FusionTables/tree/master/Example/Obj-C-FusionTablesSampleApp/View%20Controllers/Detail/GroupedUITableViews) are based on three main classes.

* ````GroupedTableViewController```` is the UITableViewController that dispatches its table view methods.

* ````GroupedTableUIController```` is the dispatcher class that simply keeps the register of specific sections and delivers messages to them.

* ````GroupedTableSectionController```` class represents a specific section in a grouped UITableView, implementing relevant table view methods and encapsulating all of its section-related controller logic.

