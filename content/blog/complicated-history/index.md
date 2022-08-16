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

I've been working on a tool that takes an OpenStreetMap history file and creates a database with every version of the way that has existed.
On the surface it looks like you just need to save each of the ways [versions](https://www.openstreetmap.org/way/4527617/history),
but it is a little more nuanced than this. OSM's data structure doesn't make this very convenient.
Ways get a new version number whenever nodes are added or removed from them
-- but do not if their component nodes change location.
For example if you have a building,
you can move the entire building by moving its existing constituent nodes,
without creating a new version of the way.

This means that to get all geometries of a way you first have to cache which nodes make up a way in each of its versions,
then check if these nodes get a new version in between each of the ways versions,
so that you can store the ways geometries where just nodes moved.
Ideally for my use case,
the way would be updated whenever one of its nodes moves,
and instead of a way containing a list of references to node ids,
the reference would be to a specific version of that node[^1].
This would make it much simpler to piece together all of the geometries that a way has had,
as you wouldn't have to solve the non trivial problem of figuring out which versions of nodes made up the way at that time.

[^1]: This would probably have a slightly undesirable side-effect:
big relations (like country boundaries) would get versioned each time they are adjusted, leading to extremely high version numbers.

Granted for the much more common usecase of just looking at a *single* point in OSM history,
it is trivial to generate a snapshot of OSM data
-- you just have to take the latest version of every non-deleted element before your desired time. This can be done nicely using osmium-tool's `time-filter` command.

### 2022-08 edit

So I realised this is actually a bit more complicated than I previously thought.
With relations there is a similar issue to ways
-- you can move or update the underlying members of a relation,
without updating the relation itself.

For example if a building with a courtyard is represented by a multipolygon relation,
you can change the landuse of the courtyard,
without creating a new version of the relation.
This is because the tags only change on the courtyard way, not the relation itself.
You will get a new relation version if you change the tags on the relation, alter the members, or change the roles of members.
