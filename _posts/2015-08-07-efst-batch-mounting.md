---
layout: post
title: "EFST tips & tricks: Batch mounting"
description: "Batch mounting with EFST"
category: articles
tags: [EFST, Cryptography, Python]
comments: false
---

A commond question about [EFST](https://github.com/akpw/efst) is how to configure automount at login. While easy enough to do via a custom startup script, for the time being this functionality it's not available out-of-the-box.
However, since version 0.26 there is a way to batch-mount all [EFST](https://github.com/akpw/efst) configured folders:

````
$ efsm mount -en +
````

In addition to providing a specific entry name, '--the entry-name'  options also accepts '+' symbol that tells efsm to go for batch mounting.


Similarly, to batch-unmount all currently mounted [EFST](https://github.com/akpw/efst) folders:

````
$ efsm umount -en +
````

To exclude a folder from batch mounting, just use the "--no-batch-mount" option:

````
$ efsm create -en NoBatchMountFolder -bp ~/Dropbox/.secret_nobatchfolder -nb
````

or

````
$ efsm register -en NoBatchMountFolder -bp ~/Dropbox/.secret_nobatchfolder -nb
````

