---
title: "ZFS snapshots"
date: 2024-12-07T20:50:25Z
draft: true
description: ""
keywords: ["ZFS"]
tags: ["projects"]
math: false
toc: false
comments: true
---

I am quite a big fan of ZFS. One of its useful features is snapshotting, allowing you to record the state of your filesystem at a point in time. This means if you later change or delete files, you will be able to roll-back to this previous snapshot, or restore individual files. So far, so normal -- even NTFS has a kind of snapshot/restore capability.

What makes ZFS's snapshots even more useful is what they enable in terms of filesystem synchronization. My use case is that I have 10 TB of data that I want to back up to a remote site. Awkwardly I am constrained by a pretty slow internet connection, so I need a solution that doesn't use much bandwidth.

What I can do is to have a matching snapshot pair on both sides, then take another snapshot on the sending end. ZFS can then find which blocks have changed on the sending side, and send only the differences to the receive side. Unfortunately you still have to do a single initial replication on the whole dataset -- you can't get around that!

In my case the initial replication was going to take more than a week over the slow link; I ended up [sneakernetting](https://en.wikipedia.org/wiki/Sneakernet) the data between sites to speed the process up. 

While you can achieve incremental results with a tool like `rsync`, the process is far less efficient, as it has to check to see if each file has been updated.
 
