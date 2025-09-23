---
layout: post
title: "BatchMP Renamer: Organize & Virtual Views"
date: 2025-09-22
categories: articles
tags: [BatchMP Tools, Python, Batch Multimedia Processing]
---

Ever stared at a downloads folder full of mixed media files thinking "I should organize this... later"? Now later has arrived, and BatchMP Renamer makes it a lot easier.

The latest updates add two new capabilities: **organize** for automatically grouping files into directories, and enhanced **print** functionality with virtual views over the original file structure.

## Organize by File Type

Imagine a typical download folder mess: photos, videos, music files, and other stuff all mixed together. The new `organize` command can sort them by media type with a single command:

```bash
$ renamer organize -b type
```

The `-b type` option tells renamer to organize files based on their media type. BatchMP Tools automatically detects whether files are images, videos, audio, or other formats and creates appropriate subdirectories:

```bash
~/Downloads
  |- image/
    |- vacation_photo.jpg
    |- screenshot.png
  |- video/
    |- family_movie.mp4
    |- presentation.mov
  |- audio/
    |- favorite_song.mp3
    |- podcast_episode.m4a
6 files, 3 folders
Proceed? [y/n]
```

Before actually moving anything, renamer shows exactly what changes it plans to make and asks for confirmation. No surprises, no accidents.

## Organize by Date

But sometimes organizing by file type isn't really what's needed. How about sorting chronologically? The date-based organization has it covered:

```bash
$ renamer organize -b date
```

This creates directories based on modification dates using the default `YYYY-MM-DD` format:

```bash
~/Downloads
  |- 2025-01-15/
    |- document.pdf
    |- notes.txt
  |- 2025-01-20/
    |- photo.jpg
    |- video.mp4
```

But isn't a hierarchical structure better for most things? The `--date-format` option gives complete control there:

```bash
$ renamer organize -b date --date-format "%Y/%m"
```

This creates nested year/month directories:

```bash
~/Downloads
  |- 2025/
    |- 01/
      |- document.pdf
      |- photo.jpg
    |- 12/
      |- last_year_file.txt
```

Any common Python `strftime` format would do: `%Y-%m` for "2025-01", `%B_%Y` for "January_2025", etc.


## The virtual views

But what if you need to see files in a new organization without actually changing anything? The enhanced `print` command now supports the same type of previews:

```bash
$ renamer print -b type
```

This shows a virtual view of how the files would look organized by type, without intent to move anything:

```bash
Virtual view by type:
~/Downloads
  |- image/
    |- vacation_photo.jpg
    |- screenshot.png
  |- video/
    |- family_movie.mp4
  |- audio/
    |- favorite_song.mp3
```

Same goes for date-based previews:

```bash
$ renamer print -b date --date-format "%Y/%m"
```

This can be especially useful when experimenting with different organization strategies or date formats.


## Sized Virtual View

Sometimes it's useful to see not just how files would be organized, but also their sizes at a glance. The `print` command supports a size summary option with the `-ss` flag that adds file size information to the virtual view:

```bash
$ renamer print -b date -df "%y/%m" -ss
```
```bash
Virtual view by date:
~/Downloads
  |->/25
    |->/ 654MB 01
      |-  12MB vacation_photo.jpg
      |-  2MB screenshot.png
      |-  640MB presentation.mov
    |->/ 50MB 12
      |-  4MB favorite_song.mp3
      |-  46MB podcast_episode.m4a
5 files, 2 folders
```

The size information works with any organization method (`-b type`, `-b date`) and date format combinations.

## Sorted Virtual Views

The virtual views become even more powerful when combined with sorting options. Using the `-s` parameter, it's easy to control how directories and files are ordered within the organized view:

### Sort by Size

When disk space becomes a concern, size-based sorting is invaluable:

```bash
$ renamer -s sd print -b type -ss
```

This shows directories sorted by size in descending order (largest first):

```bash
Virtual view by type:
~/Downloads
  |->/ 2.1GB video
    |-  531MB movie_part1.mp4
    |-  442MB movie_part2.mp4
    |-  357MB presentation.mp4
  |->/ 1.2GB nonmedia
    |-  200MB installer.dmg
    |-  150MB documentation.pdf
    |-  32MB spreadsheet.xlsx
  |->/ 8.0MB image
    |-  4MB high_res_photo.jpg
    |-  2MB screenshot.png
    |-  1MB thumbnail.jpg
```

The size sorting helps identify which file types are taking up the most space, making it easier to decide what to organize first or what might need cleanup.

For ascending order (smallest first), use `-s sa`:

```bash
$ renamer -s sa print -b type -ss
```

### Sort by Name

Alphabetical sorting can be useful for systematic organization:

```bash
# Name ascending (A-Z)
$ renamer -s na print -b type

# Name descending (Z-A) 
$ renamer -s nd print -b type
```

This works with both type-based and date-based approaches:

```bash
$ renamer -s sd print -b date --date-format "%Y-%m" -ss
```

Shows date-based directories sorted by total size, helping identify which months have the largest collections of files.


## Going the Other Direction: Flatten

Sometimes things need to go in the opposite direction - taking a nested directory structure and flattening it into a single level. Maybe the files got organized too deeply, or need a simple, flat arrangement from a complex hierarchy. The `flatten` command handles this:

```bash
$ renamer flatten -tl 0
```

The `-tl 0` (target level 0) tells renamer to flatten everything to the root directory level. This moves all files from subdirectories up to the main directory:

```bash
# Before:
~/Downloads
  |- images/
    |- photo1.jpg
    |- photo2.png
  |- videos/
    |- movie.mp4
  |- docs/
    |- report.pdf

# After flatten -tl 0:
~/Downloads
  |- photo1.jpg
  |- photo2.png
  |- movie.mp4
  |- report.pdf
```

This creates an interesting workflow: organize files with `organize`, review the structure, and if a flatter arrangement is preferred, simply use `flatten -tl 0` to bring everything back to a single level.

The flatten command handles duplicate filenames intelligently and, like all BatchMP Tools commands, shows exactly what it plans to do before making any changes.

## Real-World Scenarios

Here's the described functionality in several common scenarios:

**Digital Photography Workflow**: After importing photos from multiple shoots, organize by date to create chronological archives:
```bash
$ renamer -r organize -b date --date-format "%Y/%m-%B"
```

**Downloads Cleanup**: Sort mixed downloads by type to quickly find what's needed:
```bash
$ renamer organize -b type
```

**Project Preparation**: Preview different organization strategies before committing:
```bash
$ renamer -s sd print -b date --date-format "%Y-%m" -ss
$ renamer -s sd print -b type -ss
$ renamer organize -b type  # When the choice is made
```

**Archive Preparation**: Organize files by date with hierarchical structure for long-term storage:
```bash
$ renamer organize -b date --date-format "%Y/%m/%d" --target-dir ~/Archives
```

**Disk Space Analysis**: Identify which file types or time periods are consuming the most space:
```bash
$ renamer -s sd print -b type -ss    # Show largest file type categories first
$ renamer -s sd print -b date --date-format "%Y-%m" -ss  # Show largest months first
```

**Reorganization Workflow**: Try different organization approaches by combining organize and flatten:
```bash
$ renamer organize -b type          # Sort by type first
$ renamer -s sd print -b date -ss    # Preview date-based organization with size info
$ renamer flatten -tl 0             # Flatten back to single level
$ renamer organize -b date          # Now organize by date instead
```

