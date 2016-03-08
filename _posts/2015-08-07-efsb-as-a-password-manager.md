---
layout: post
title: "EFSB: who needs password managers?"
description: "using EFSB as a password managers"
category: articles
tags: [efst, cryptography, python]
comments: true
---

[EFSB](https://github.com/akpw/efst#efsb) is an [EFST](https://github.com/akpw/efst) configuration tool for managing EncFS backend stores folders. It can show registered EncFS File Systems info, retrieve plaintext EncFS key values, encode / decode file names, list EncFS un-decodable files, etc.

A little bit beyond its typical intended usage, efsb can also serve as a light-weight command line password manager. As "efsb encode" command can generate an encoded version of plaintext filenames, why not use it generate an encoded version of any arbitrary string?
 To begin, let's create a dedicated EFST entry:

````
$ efsm create -en PwdMaker -bp ~/Dropbox/.pwdb
Enter password: *****
Confirm password: *****
Creating EncFS backend store...
Do you want to securely store the password for later use? [y/n]: y
CipherText Entry registered: PwdMaker
Generating passwords is now as easy as:
$ efsb encode -en PwdMaker -fn 'my cool password'
Encoded: 5IxzEjT7HKhOBiWd691SvkEq
````

````
$ efsb encode -en PwdM -fn 'facebook'
Encoded: V5B31H5T2azuw,
$ efsb encode -en Pwd -fn 'gmail'
Encoded: mwohTmThE,
To improve things further, lets make sure it is not possible to make educated guesses based on the length of generated passwords. To do that, we need to first create an EFST Configuration Entry with the "Block" or "Block32" filename encoding.
````

````
$ efsc register -ce PwdMakerCfg -na Block32
PwdMakerCfg entry registered
````

Now let's create another PwdMaker entry, using the Block32 Configuration from above:

````
$ efsm create -en PwdMaker2 -bp ~/Dropbox/.pwdb2 -ce PwdMakerCfg
Enter password: ****
Confirm password: ****
Creating EncFS backend store...
Do you want to securely store the password for later use? [y/n]: y
CipherText Entry registered: PwdMaker2
````

With that, we are right at the password handling nirvana:

````
$ efsb encode -en PwdMaker2 -fn "facebook"
Encoded: AYV42LJUANZ2TFHML4VRW2IKN7IVI

$ efsb encode -en PwdMaker2 -fn "gmail"
Encoded: EQGKIUNB5UDSOSJA7W2S5YFL43NJM

$ efsb encode -en PwdMaker2 -fn "twitter"
Encoded: RSPLTE3CHDY5HVJBWECB64OOPBFAL
````


From now on, we do not even need to store our passwords! Instead, a password can be simply regenerated right from the command line.
