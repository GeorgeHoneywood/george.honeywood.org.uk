---
title: "Complicated history"
date: 2021-06-20T11:41:00Z
slug: ""
description: "working with OpenStreetMap history files"
keywords: ["openstreetmap"]
draft: false
tags: ["openstreetmap"]
math: false
toc: false
comments: true
---

I've been working on a tool that takes an OpenStreetMap history file, and creates a database with every version of the way that has existed. On the surface it looks like you just need to save each of the ways [versions](https://www.openstreetmap.org/way/4527617/history), but it is a little more nuanced than this as OSM's data structure doesn't make it very convenient. Part of the problem is that ways only get a new version number whenever nodes are added or removed from them -- but do not if their component nodes change location. For example if you have a building, you can move the entire building by moving its existing constituent nodes, without creating a new version of the way.

This means that to get all geometries of a way you first have to cache which nodes make up a way in each of its versions, then check if these nodes get a new version in between each of the ways versions, so that you can store the ways geometries where just nodes moved. Ideally for my use case, the way would be updated whenever one of its nodes moves, and instead of a way containing a list of references to node ids, the reference would be to a specific version of that node. This would make it much simpler to piece together all of the geometries that a way has had, as you wouldn't have to solve the non trivial (to optimise) problem of figuring out which versions of nodes made up the way at that time.

Granted for the much more common usecase of just looking at a *single* point in OSM history, it is trivial to generate a snapshot of OSM data -- you just have to take the latest version of every non-deleted element before your desired time. This can be done nicely using osmium-tool's `time-filter` command.
