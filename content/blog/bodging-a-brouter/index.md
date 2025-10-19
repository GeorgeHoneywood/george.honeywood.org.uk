---
title: "Bodging a brouter"
date: 2025-10-17T19:20:35+01:00
draft: false
description: "Site-to-site VPN, the hard way"
keywords: ["wireguard", "tailscale", "VPN", "bridge"]
tags: ["projects"]
math: false
toc: false
comments: true
---

I wanted to do something a bit weird the other day.\
I've got two networks. `192.168.0.1/24` and `192.168.1.1/24`, which are at different sites --- `.1.` is at my parent's house, `.0.` is at my flat.\
A Jellyfin media server lives on the `.1.` network, and I want to be able to reach that from my the `.0.` network, where I have a Roku with the Jellyfin app installed.

The really easy option here is to add a port forward on the `.1.` side router, such that you can reach the Jellyfin server from the public internet --- this is exactly what I used to do for Plex. However, exposing things to the internet isn't usually a great idea from a security perspective, especially when you aren't great at keeping things up to date!

I've got Tailscale (which is a fancy Wireguard VPN solution) set up on the `.1.` side, so I can reach that network from specific devices that have the Tailscale app installed, but unfortunately there isn't an app for the Roku.
What makes things a bit more complicated is that the router for the `.0.` network is a rubbish ISP provided one. I can't easily avoid using it as the flat has 4G/LTE internet, don't ask!
As such I can't configure any extra routes or install the Tailscale VPN on the router itself.

My first pass at this was very lazy. On my desktop on the `.0.` side I've got Tailscale running, so it can reach the Jellyfin server over on `.1.` fine. All that's required is a little TCP proxy [^2]:

```bash
desktop$ socat -dd TCP4-LISTEN:8096,fork,reuseaddr TCP4:192.168.1.30:8096
```

[^2]: You could also use a HTTP reverse proxy for this, but these tools usually need a bit more config than `socat` does.

Then on the Roku I can configure the Jellyfin client to hit the desktop LAN `.0.` IP and the connection is forwarded on to the remote Jellyfin server at `192.168.1.30`. This worked perfectly fine, but having to keep my desktop on whenever I wanted to use Jellyfin was a bit annoying.

My next idea was to just put this on a Raspberry Pi which I can leave on permenantly without using too much expensive electricity. The downside with this `socat` trick is that it's a bit static, if you wanted to talk to multiple endpoints you'd need to listen on multiple ports and remember all the mappings.

What I really wanted was a proper routed setup, where any `.0.` device can route to anything on the `.1.` network. This is where I had a devious idea --- to use the Raspberry Pi as a bridge for all traffic on the way to my router. Bridging is where a device with two NICs, links them, such that traffic coming in on one, is sent straight back out the other.\
For my purpose the Pi can't act purely as a bridge though, it also needs to do some routing of the `.1.` network bound packets, such that they pass through the tailscale tunnel.

As far as I can tell, this is a bit of an unusual thing to want to do --- it's called bridge routing (or brouting). It doesn't seem to easy to do this with a usual Linux bridge device [^1], but thankfully it's pretty simple to configure something that behaves the same.

[^1]: It might be possible via the `br_netfilter` kernel module and `net.bridge.bridge-nf-call-iptables=1` parameter, but I couldn't figure out how to make it work!

These are the interfaces on my brouter:

```bash
root@raspberry:~# networkctl 
IDX LINK       TYPE     OPERATIONAL SETUP     
  1 lo         loopback carrier     unmanaged
  2 eth0       ether    routable    configured
  3 eth1       ether    routable    configured
  4 tailscale0 none     routable    unmanaged
```

I'm using `eth0` as the upstream side (plugged into the ISP router) and `eth1` as downstream (plugged into a switch and WAP).\
You'll need some kernel config:

<!-- TODO: i want to do all this with systemd-networkd, it seems possible and preferable -->

```bash
root@raspberry:~# cat /etc/sysctl.d/99-proxyarp.conf 
net.ipv4.ip_forward=1
net.ipv4.conf.eth0.proxy_arp=1
net.ipv4.conf.eth1.proxy_arp=1
```
* `ip_forward` makes the kernel to retransmit packets that weren't destined for a local IP address.
* `proxy_arp` causes ARP traffic coming in on one interface to be sent back out of the other, replacing the MAC addresses such that layer 2 works as expected.

Once you've got your kernel parameters set, you need a bit of `iptables` magic to handle the routing part of the equation. We want to mark the `.1.` bound packets, so that they are forced to route via our `tailscale0` interface:


```bash
iptables -t mangle -A PREROUTING -d 192.168.1.0/24 -j MARK --set-mark 1
ip rule add fwmark 1 table 100
ip route add default dev tailscale0 table 100
```

This isn't quite enough to make things work unfortunately. Checking the traffic, I can see packets headed out over the Tailscale interface, but no replies coming back:

```bash
root@raspberry:~# tcpdump -i tailscale0 'icmp' -n
18:53:28.804692 IP 192.168.0.3 > 192.168.1.30: ICMP echo request, id 253, seq 1, length 64
18:53:29.805010 IP 192.168.0.3 > 192.168.1.30: ICMP echo request, id 253, seq 2, length 64
18:53:30.829186 IP 192.168.0.3 > 192.168.1.30: ICMP echo request, id 253, seq 3, length 64
```

This is because devices on the `.1.` net can't route directly back to `.0.`. To make this work we have to SNAT (source NAT) the traffic such that it appears to come from the local side of the Tailscale tunnel:

```bash
iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
```

Now we see replies coming back too! `100.120.7.128` is the local IP of the `tailscale0` interface.

```bash
root@raspberry:~# tcpdump -i tailscale0 'icmp' -n
18:56:50.428553 IP 100.120.7.128 > 192.168.1.30: ICMP echo request, id 254, seq 1, length 64
18:56:50.499516 IP 192.168.1.30 > 100.120.7.128: ICMP echo reply, id 254, seq 1, length 64
18:56:51.429393 IP 100.120.7.128 > 192.168.1.30: ICMP echo request, id 254, seq 2, length 64
18:56:51.517161 IP 192.168.1.30 > 100.120.7.128: ICMP echo reply, id 254, seq 2, length 64
18:56:52.431187 IP 100.120.7.128 > 192.168.1.30: ICMP echo request, id 254, seq 3, length 64
18:56:52.509740 IP 192.168.1.30 > 100.120.7.128: ICMP echo reply, id 254, seq 3, length 64
```

I figure I better include a diagram here:

{{< svg 
	path="network"
	alt="Network diagram of brouting setup"
>}}

The final piece of the puzzle is that this setup breaks DHCP (dynamic IP configuration) --- as it uses broadcast traffic, and the kernel won't forward broadcast traffic. This is pretty easy to work around, you can install a little daemon to proxy traffic recieved downstream on `eth1` up to the ISP router on `eth0`. I used `isc-dhcp-relay` and the config is trivial:

```bash
root@raspberry:~# cat /etc/default/isc-dhcp-relay
# What servers should the DHCP relay forward requests to?
SERVERS="192.168.0.1"
# On what interfaces should the DHCP relay (dhrelay) serve DHCP requests?
INTERFACES="eth1 eth0"
```

The network flow for DHCP now looks like this, where `192.168.0.125` is `eth0`'s local IP and `192.168.0.126` is `eth1`'s:

```bash
root@raspberry:~# tcpdump -i any 'port bootps' -n
19:12:11.5112 eth1  B   IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from aa:bb:cc:dd:ee:ff, length 312
19:12:11.5114 eth0  Out IP 192.168.0.125.67 > 192.168.0.1.67: BOOTP/DHCP, Request from aa:bb:cc:dd:ee:ff, length 312
19:12:11.5345 eth0  In  IP 192.168.0.1.67 > 192.168.0.126.67: BOOTP/DHCP, Reply, length 300
19:12:11.5346 eth1  Out IP 192.168.0.126.67 > 0.0.0.0.68: BOOTP/DHCP, Reply, length 300
19:12:11.5418 eth1  B   IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from aa:bb:cc:dd:ee:ff, length 308
19:12:11.5419 eth0  Out IP 192.168.0.125.67 > 192.168.0.1.67: BOOTP/DHCP, Request from aa:bb:cc:dd:ee:ff, length 308
19:12:11.5684 eth0  In  IP 192.168.0.1.67 > 192.168.0.126.67: BOOTP/DHCP, Reply, length 300
19:12:11.5685 eth1  Out IP 192.168.0.126.67 > 192.168.0.53.68: BOOTP/DHCP, Reply, length 300
19:12:11.5760 eth1  B   IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from aa:bb:cc:dd:ee:ff, length 318
19:12:11.5761 eth0  Out IP 192.168.0.125.67 > 192.168.0.1.67: BOOTP/DHCP, Request from aa:bb:cc:dd:ee:ff, length 318
19:12:11.5814 eth0  In  IP 192.168.0.1.67 > 192.168.0.126.67: BOOTP/DHCP, Reply, length 300
19:12:11.5816 eth1  Out IP 192.168.0.126.67 > 192.168.0.53.68: BOOTP/DHCP, Reply, length 300
```

The advantage of this setup is that it's transparent to downstream devices, they think they are just talking to the ISP router normally. That it just happens to sit on the path is useful if something goes wrong with the Pi [^3], I can just physically unplug it and I won't lose anything other than my extra route.

[^3]: SD card failure being what I am afraid of here!

It probably would have been easier if I had set up my Pi with OpenWRT or similar, and had it act as a normal router, downstream of the ISP provided router. Well, at least this way I learnt some stuff!
