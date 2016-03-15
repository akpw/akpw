---
layout: post
title: "BatchMP Tools Tutorial, Part I"
description: "BatchMP Tools Tutorial, Part I"
category: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
comments: true
---

Content:

+ [Part I]({% post_url 2015-04-10-batchmp-tutorial-part-i %}): splitting a long media file into multiple pieces with bmfp
+ [Part II]({% post_url 2015-04-11-batchmp-tutorial-part-ii %}): renaming files with renamer
+ [Part III]({% post_url 2015-04-12-batchmp-tutorial-part-iii %}): setting tags and artwork with tagger


Following up on [the previous blog]({% post_url 2015-03-21-the-batchmp-project %}), this article is a tutorial on practical usage of [BatchMP Tools](https://github.com/akpw/batch-mp-tools) for common audio / video media processing.

Let's start with some quality media available in the public domain. Not long ago I was surprised to find an excellent performance of Chopin Etudes Op. 25 by Daniil Trifonov, graciously provided for public download via a [WGBH podcast](http://www.wgbh.org/programs/Classical-Performance-Podcast-391/episodes/Chopin-with-Daniil-Trifonov-60828).

So let's download and look at what's inside using ```bmfp```:

````
$ bmfp
~/Desktop/_podcast
  |- pod150311DaniilTrifonov.mp3
      Format: MP3
      Duration: 0:33:25, Bit rate: 128kb/s, Sample rate: 44100Hz
1 media file, 0 folders
````

Running ```$ bmfp``` without any parameters defaults to ```$ bmfp print```, which prints out a brief info about all media files in the current directory. While there are plenty of other printing options available (```$ bmfp -h``` and ```$ bmfp print -h``` can show all of them), that is already sufficient to get an idea about base media attributes.

After some introductory talks, the podcast indeed turns out to be a great performance. Definitely want to keep this for my collection, perhaps optimizing a few things. The first thing to do would be to break the file into individual parts, one for each of the twelve Etudes. Given this is an MP3 audio file, can be done manually with tools like [Audacity](http://audacity.sourceforge.net/help/faq_i18n?s=files&i=split) -- but do we really need to spend more than a minute on this task?

Not with ```bmfp```, which works for variety of audio / video formats and available right from the command line. It provides no less than three commands for automated batch splitting, full description of each readily available via the '-h' switch:

````
$ bmfp fragment -h
$ bmfp segment -h
$ bmfp silencesplit -h
````

For this specific case, automatic split on silence seems to be appropriate. Not an easy target though, as for example there is almost no pause between the introductory speech and start of actual piano playing. Throughout the performance, there are also long artistic pauses within the pieces itself and sharp contrasts in dynamics / sound volume.

With all that, let's just run the ```silencesplit``` command with its default values and see what will come out:

````
$ bmfp silencesplit
1 media file to process
Processing 1 task
Done processing
   ~/Desktop/_podcast/pod150311DaniilTrifonov.mp3
   in 0:00:09.77
Total running time: 0:00:14.85
````

Running with default settings took about 15 seconds to analyze the podcast, find appropriate silence times, and split the file in multiple parts.
Now let' look at the output directory:

````
$ bmfp
~/Desktop/_silence_split
  |- pod150311DaniilTrifonov_00.mp3
      Format: MP3
      Duration: 0:03:56, Bit rate: 128kb/s, Sample rate: 44100Hz

    ... for the sake of brevity, this stands for media files two to ten ...

  |- pod150311DaniilTrifonov_10.mp3
      Format: MP3
      Duration: 0:03:26, Bit rate: 128kb/s, Sample rate: 44100Hz
11 media files, 0 folders
````

Given the challenges described above, not a bad first cut at all. We have eleven files now, and as Chopin Etudes Opus 25 are 12 pieces (plus the introductory speech) it looks like there is still some more splitting to do.

As suspected, the first part stills contains the talk followed by a real short pause. Let's split it out with:

````
$ bmfp -f pod150311DaniilTrifonov_00.mp3 silencesplit -md 0.5
````

The ```-md``` switch here is for minimal silence duration, which tells bmfp to look for at least 0.5 seconds of silence and split there.

That works as expected, and now let's find the other missing file. After quick check, turns out *pod150311DaniilTrifonov_07.mp3* indeed contains two pieces joined together. While the pause between them is about 2 seconds (whic is bmfp silencesplit default), looks like Daniil made these Etudes merge together with final sounds of the first fading into a cheerful start of the second. For the purpose of our exercise, we can now either use one of the other bmfp splitting methods to separate at the exact time or simply to further parametrize the above command to take care of 'lesser silence':

````
$ bmfp -in '*_07.mp3' silencesplit -nt 0.005
````

The ``-nt`` switch stands for noise tolerance, and sets amplitude ratio for detecting silence. As can be seen from `$ bmfp silencesplit -h`, the default noise tolerance value is 0.002 so using 0.005 should raise the silence threshold.

This indeed splits things as expected, and now all 12 Etudes are perfectly isolated and ready for further processing.
Instead of running bmfp in input file mode, in the example above we used the `-in` switch to specify media files in current directory. With additional `-r` switch, bmfp would also process matching files in all nested directories. That can be very powerful indeed, though outside of scope of this tutorial.

So far we used two of the `bmfp` commands, `print` and `silencesplit` to get to first interesting results in less than a minute.

In [Part II]({% post_url 2015-04-11-batchmp-tutorial-part-ii %}): renaming files with renamer we will use renamer to easily shape the media file names, and then move on to [Part III](({% post_url 2015-04-12-batchmp-tutorial-part-iii %})) to add media metadata using tagger.
