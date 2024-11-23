---
title: "De-Googling myself"
date: 2020-09-09T12:36:38+01:00
slug: ""
description: "90% easy, 10% really hard"
keywords: [google, privacy]
draft: false
tags: [thoughts]
math: false
toc: false
---

A couple of years ago I decided that it would be a great idea if I tried to remove as much Google from my life as possible. I think the reason behind this is that I was slightly afraid as to what Google was getting up to with my data, but also I enjoy fiddling with hosting my own stuff. Google's expansive software graveyard isn't exactly a big selling point either. Using Firefox was an obvious first step, as it works just as well as Chrome for me, and I think multiple different browser engines are an important part of keeping the web open and accessible for everyone.

The easiest thing for me to give up was Google Search. One day I set DuckDuckGo to my default in Firefox and pretty much never had any problems with it. Very occasionally I'll struggle to find something, and I'll use the Google bang (`!g <search term>`) to get there.

The first big step in the purge was GMail. I can imagine for most people this would probably be the worst part, simply because changing your email address -- something you've probably been using for years -- is a massive pain. After some research I settled on FastMail as a provider, due to their support for wildcard addresses. I like to give each website/service I sign up for a different email, for example `reddit@example.com` or `microsoft@example.com` -- this means if a company decides to send me spam, all I have to do is to send all email for that address to the bin. Another benefit of this approach is that you can create mail sorting rules in a foolproof way, i.e. if a business starts to use another domain for its emails they will still make their way into their correct IMAP folders. Its not the cheapest service, and I don't think paid email is for everyone, but it presents enough value for me (although I am considering moving to Migadu).

Something that I've struggled with is Google Photos. Irritatingly this is probably the most invasive service that Google provides -- other than maybe the always-on location tracking. Its just so convenient for me, I use it to store all pictures ever taken my anyone[^1] in my family. It also provides some piece of mind, just as another backup. I'd happily self host a solution like it, just as far as I know nothing quite like it exists yet.

Plex has the ability to display photo libraries, but it feels like a bit of a second class feature compared to the meat of their product -- self hosting your film and television à la Netflix. Rather irritatingly the automatic photo upload feature is paywalled, but its not a massive problem as I use Syncthing to achieve a similar result. Apparently its syncing is a little half baked anyway. This has become a more pressing issue now that Google is going to start limiting uploads to Photos, even though it'll probably take me a year or so to fill my quota.

YouTube was also difficult. It would really make me happy to avoid it, but it currently has no real competitors, which I think is something that will become more of a problem in the years to come. I suppose the end goal is something like [PeerTube](https://peer.tube/), which is a federated streaming platform, with its own users providing a CDN for its content. However  I'm not entirely sure that that model is sustainable enough to compete with a giant like Google, as the amount of storage required is still massive.

With Android I have come to a compromise, using LineageOS instead of the stock ROM on my phone. I also much prefer using F-Droid whenever possible over the Google Play Store, but I haven't gone as far to completely avoid Google Play Services yet. MicroG seems like a good solution, but I haven't gotten round to testing it out yet.

This is not something I'd recommend for everyone, simply because it is not really worth the struggle of detangling yourself from Google's tentacles, unless its something that you really believe is important. I'll probably update[^2] this page eventually with my progress, which has rather depressingly slowed recently.

[^1]: Even the slightly scary childhood videos
[^2]: 2021-02-22: I added sections about Google Photos alternatives
