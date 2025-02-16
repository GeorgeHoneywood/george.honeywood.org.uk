---
title: "Visualising OpenStreetMap changes at a macro scale"
date: 2020-08-30T12:17:38+01:00
slug: ""
description: "How to see what you've done in OSM."
keywords: [openstreetmap, data visualisation]
draft: false
tags: [openstreetmap]
math: false
toc: true
---

## the problem

One of the most satisfying things for me, as a contributor to OSM, is to see how my changes have improved the map for everyone. There currently are a number of ways to achieve this, which primarily focus on the micro level, for example a single changeset (such as [OSMCha](https://osmcha.org)). These are very useful for checking for things like vandalism, and simply just showing what that changeset did to nodes, ways & relations. On the other hand, I've yet to find something that lets me see what has happened in an area over a greater time period.

## the goal (with hindsight...)

In an ideal world, I can picture a screen with two maps, with one on top of the other, each with a date picker. There would be a slider which can be moved from one side to the other to show the differences between them. This layout is inspired by the currently out of service [OSM Then and Now](https://mvexel.github.io/thenandnow/), which goes some of the way towards a solution, but the data shown is too old to be useful for me.

## a partial solution

### viability

In OpenStreetMap people contribute through a system called changesets. These effectively group together a number of alterations (additions, edits, deletions) to the data structures of OSM, and can be thought of as analogous to `git` commits. These changesets can then be combined in the order of their creation to create an up to date version of the database.

Therefore, it is possible to recreate the database of any point in time by ignoring any changesets that were authored after that point, which can be done using a tool such as [`osmium`](https://osmcode.org/osmium-tool/).

### implementation

I followed a method similar to the one in [this](https://hackmd.io/XfrY334rS7CV0tnPzx8Wvw) post, however, after filtering the history file to the desired time, I imported it into Postgres (using osm2psgl).

Once I had everything in Postgres I first tried to use the [`nik4`](https://github.com/Zverik/Nik4) tool, which worked as described. However, it wasn't really built for my usecase; for example, I had to manually create an image for each location I wanted to compare. It also wasn't great for directly comparing old tiles to the current ones.

Therefore, I decided that it'd be best to just create a full on slippy map, using the normal stack, a-la [switch2osm](https://switch2osm.org/serving-tiles/manually-building-a-tile-server-20-04-lts/). This gave me pretty much a full recreation of how the map at [openstreetmap.org](https://openstreetmap.org) looked at the time period I picked.

Using the Leaflet library to display these tiles, I followed an example from Mapbox on how you can overlay two different maps with a slider. I also added two pieces of text to illustrate which side was which.

{{< image path="result" alt="Leaderboard" >}}

You can see the result at [https://maps.honeyfox.uk](https://maps.honeyfox.uk) (which only works for the UK). This will likely be very impermanent, as I don't really have the means to host it -- the database and tileserver are currently on my desktop PC, with an SSH tunnel up to my VPS.

### failures

This solution partially meets my goal. Ideally you'd be able to set the specific date that each side of the map displayed, but as far as I'm aware there is no way to achieve that without having to drop the database and re-import everything from the other time period. The map stack I'm using (postgres/postgis/mapnik/renderd/mod_tile/apache2 - bit of a mouthful) isn't really designed to display anything but the latest version of the data, as typically that's all you'd really need.

## conclusion

I think this would be a valuable tool to help motivate contributors if the implementation was improved. I'd really appreciate any suggestions or advice on how to achieve this.

## late 2022 update

In July 2021, I made some upgrades to this demo, but never got round to updating this post. It is still running at [https://osm-history.george.honeywood.org.uk](https://osm-history.george.honeywood.org.uk).

Instead of showing just one set of old tiles, it shows the state every year between 2007 and 2022. As rendering the tiles live requires a beefy server, I used a script to download the tiles for each year I wanted, making everything static. This only works because I only wanted to render a relatively small area -- when you increase the area, the amount of tiles you need to download grows exponentially. This demo is now just a bunch of `$year/$z/$x/$y.png`s I serve using nginx on my little VPS.

Departing from the technical details, you can see my contributions begin in 2019. My initial prompt to start editing OSM was that a new build estate near my house was missing from the map (you can see it appear [here](https://osm-history.george.honeywood.org.uk/#17/50.78814/-1.90129) in 2019).

In some years there aren't many changes. In others a lot of stuff is changed -- between 2010 and 2011, all the roads and residential areas were added. From then all is quiet until 2018, when most of the houses were drawn in. Someone[^1] gave [Ferndown Golf Club](https://osm-history.george.honeywood.org.uk/#16/50.7994/-1.8767) an excellent makeover in 2022, adding all the hole numbers, greens, fairways and bunkers. I can and have spent ages looking at this visualization. Something about it is extremely satisfying to me.

[^1]: I would never map something like this myself. This is part of the beauty of OSM -- people map the things they care about. I'd never map a golf course partially because I know nothing about golf, and partially because I vaguely disapprove of it as a landuse. There are currently three 18-hole courses within 3 km of my parent's house (there used to be 4!).

One day I hope to make something like this that can scale up globally, or at least to a national scale.
