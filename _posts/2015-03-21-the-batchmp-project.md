---
layout: post
title: "The BatchMP Tools Project"
description: "The BatchMP Tools Project"
category: articles
tags: [batch-mp-tools, python, batch multimedia processing]
comments: true
---


Back a few months ago, I wrote about [a rainy Sunday hacking to de-noise a bunch of old vacation videos]({% post_url 2014-11-24-batch-media-processing-ffmpeg-python%}). Turned out there had been a few similar weekends during the winter, and after some more experiments I eventually decided to turn it into a fun little open source project. The main idea was around batch management of media files, starting from base properties such as file names through tags / artwork metadata to various manipulation of the actual media content.

The [BatchMP Tools Project](https://github.com/akpw/batch-mp-tools) is written in Python 3.4, and currently consists of three main CLI tools:

+ [Renamer](https://github.com/akpw/batch-mp-tools#renamer) primarily takes care of shaping up files names, supporting various batch rename operations as well as flattening folders and cleaning up non-relevant files.

+ [Tagger](https://github.com/akpw/batch-mp-tools#tagger) manages media metadata, such as tags and artwork. Setting those in selected media file over multiple nested directories now becomes a breeze, with just a few simple commands working uniformly over almost any imaginable media formats. While being easy to use, Tagger also supports advanced metadata manipulation such as template processing, regexp-based replace in selected tags, etc.

+ [BMFP](https://github.com/akpw/batch-mp-tools#bmfp) is all about efficient media content processing, such as conversion between various formats, segmenting / fragmenting media files, de-noising audio, detaching individual audio / video streams, etc. As processing media files can typically be resource consuming BMFP is designed to take advantage of multi-core processors, automatically breaking up jobs into individual tasks that are then run as separate processes on CPU cores.

All three tools share the core concept of various transformations applied to generated stream of file systems entries. Consequently all of them also share the same set of global options, such as recursive processing, files / folders filtering, etc. A quick way to check on that is to run:

````
$ renamer -h
$ tagger -h
$ bmfp -h
````

This will display detailed information about the global options, as well as revealing specific commands available for each tool.
Getting more info on the commands level can be done using a similar approach, e.g. to learn about the tagger capitalize command:

````
$ tagger capitalize -h
````

In the upcoming blogs, I'll follow up with more practical examples and common use-cases.
