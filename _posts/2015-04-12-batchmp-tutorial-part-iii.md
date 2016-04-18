---
layout: post
title: "BatchMP Tools Tutorial, Part III"
description: "BatchMP Tools Tutorial, Part III"
category: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
comments: false
---

Content:

+ [Part I]({% post_url 2015-04-10-batchmp-tutorial-part-i %}): splitting a long media file into multiple pieces with bmfp
+ [Part II]({% post_url 2015-04-11-batchmp-tutorial-part-ii %}): renaming files with renamer
+ [Part III]({% post_url 2015-04-12-batchmp-tutorial-part-iii %}): setting tags and artwork with tagger

In [Part I]({% post_url 2015-04-10-batchmp-tutorial-part-i %}) and [Part II]({% post_url 2015-04-11-batchmp-tutorial-part-ii %}), we downloaded a cool WGBH podcast then used `bmfp` to split it into 12 parts and renamed the files with `renamer`. With about two minutes of command-line typing / processing spent so far, let's spend another minute to finish this tutorial series via setting up tags and artwork.

`Tagger` manages media metadata, working uniformly for [supported audio / video formats](https://github.com/akpw/batch-mp-tools#supported-formats). As all [BatchMP tools](https://github.com/akpw/batch-mp-tools), it can handle both an individual file and or all specified media files in nested directories.

Running `tagger` in a console without any parameters defaults to `tagger print` command. To show some of the available options, lets use the explicit print command instead:

````
$ tagger print -ff -st
~/Desktop/_podcast
  |- 01 F. Chopin Etude Op.25 No.1.mp3
      Format: MP3
      Duration: 0:02:21, Bit rate: 128kb/s, Sample rate: 44100Hz, Bit depth: n/a

    ... for the sake of brevity, this stands for media files two to eleven ...

  |- 12 F. Chopin Etude Op.25 No.12.mp3
      Format: MP3
      Duration: 0:03:26, Bit rate: 128kb/s, Sample rate: 44100Hz, Bit depth: n/a
12 media files, 0 folders
The '-ff' switch tells tagger to use full output format while '-st' prints media files statistics.
````

Now let's set some basic tags:

````
$ tagger set \
   --title '$filename' --artist 'Daniil Trifonov' \
   --album 'WGBH podcast: Chopin Etudes Op. 25 with Daniil Trifonov' \
   --genre 'Classical' --composer 'Frederic Chopin'
Targeted after processing:
~/Desktop/_podcast
  |- 01 F. Chopin Etude Op.25 No.1.mp3
      Title: 01 F. Chopin Etude Op.25 No.1
      Album: WGBH podcast: Chopin Etudes Op. 25 with Daniil Trifonov
      Artist: Daniil Trifonov
      Genre: Classical
      Composer: Frederic Chopin

    ... for the sake of brevity, this stands for media files two to eleven ...

  |- 12 F. Chopin Etude Op.25 No.12.mp3
      Title: 12 F. Chopin Etude Op.25 No.12
      Album: WGBH podcast: Chopin Etudes Op. 25 with Daniil Trifonov
      Artist: Daniil Trifonov
      Genre: Classical
      Composer: Frederic Chopin
12 media files, 0 folders

Proceed? [y/n]:
````

Along with setting simple textual values, `$filename` is telling tagger to set the title tag to corresponding file name. That is a just brief demonstration of tagger template processing. Any tag field name can be used in a similar fashion, in combination with text or other tag field names.

Now let's set the album artist and atrwork. For album artist we can just use template processing again, leveraging the existing value of the artist tag. For artwork, we can either use an image available on disk or an URL to a Web image:

````
$ tagger set \
  --albumartist '$artist' \
  --artwork 'http://www.trifonov.us/wp-content/gallery/main/trifonov_011.jpg' \
  --diff-only
Targeted after processing:
~/Desktop/_podcast
  |- 01 F. Chopin Etude Op.25 No.1.mp3
      Album Artist: Daniil Trifonov
      Artwork present

    ... for the sake of brevity, this stands for media files two to eleven ...

  |- 12 F. Chopin Etude Op.25 No.12.mp3
      Album Artist: Daniil Trifonov
      Artwork present
12 media files, 0 folders

Proceed? [y/n]:
````

The optional `--diff-only` switch is to tell tagger to use only changed fields in the confirmation prompt.
Now let's automatically add the tracks / track totals information:

````
$ tagger index --diff-only
Targeted after processing:
~/Desktop/_podcast
  |- 01 F. Chopin Etude Op.25 No.1.mp3
      Track: 1/12

    ... for the sake of brevity, this stands for media files two to eleven ...

  |- 12 F. Chopin Etude Op.25 No.12.mp3
      Track: 12/12
12 media files, 0 folders

Proceed? [y/n]:
````

Let's confirm and we are pretty much done here.
To see the current state:

````
$ tagger
~/Desktop/_podcast
  |- 01 F. Chopin Etude Op.25 No.1.mp3
      Title: 01 F. Chopin Etude Op.25 No.1
      Album: WGBH podcast: Chopin Etudes Op. 25 with Daniil Trifonov
      Artist: Daniil Trifonov
      Album Artist: Daniil Trifonov
      Genre: Classical
      Composer: Frederic Chopin

    ... for the sake of brevity, this stands for media files two to eleven ...

  |- 12 F. Chopin Etude Op.25 No.12.mp3
      Title: 12 F. Chopin Etude Op.25 No.12
      Album: WGBH podcast: Chopin Etudes Op. 25 with Daniil Trifonov
      Artist: Daniil Trifonov
      Album Artist: Daniil Trifonov
      Genre: Classical
      Composer: Frederic Chopin
12 media files, 0 folders
````

Looks good to me.  Perhaps just one little detail, the title tag starts with a number that does not really add too much information and looks somewhat extraneous. Let's cut it out with:

````
$ tagger replace -tf 'title'  -fs '^.{3}' -rs ''
````

Tagger replace works almost exactly like similar `renamer replace` command, with the additional `--tag-fields` parameter specifying the tag fields in which to perform the replace.

Now all looks cool, which also closes this tutorial series.
