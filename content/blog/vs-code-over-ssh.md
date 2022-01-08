---
title: "Visual Studio Code over SSH"
date: 2021-12-18T15:20:00Z
slug: ""
description: "Visual Studio Code over SSH"
keywords: ["ssh", "VS Code", "Visual Studio Code"]
draft: false
tags: ["development"]
math: false
toc: false
comments: true
---

I've recently had an opportunity to do some work away from home. I've never worked on anything other than my desktop PC before. I do have a decently capable laptop, but it has limited RAM and storage -- and hence it is not really suited to running multiple Node.js servers and various Docker containers; let alone the significant faff to get everything set up on my laptop as it is on my desktop PC.

{{< container-image path="images/vs-code-over-ssh/vscode.png" alt="VS Code Screenshot" >}}

To suit this end, Visual Studio Code has a very nice feature that I've been appreciating -- you can connect to a remote instance of VS Code running on any machine you can SSH into. All of this happens automatically, just install the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension, add a target in the "Remote Explorer", and it will install an instance of VS Code on the remote machine. As soon as it has downloaded some files, you will be working on your remote machine just as if it were local.

You can open terminals, and they will be on the remote machine, as you'd expect. It even does some `stdout` parsing to automatically forward ports to your local machine when you run a server. All of this makes for an impressively seamless experience. The only small bit of jank is that you need to install extensions you already have locally on the remote, but the button to replicate your local set practically remediates this.

It works on pretty tiny machines. This is being written on a VPS in Italy with a single vCPU and 1GB of RAM. The disk requirements are likewise pretty minimal, only taking up ~360MB, most of which is two (?) Node.js binaries. Writing some markdown and running `hugo -D` is something my laptop is capable of, so this is a bit of a pointless use case, but I think the technology is really cool. 
