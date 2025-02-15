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
$ journalctl -u tank-offsite
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

One thing that I'd still like to get working is ZFS's [`nop-write`][nop-write] support.
My use for this is that I have a different daily job that tars up data from my VPS, overwriting a file on disk.
This means that every day I have to sync the full tar file, as from ZFS's perspective it is completely new data, even though there will have been very few changes.
The data in question is only about 1.3 GB --- so it isn't too slow, but if I can avoid having to copy it at all then it would be preferable.
Alternatively, I could just swap to using `rsync` for this job, and avoid re-writing the data at all. ZFS's compression should replicate the benefits I was getting from compressing the tar file.

[nop-write]: https://openzfs.org/wiki/Features#nop-write

## a few days later

Getting [`nop-write`][nop-write] working was indeed really just as simple as swapping the dataset checksum setting to `sha256` (or you can pick one of [the other options](https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Checksums.html#checksum-algorithms))

```bash
$ zfs set checksum=sha256 pool_name/dataset_name
```

Now even though the job rewrites this large tar file daily, there is nothing for `syncoid` to copy over! (well, only 84 KB compared to 1.3 GB)

```bash
$ journalctl -qu tank-offsite --grep 'tank/backup@' | tail -n 2
# without `nop-write`
Dec 28 03:00:43 desktop syncoid[337636]: Sending incremental tank/backup@syncoid_desktop_2024-12-27:23:38:04-GMT00:00 ... syncoid_desktop_2024-12-28:03:00:43-GMT00:00 (~ 1.3 GB):
# with `nop-write`
Dec 28 13:28:38 desktop syncoid[26300]: Sending incremental tank/backup@syncoid_desktop_2024-12-28:13:12:15-GMT00:00 ... syncoid_desktop_2024-12-28:13:28:38-GMT00:00 (~ 84 KB):
```

I am now questioning why I didn't use `rsync` in the first place, however.
`nop-write` saves me from replicating the unchanged overwritten file, by preventing the writes from actually hitting the disk.
It doesn't avoid the whole daily download from the VPS though!
ZFS couldn't possibly know what writes would be no-ops without having the new data to checksum against what is already on disk.

The only slight gotcha with `nop-write` is that you need to make sure that you don't truncate the file you rewrite.
For example something like this won't work:

```bash
$ ssh $VPS_HOSTNAME 'tar -cf - /var/www/' > var-www.tar
```

If you do this, then the shell first truncates the file before writing the new data.
There is probably a clever bash way of avoiding the truncation, but using `dd` with the `conv=notrunc` option is a bit more self documenting:

```bash
$ ssh $VPS_HOSTNAME 'tar -cf - /var/www/' | dd of=var-www.tar conv=notrunc bs=1M
```

Although `nop-write` sounds very compelling at first -- it is actually fairly niche. Most of the time it is possible (and more efficient) to avoid rewriting unchanged data! 

## a few weeks later

At some point I decided to enable some power management settings on my desktop.
Usually, my desktop is suspended. However, sometimes one of my meddling cats will step on the keyboard, waking it up, so it is handy if the machine automatically suspends after being idle for some amount of time.
Auto-suspend however created a bit of headache for this backup job:

```bash
Jan 10 03:00:44 desktop systemd[1]: Starting tank-offsite.service - Backup tank to tank-offsite...
Jan 10 03:00:55 desktop sh[296224]: PING 192.168.1.10 (192.168.1.10) 56(84) bytes of data.
Jan 10 03:00:55 desktop sh[296224]: 64 bytes from 192.168.1.10: icmp_seq=1 ttl=62 time=12.8 ms
Jan 10 03:00:55 desktop sh[296224]: --- 192.168.1.10 ping statistics ---
Jan 10 03:00:55 desktop sh[296224]: 1 packets transmitted, 1 received, 0% packet loss, time 0ms
Jan 10 03:00:55 desktop sh[296224]: rtt min/avg/max/mdev = 12.842/12.842/12.842/0.000 ms
Jan 10 03:00:56 desktop syncoid[296226]: Sending incremental tank/backup@syncoid_desktop_2025-01-09:03:00:51-GMT00:00 ... syncoid_desktop_2025-01-10:03:00:56-GMT00:00 (~ 3.2 MB):
Jan 10 03:01:11 desktop syncoid[296226]: Sending incremental tank/backup/email@syncoid_desktop_2025-01-09:03:01:11-GMT00:00 ... syncoid_desktop_2025-01-10:03:01:11-GMT00:00 (~ 1.5 MB):
Jan 10 03:01:13 desktop syncoid[296226]: Sending incremental tank/backup/lxc@syncoid_desktop_2025-01-09:03:01:13-GMT00:00 ... syncoid_desktop_2025-01-10:03:01:13-GMT00:00 (~ 4 KB):
Jan 10 03:01:14 desktop syncoid[296226]: Sending incremental tank/backup/pbs@syncoid_desktop_2025-01-09:03:01:13-GMT00:00 ... syncoid_desktop_2025-01-10:03:01:14-GMT00:00 (~ 1.0 GB):
Jan 10 08:52:35 desktop syncoid[296484]: cannot receive incremental stream: dataset is busy
Jan 10 19:29:53 desktop syncoid[296488]: lzop: Broken pipe: <stdout>
Jan 10 19:29:53 desktop syncoid[296226]: CRITICAL ERROR: ssh      -S /tmp/syncoid-root@192.168.1.10-1736478055-2255 root@192.168.1.10 ' zfs send  -I '"'"'tank/backup/pbs'"'"'@'"'"'syncoid_desktop_2025-01-09:03:01:13-G'"'"' '>
Jan 10 19:29:55 desktop syncoid[296226]: Sending incremental tank/backup/veeam@syncoid_desktop_2025-01-09:03:15:13-GMT00:00 ... syncoid_desktop_2025-01-10:19:29:55-GMT00:00 (~ 4 KB):
Jan 10 19:29:59 desktop syncoid[296226]: Sending incremental tank/data@syncoid_desktop_2025-01-09:05:52:20-GMT00:00 ... syncoid_desktop_2025-01-10:19:29:58-GMT00:00 (~ 35.8 MB):
Jan 10 19:30:39 desktop systemd[1]: tank-offsite.service: Main process exited, code=exited, status=2/INVALIDARGUMENT
Jan 10 19:30:39 desktop systemd[1]: tank-offsite.service: Failed with result 'exit-code'.
Jan 10 19:30:39 desktop systemd[1]: Failed to start tank-offsite.service - Backup tank to tank-offsite.
Jan 10 19:30:39 desktop systemd[1]: tank-offsite.service: Consumed 31.336s CPU time, 43.7M memory peak.
```

It wasn't immediately clear what was going wrong to me, as I'd completely forgotten that auto-suspend was enabled.
What made it more obvious was this other journal entry:

```bash
Jan 10 03:15:40 desktop systemd-logind[1367]: The system will suspend now!
Jan 10 03:15:40 desktop ModemManager[1645]: <msg> [sleep-monitor-systemd] system is about to suspend
Jan 10 03:15:40 desktop NetworkManager[2071]: <info>  [1736478940.0158] manager: sleep: sleep requested (sleeping: no  enabled: yes)
Jan 10 03:15:40 desktop NetworkManager[2071]: <info>  [1736478940.0163] manager: NetworkManager state is now ASLEEP
Jan 10 03:15:40 desktop systemd[1]: Reached target sleep.target - Sleep.
Jan 10 03:15:40 desktop systemd[1]: Starting nvidia-suspend.service - NVIDIA system suspend actions...
```

Conveniently, it is quite easy to add "inhibitions" that prevent the system from sleeping.
I added a `systemd-inhibit` call on the `ExecStart=` line of the unit:

```bash
ExecStart=/usr/bin/systemd-inhibit /usr/local/sbin/syncoid [-snip-]
```

This wasn't quite enough, however. There is [a race condition](https://github.com/systemd/systemd/issues/14045) if you call `systemd-inhibit` while the machine is still waking from sleep:

```bash
Jan 12 03:00:51 desktop systemd-inhibit[398074]: Failed to inhibit: The operation inhibition has been requested for is already running
Jan 12 03:00:51 desktop systemd[1]: tank-offsite.service: Main process exited, code=exited, status=1/FAILUR
```

I've hacked around this by adding a 30s sleep in another `ExecStartPre=` line.
I'm somewhat surprised there isn't a built-in option to inhibit sleep while a unit is running, but I suppose this is a niche thing to do.
