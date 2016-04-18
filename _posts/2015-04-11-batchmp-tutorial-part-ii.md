---
layout: post
title: "BatchMP Tools Tutorial, Part II"
description: "BatchMP Tools Tutorial, Part II"
category: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
comments: false
---

Content:

+ [Part I]({% post_url 2015-04-10-batchmp-tutorial-part-i %}): splitting a long media file into multiple pieces with bmfp
+ [Part II]({% post_url 2015-04-11-batchmp-tutorial-part-ii %}): renaming files with renamer
+ [Part III]({% post_url 2015-04-12-batchmp-tutorial-part-iii %}): setting tags and artwork with tagger

In [Part I]({% post_url 2015-04-10-batchmp-tutorial-part-i %}), we downloaded a [cool WGBH podcast](http://www.wgbh.org/programs/Classical-Performance-Podcast-391/episodes/Chopin-with-Daniil-Trifonov-60828) and used [bmfp](https://github.com/akpw/batch-mp-tools/blob/master/README.md#bmfp-requires-ffmpeg) to split it into 12 parts nicely corresponding to each of the played pieces. With about a minute spent there (including typing in the command prompt), hopefully there is still a minute or two for further fine-tune processing.

Let's start from where we ended, and proceed with shaping up the media files names using [renamer](https://github.com/akpw/batch-mp-tools#renamer), which as the name suggests is a multi-platform batch rename tool.

As in other BMFP tools, running in a console without any parameters defaults to `renamer print` command:

````
$ renamer
~/Desktop/_podcast
  |- pod150311DaniilTrifonov_00_1.mp3
  |- pod150311DaniilTrifonov_01.mp3
  |- pod150311DaniilTrifonov_02.mp3
  |- pod150311DaniilTrifonov_03.mp3
  |- pod150311DaniilTrifonov_04.mp3
  |- pod150311DaniilTrifonov_05.mp3
  |- pod150311DaniilTrifonov_06.mp3
  |- pod150311DaniilTrifonov_07_1.mp3
  |- pod150311DaniilTrifonov_07_2.mp3
  |- pod150311DaniilTrifonov_08.mp3
  |- pod150311DaniilTrifonov_09.mp3
  |- pod150311DaniilTrifonov_10.mp3
12 files, 0 folders
````

In its simples form renamer can be used to print files / directories. With switches such as `-r`, `-el`, etc.  it should be able to handle most complex nested hierarchies. As usual, to learn more just run:

````
$ renamer -h
$ renamer print -h
````
and then feel free to experiment on your directory structure.

For the purpose of our task at hand, let's first do some file names indexing. `renamer index` command can do both sequential and multi-level indexing across all specified files in nested directories. For now, let's just run it in its simplest form:

````
$ renamer index
Targeted after processing:
~/Desktop/_podcast
  |- 01 pod150311DaniilTrifonov_00_1.mp3
  |- 02 pod150311DaniilTrifonov_01.mp3
  |- 03 pod150311DaniilTrifonov_02.mp3
  |- 04 pod150311DaniilTrifonov_03.mp3
  |- 05 pod150311DaniilTrifonov_04.mp3
  |- 06 pod150311DaniilTrifonov_05.mp3
  |- 07 pod150311DaniilTrifonov_06.mp3
  |- 08 pod150311DaniilTrifonov_07_1.mp3
  |- 09 pod150311DaniilTrifonov_07_2.mp3
  |- 10 pod150311DaniilTrifonov_08.mp3
  |- 11 pod150311DaniilTrifonov_09.mp3
  |- 12 pod150311DaniilTrifonov_10.mp3
12 files, 0 folders

Proceed? [y/n]
````

By default, indexes are added at the beginning of file names using a space as the join string. An important detail here, by default `renamer` is visualizing the targeted changes and asking for permission to proceed before actually doing anything.
Let's confirm and run the indexing command again, this time adding indexes to the end of file names:

````
$ renamer index -as
Targeted after processing:
~/Desktop/_podcast
  |- 01 pod150311DaniilTrifonov_00_1 01.mp3
  |- 02 pod150311DaniilTrifonov_01 02.mp3
  |- 03 pod150311DaniilTrifonov_02 03.mp3
  |- 04 pod150311DaniilTrifonov_03 04.mp3
  |- 05 pod150311DaniilTrifonov_04 05.mp3
  |- 06 pod150311DaniilTrifonov_05 06.mp3
  |- 07 pod150311DaniilTrifonov_06 07.mp3
  |- 08 pod150311DaniilTrifonov_07_1 08.mp3
  |- 09 pod150311DaniilTrifonov_07_2 09.mp3
  |- 10 pod150311DaniilTrifonov_08 10.mp3
  |- 11 pod150311DaniilTrifonov_09 11.mp3
  |- 12 pod150311DaniilTrifonov_10 12.mp3
12 files, 0 folders

Proceed? [y/n]:
````
The `-as` switch tells renamer to add indexes as names suffixes.

Now we are all ready for the final transformation using renamer replace command. Basically, we just want to find the string that is in between our newly added indexes and replace it with something like "F. Chopin Etude Op.25 No.".  Regular expressions make this a breeze, for anyone (like myself) who occasionally needs to refresh its memories the sites like regexr.com provide a great reference.

Here I'm using a simple lookbehind to specify that our find-string parameter is something that goes after two digits and a space: `(?<=\d\d\s)`, and that it can be whatever:  `.*` that ends with a digit, a space, and optional `0: \d\s0?` (the optional 0 comes from the index at the end).

````
$ renamer replace -fs '(?<=\d\d\s).*\d\s0?' -rs 'F. Chopin Etude Op.25 No.'
Targeted after processing:
~/Desktop/_podcast
  |- 01 F. Chopin Etude Op.25 No.1.mp3
  |- 02 F. Chopin Etude Op.25 No.2.mp3
  |- 03 F. Chopin Etude Op.25 No.3.mp3
  |- 04 F. Chopin Etude Op.25 No.4.mp3
  |- 05 F. Chopin Etude Op.25 No.5.mp3
  |- 06 F. Chopin Etude Op.25 No.6.mp3
  |- 07 F. Chopin Etude Op.25 No.7.mp3
  |- 08 F. Chopin Etude Op.25 No.8.mp3
  |- 09 F. Chopin Etude Op.25 No.9.mp3
  |- 10 F. Chopin Etude Op.25 No.10.mp3
  |- 11 F. Chopin Etude Op.25 No.11.mp3
  |- 12 F. Chopin Etude Op.25 No.12.mp3
12 files, 0 folders

Proceed? [y/n]:
````
Let's confirm, and now we are all done here and in a good shape to move on.

In [Part III]({% post_url 2015-04-12-batchmp-tutorial-part-iii %}) where we will finish in style by adding tags / artwork metadata using the tagger tool.
