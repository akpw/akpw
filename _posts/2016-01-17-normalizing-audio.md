---
layout: post
title: "Normalizing audio"
description: "How to normalize audio"
category: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
comments: false
---

In general, audio normalization is the process of adding constant amount of gain to bring the average or peak amplitude to a target level.

Peak normalization is a specific type of normalization, where the gain is usually applied to bring the highest sound (PCM sample value or analog signal peak) to 0 dBFS, the loudest level allowed in a digital system.

Peak normalization with [BatchMP Tools](https://github.com/akpw/batch-mp-tools) is as easy as:

````
$ bmfp normalize
3 media files to process
Processing 3 tasks with pool of 2 worker processes
Already normalized:
    /Users/AKPower/Downloads/08 Queen Alice.mp3
Already normalized:
    /Users/AKPower/Downloads/Born Barnstomers.mp3
Done processing:
 /Users/AKPower/Downloads/Bird in Hand.mp3
 in 0:00:06.19
Finished running 3 tasks (Succeeded: 3, Failed: 0)
Total running time: 0:00:11.33
````

The ```bmfp normalize``` command in its simplest form runs over all media files in a given directory, processing all media files that are not yet normalized.
