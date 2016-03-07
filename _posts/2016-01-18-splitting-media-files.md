---
layout: post
title: "Splitting media files"
description: "How to split audio by silence"
category: articles
tags: [batch-mp-tools, python, batch multimedia processing]
comments: true
---

The Part I of [BatchMP Tools](https://github.com/akpw/batch-mp-tools) tutorial went into some details of how to automatically break audio / video into mltiple pieces based on silence. The bmfp silencesplit command analyzes content of media files and then splits them into segments via detecting specified level of silence.

In addition to this method, sometimes it's usefull to split into segments based on desired segment duration or file size.  To do that with bmfp:

````
$ bmfp segment -sd '1:00'
2 media files to process
Processing 2 tasks with pool of 2 worker processes
Done processing
 /Users/AKPower/Downloads/Bird in Hand.mp3
 in 0:00:00.23
Done processing
 /Users/AKPower/Downloads/Born Barnstomers.mp3
 in 0:00:00.43
Finished running 2 tasks (Succeeded: 2, Failed: 0)
Total running time: 0:00:08.07
````

In its simplest form, the bmfp segment command above goes over all media files in curent directory splitting them into segments of 1 minute each.
Another common use case is taking a meda file's fragment, typically based on the fragment start time and desired duration:

````
$ bmfp -f 'Bird in Hand.mp3' fragment -fs '00:10'
1 media files to process
Done processing
 /Users/AKPower/Downloads/Bird in Hand.mp3
 in 0:00:00.2
Finished running 1 task (Succeeded: 1, Failed: 0)
Total running time: 0:00:04.8
````

The above command takes a fragment from the first 10 seconds till the end. Desired duration can be further tuned via ````-fd```` parameter, which in the above case was assumed to be the end of the meda file.
