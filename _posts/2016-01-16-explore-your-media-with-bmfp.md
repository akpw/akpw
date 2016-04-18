---
layout: post
title: "Explore your media with BMFP"
description: "Exploring your media with BMFP"
category: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
comments: false
---

[BatchMP Tools](https://github.com/akpw/batch-mp-tools) provide variety of options of exploring media files right from the command line. For examples, to quickly see base media info such as duration, format, bit/sample rate, metadata tags, etc.:

````
$ bmfp
  |- 08 Queen Alice.mp3
      Format: MP3
      Duration: 0:00:55, Bit rate: 243kb/s, Sample rate: 44100Hz, Bit depth: n/a
  |- Bird in Hand.mp3
      Format: MP3
      Duration: 0:02:50, Bit rate: 320kb/s, Sample rate: 44100Hz, Bit depth: n/a
  |- Born Barnstomers.mp3
      Format: MP3
      Duration: 0:07:02, Bit rate: 192kb/s, Sample rate: 44100Hz, Bit depth: n/a
````
````
$ tagger -f '08 Queen Alice.mp3'
  |- 08 Queen Alice.mp3
      Title: Queen Alice
      Album: Looking-Glass EP
      Artist: DimensionBucket
      Album Artist: DimensionBucket
      Genre: Simple
      Year: 2014
      Track: 8
````
(The media files above are random samples from [FreePD.com](http://freepd.com))
With a bit more options, the tools can go way further to e.g. display information about sound volume levels or intervals of silence:

````
$ bmfp -f '08 Queen Alice.mp3'  print --show-volume
   |- 08 Queen Alice.mp3
      Format: MP3
      Duration: 0:00:55, Bit rate: 243kb/s, Sample rate: 44100Hz, Bit depth: n/a
      Max Volume: -0.0dB, Mean Volume: -18.7dB
````
````
$ bmfp -f '08 Queen Alice.mp3'  print --show-silence
  |- 08 Queen Alice.mp3
     Format: MP3
     Duration: 0:00:55, Bit rate: 243kb/s, Sample rate: 44100Hz, Bit depth: n/a
     Detected Silences:
      Start: 0:00:51.84, End: 0:00:54.31, Duration: 0:00:02.48
````

