---
title: "ZFS snapshots and how to sync them"
date: 2024-12-07T20:50:25Z
draft: false
description: "I finally have a somewhat usable offsite backup!"
keywords: ["ZFS"]
tags: ["projects"]
math: false
toc: false
comments: true
---

I am quite a big fan of ZFS. One of its useful features is snapshotting, allowing you to record the state of your filesystem at a specific point in time. This means if you later change or delete files, you will be able to roll-back to this previous snapshot, or restore individual files. So far, so normal --- even NTFS has a kind of snapshot/restore capability.

What makes ZFS's snapshots even more useful is what they enable in terms of filesystem synchronization. My use case is that I have 10 TB of data at a remote site that I want to back up to my local desktop. I am constrained by a slow internet connection, so I need a solution that doesn't use much bandwidth.

What I can do is to have a matching snapshot pair on both sides, then take another snapshot on the sending end. ZFS can then find which blocks have changed on the sending side, and send and replay the differences to the receiving side. Unfortunately you still have to do a single initial replication on the whole dataset --- you can't get around that!

In my case the initial replication was going to take more than a week over the slow link; I ended up [sneakernetting](https://en.wikipedia.org/wiki/Sneakernet) the data between sites to speed up the process. While you can achieve incremental results with a tool like `rsync`, the process isn't as efficient, as it has to check to see if each file has been updated.

[`syncoid`](https://github.com/jimsalterjrs/sanoid#syncoid) is the tool I use to automate the `zfs snapshot`, `zfs send | receive` process.
I run a command like this to pull all the changes since the previous run:

```bash
root@desktop:~# syncoid --recursive --skip-parent root@192.168.1.10:tank tank-offsite
```

Here `tank` is a pool on the remote machine at `192.168.1.10`, and `tank-offsite` is mounted on the local desktop.
I don't use the desktop machine that runs this backup consistently, it suspended most of the time, so I needed a way to schedule this job regularly.

`systemd` to the rescue! I created a service to run the `syncoid` command, and a timer to run the service on a schedule.
The magic here is the [`WakeSystem=`](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html#WakeSystem=) timer option --- which resumes my desktop from suspend when the timer triggers.
Here is my config --- it is pleasantly simple:

```bash
root@desktop:~# systemctl cat tank-offsite.{service,timer}
# /etc/systemd/system/tank-offsite.service
[Unit]
Description=Backup tank to tank-offsite
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot

# wait for the network to be usable
ExecStartPre=sh -c 'until ping -c 1 192.168.1.10; do sleep 1; done'
# do the sync
ExecStart=/usr/local/sbin/syncoid --recursive --skip-parent root@192.168.1.10:tank tank-offsite
# suspend the machine again
ExecStopPost=/usr/bin/systemctl suspend

# /etc/systemd/system/tank-offsite.timer
[Unit]
Description=Backup tank to tank-offsite on a schedule

[Timer]
OnCalendar=Mon-Sun 03:00
WakeSystem=true

[Install]
WantedBy=timers.target
```

The only little hack here is the `ExecStartPre=` line; my first pass at this didn't include it. I was hoping that `After=network-online.target` would be enough to make sure the network stack was up before the `syncoid` command would run. Evidently not:

```bash
Dec 22 03:00:28 desktop systemd[1]: Starting tank-offsite.service - Backup tank to tank-offsite...
Dec 22 03:00:29 desktop syncoid[162504]: ssh: connect to host 192.168.1.10 port 22: Network is unreachable
Dec 22 03:00:29 desktop syncoid[162505]: ssh: connect to host 192.168.1.10 port 22: Network is unreachable
Dec 22 03:00:29 desktop syncoid[162423]: CRITICAL ERROR: ssh connection echo test failed for root@192.168.1.10 with exit code 255 at /usr/local/sbin/syncoid line 1714.
Dec 22 03:00:29 desktop systemd[1]: tank-offsite.service: Control process exited, code=exited, status=1/FAILURE
Dec 22 03:00:29 desktop systemd[1]: tank-offsite.service: Failed with result 'exit-code'.
Dec 22 03:00:29 desktop systemd[1]: Failed to start tank-offsite.service - Backup tank to tank-offsite.
```

`systemd`'s docs have [some discussion of this scenario](https://systemd.io/NETWORK_ONLINE/#modyfing-the-meaning-of-network-onlinetarget). They suggest adding a separate service that runs the same ping check with `Before=network-online.target` specified. This means that any services depending on `network-online.target` will only start once the ping has been successful. As I only have a single service that cares about this, keeping it all together in the same unit with `ExecStartPre=` made sense to me.

You may have noticed a slight issue with this timer setup: my machine will always suspend after the backup job finishes. This is the desired outcome when the timer has caused the desktop to wake up, but it will probably be quite annoying if I were using the machine at the time. Luckily I'm usually fast asleep before 03:00! I couldn't find a neat way of avoiding this.

One thing that I'd still like to get working is ZFS's [`nop-write`](https://openzfs.org/wiki/Features#nop-write) support.
My use for this is that I have a different daily job that tars up data from my VPS, overwriting a file on disk.
This means that every day I have to sync the full tar file, as from ZFS's perspective it is completely new data, even though there will have been very few changes.
The data in question is only about 1.5 GB --- so it isn't too slow, but if I can avoid having to copy it at all then it would be preferable.
Alternatively, I could just swap to using `rsync` for this job, and avoid re-writing the data at all. ZFS's compression should replicate the benefits I was getting from compressing the tar file.
