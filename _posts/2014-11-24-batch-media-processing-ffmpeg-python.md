---
layout: post
title: "Parallel batch media processing with FFmpeg and Python"
description: "Parallel batch media processing with FFmpeg and Python"
category: articles
tags: [Python, Multiprocessing, Concurrency, FFmpeg, Noise Reduction, Batch Multimedia Processing]
comments: false
---

A short summary:

* A Python script for batch processing of media files

* runs multiple FFmpeg jobs

* takes a source directory, supports subfolders recursion

* multi-pass processing, e.g. 3 times for each media file in a source dir

* uses Python multiprocessing to leverage available CPU cores

* shows continuous progress / percentage of media files processed


It started with a question. If a rainy November weekend is not a good time to finally do some basic organization of old vacation videos, when would it be then?

Half an hour later I realized that while overall things look hopeful, there was a common problem. Quite a few of the videos had really annoying audio noise in the background. Fixing manually with something like Audacity is no big deal, but how should you go about lots of various media files hiding out in numerous nested directories?

Clearly some more powerful tools were needed, such as [FFmpeg](http://ffmpeg.org/), an all-rounder covering variety of media formats or [SoX](http://sox.sourceforge.net/), a tool specifically dedicated to sound processing.

Initially the process looked like:

* Detach audio stream from media into a separate file (FFmpeg)

* Process the audio to remove noise (SoX)

* Back in the original media, replace original audio with the de-noised version (FFmpeg)

* Automate with a simple script

* Relax till all is done, then check results and declare victory


In reality a few things had to be adjusted. First off, while Sox noise processing produced some good results it also often ended up with undesired side effects -- which In multiple cases were not much better than the original noise.

````
sox <1st_sec_of_audio_in> -n noiseprof | sox <audio_in> <audio_out> noisered - 0.2
````

This SoX command generates a DFT profile of the audio that then is fed to SoX 'noisered' filter. Works well for some cases, but unfortunately not as useful for an unattended batch run.

Uhmm. Time to get into base theory of noise? Constant noise and random noise. Broadband Noise, Hum, Rumble, Click and Crackle. Bark scale features and K-NN technique. K=3 and median over 5 consecutive frames.  NOISEX-92 and....

Hey, it's Sunday!!! Back to practical side of things: "first line of defense for Noise Removal is the low-cut and / or high-pass filters". A quick scan over FFmpeg docs, and things started to look bright again. This simple command turned out to do pretty well:

````
ffmpeg -i <input> -af "highpass=f=200, lowpass=f=3000" <output>
````

The highpass / lowpass filters values above are to optimize for audible speech, which is reasonable enough for a bunch of vacation videos. And no need for detached audio stream processing, a single FFmpeg command that just works for variety of media formats. Yep!!

Now ready to automate, the basic requirements are:

* given a source directory, find relevant media files (including subfolders)

* run the FFmpeg command on each

* for some media, several processing passes might be needed

* given large number of files to process, would be good to run on multiple CPU cores

* as the processing might take some non-trivial time, need to show continuous / percentage progress

Surprisingly, apart from trivial bash scripts there did not seem to be lots of existing solutions. And now it all is shaping up as a nice little weekend Python project...

Most of the tasks on list above are straightforward, but how about running FFmpeg from Python? A quick idea is to spin off a subprocess:

{% highlight python linenos %}
cmd = ''.join(('ffmpeg -i "{}"'.format(fpath_input),
                  ' -af "highpass=f={0}, lowpass=f={1}"'.format(highpass, lowpass),
                  ' -loglevel "error" -n',
                  ' "{}"'.format(fpath_output)))
proc = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
output = proc.communicate()[0].decode()
{% endhighlight %}

Now putting something like this in a loop over media files would pretty much solve the problem, right? It actually might, eventually. But it would also block on ```proc.communicate()``` for each individual FFmpeg run, and would hang there till it's done. Might not be a bad thing per se, if we just want to go sequentially and do not care much about visualizing progress. However given large number of media files and all these CPU cores that are so common these days, would be kind of nice to run FFmpeg in multiple processes.

One approach would be implementing custom subprocess management, e.g. spinning off several worker processes based on number of available CPU cores then using ```os.wait()``` to control flow of jobs, etc. Not as hard though not necessarily trivial either.

An alternative method would be to use Python multiprocessing module. Written for concurrent CPU-bound processing, among other things it provides out-of-the-box Pool class that controls a pool of worker processes and feeds them submitted jobs. Some quick shadow of a doubt about the overhead of spinning FFmpeg subprocesses from parallel Python processes, but given that a typical video processing task takes non-trivial amount of time this extra 'infrastructure' burden should not be a big deal after all. And as an immediate reward, the process pool workers management now becomes a breeze:

{% highlight python linenos %}
tasks_params = ((media_file, backup_dir, highpass, lowpass, num_passes)
                                            for media_file, backup_dir in zip(media_files, target_dirs))

with multiprocessing.Pool(cpu_count) as pool:
    for res in pool.imap_unordered(self._af_worker, tasks_params_list):
        print (res.output)
        <show spinner / percentage progress>

{% endhighlight %}


The ```_af_worker``` method is where most of the other things happen. Backing up original media, shaping up an FFmpeg command, running it in multiple passes, etc. All nicely packed to run in multiple managed worker processes and fed to the workers via tasks_params generator.

So far, so good. One little fun-spoiler is still there though. Each iteration of the ```for res in pool.imap_unordered``` loop still blocks, which means that for large media files there might be long moments when things appear to be frozen.

Unfortunately, there seems to be no standard async version of ```Pool.imap_unordered()```. There is ```Pool.map_async()``` method, returning ```AsyncResult``` and taking a callback to be applied when the result becomes available. However while it'd be good enough for showing the spinner, it would not be of much help for showing progress of completed tasks.

As somewhat  foggily described in the docs, ```map_async``` is "variant of the ```map()``` method which returns a result object". The result object is a container class designed to aggregate individual jobs outcome in their relative order. Which means, until all jobs are done the partial results are not  available and thus there is no an easy way to tell how much tasks have been done already. It's possible of course to do some interprocess communications and get the info from worker processes e.g. via pipes, but then -- would the very idea of using multiprocessing module be really worth it? Or perhaps it'd be easier to just get back to custom subprocess management instead...

Before diving into own version of ```imap_unordered_async```, let's remember once more the original requirements and see what is really missing. The major requirement was management of separate processes and making out the most of available CPU cores resources. Now whatever of these remains, need a small part to also occasionally show things are well in progress -- showing a spinner while all workers are busy and updating 'percentage done' whenever a worker 'comes up for air' right after finishing another job. Not that much really, so instead of imap_unordered_async how about simply doing progress visualization in a separate thread?

While horror stories about threads in Python (most of which include notions of GIL) are often true, for this particular case it should be a good fit.

For the sake of brevity, I will skip the implementation details of the progressbar module in this article (might do it in a separate one). With this final piece, things now nicely fit together:

{% highlight python linenos %}
# start showing progress
with progress_bar() as p_bar:

    tasks_params = ((media_file, backup_dir, highpass, lowpass, num_passes)
                                            for media_file, backup_dir in zip(media_files, target_dirs))

    with multiprocessing.Pool(cpu_count) as pool:
        for res in pool.imap_unordered(self._af_worker, tasks_params_list):
            if not quiet:
                p_bar.info_msg = res.output
            tasks_done += 1
            p_bar.progress = tasks_done / num_tasks * 100
{% endhighlight %}


Running dev tests on my iMac, all looks reasonable:
![xxstart]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/ffmpeg-python-xxstart.png)
![xxfinish]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/ffmpeg-python-xxfinish.png)

As expected, the total time is approximately a half of the summed up times spent by individual FFmpeg jobs.

And now the real deal ran an old Mac mini server (Intel Core 2 Duo, 2.66 GHz processor with  2 Cores):
![xxrunning]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/ffmpeg-python-running_0.png)

The two FFmpeg worker processes are run in parallel on their respective CPU cores, while most of the other stuff happily sleeping.

Because of a number of large video files, this take a while and then finally completes with the following result:
![xxdone]({% if site.baseurl %}{{ site.baseurl }}{% endif %}/images/ffmpeg-python-xxDone.png)

Around 6 hours as compared to over 12 hours it would take under sequential processing. Not bad, and time to go enjoy the rest of the weekend... :)
