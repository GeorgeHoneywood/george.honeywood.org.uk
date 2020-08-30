---
title: "Visualising OpenStreetMap changes at a macro scale"
date: 2020-08-30T12:17:38+01:00
slug: ""
description: "How to see what you've done in OSM."
keywords: [openstreetmap, data visualisation]
draft: true
tags: [openstreetmap]
math: false
toc: true
---

## the problem

One of the most satisfying things for me, as a contributor to OSM, is to see how my changes have improved the map for everyone. There currently are a number of ways to achieve this, which primarily focus on the micro level, for example a single changeset (such as [OSMCha](https://osmcha.org)). These are very useful for checking for things like vandalism, and simply just showing what that changeset did to nodes, ways & relations. On the other hand, I've yet to find something that lets me see what has happened in an area over a greater time period.

## the goal (with hindsight...)

An ideal world, I can picture a screen with two maps, with one overlaid on the other, each with a date picker. There would be a slider which can be moved from one side to the other to show the differences between them. This layout is inspired by the currently out of service [OSM Then and Now](https://mvexel.github.io/thenandnow/), which goes some of the way towards a solution, but the data shown is too old to be useful for me.

## a partial solution

### viability

In OpenStreetMap people contribute through a system called changesets. These effectively group together a number of alterations (additions, edits, deletions) to the data structures of OSM, and can be thought of as analogous to `git` commits. These changeset can then be combined in the order of their creation to create an up to date version of the database.

Therefore it is possible to recreate the database of any point in time by ignoring any changesets that were authored after that point, which can be done using a tool such as [`osmium`](https://osmcode.org/osmium-tool/).

### implementation

I followed a method similar to the one in [this](https://hackmd.io/XfrY334rS7CV0tnPzx8Wvw) post, however after filtering the history file to the desired time I imported it into Postgres (using osm2psgl).

Once I everything in Postgres I first tried to use the [`nik4`](https://github.com/Zverik/Nik4) tool, which worked as described. However it wasn't really built for my usecase, for example I had to manually create an image for each location I wanted to compare. It also wasn't great for directly comparing old tiles to the current ones.

Therefore I decided that it'd be best to just create a full on slippy map, using the normal stack, a-la [switch2osm](https://switch2osm.org/serving-tiles/manually-building-a-tile-server-20-04-lts/). This gave me pretty much a full recreation of how the map at [openstreetmap.org](https://openstreetmap.org) looked at the time period I picked.

Using the Leaflet library to display these tiles, I followed an example from Mapbox on how you can overlay two different maps with a slider. I also added two pieces of text to illustrate which side was which.

You can see the result at [https://maps.honeyfox.uk](https://maps.honeyfox.uk) (which only works for the UK). This will likely be very impermanent, as I don't really have the means to host it -- the database and tileserver are currently on my desktop PC, with an SSH tunnel up to my VPS.

### failures

This solution partially meets my goal. Ideally you'd be able to set the specific date that each side of the map displayed, but as far as I'm aware there is no way to achieve that without having to drop the database and re-import everything from the other time period. The map stack I'm using (postgres/postgis/mapnik/renderd/mod_tile/apache2 - bit of a mouthful) isn't really designed to display anything but the latest version of the data, as typically that's all you'd really need.

## conclusion

I think this would be a valuable tool to help motivate contributors if the implementation was improved. I'd really appreciate any suggestions or advice on how to achieve this.
