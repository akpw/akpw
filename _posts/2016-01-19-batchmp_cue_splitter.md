---
layout: post
title: "BatchMP Cue Splitter"
description: "How to split audio into multiple tracks using Cue sheets"
category: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
comments: false
---

A cue sheet is a metadata file that can describe layout of audio and data CDs. Cue sheets are stored as plain text files and commonly have a ".cue" filename extension. For example, a multi-track audio CD can be ripped to a single audio file with a cue sheet describing individual tracks position, length, as well as general information such as track titles, performer, etc.
An example of such cue file would look something like:

````
PERFORMER "CD Performer"
TITLE "CD Title"
REM GENRE "Classical"
REM DATE "2016"
FILE "~\MYAUDIO.WAV" WAVE
 TRACK 01 AUDIO
  INDEX 01 00:00:00
 TRACK 02 AUDIO
  INDEX 01 05:50:65
 ...
````

Cue files can therefore be  useful when dividing audio stored in a single file into multiple songs or tracks.
With [BatchMP Tools](https://github.com/akpw/batch-mp-tools) it can be done with a single ````bmfp cuesplit```` command. The command will go through files in a given directory, find relevant *.cue files and then intelligently extract individual media files.

````
$ bmfp cuesplit -tf mp3
16 media files to process
Processing 16 tasks with pool of 2 worker processes
Done processing
 ~\MYAUDIO.WAV, TRACK 01
 in 0:00:00.46
 ~\MYAUDIO.WAV, TRACK 02
 in 0:00:01.18
...
Finished running 16 tasks (Succeeded: 16, Failed: 0)
Total running time: 0:02:51.01
````
