---
title: "Building a digital map from the ground up"
date: 2023-07-04T11:19:09Z
draft: false
description: "A summary of how one might go about building a digital map from the ground up."
keywords: ["maps", "projection", "tiles", "openstreetmap"]
tags: ["openstreetmap", "projects"]
math: false
toc: false
comments: true
---

This is pretty much a summary of the Final Year Project, that I completed at Royal Holloway. The task was to produce an "Offline HTML5 Map Application".

This is a slightly weird thing to do. Most web maps are decidedly online, fetching tiles dynamically from a tile sever whenever they are required. Most offline map applications are native apps for mobile devices, which fulfil the main use case for an offline map, navigation. However, it is possible to build offline web apps, through technologies like Service Workers, and it seemed like a good opportunity for me to understand the lower levels of how web maps work.

What follows is a summary of the main chunks that you need, in more of a logical order than strictly adhering to the chronology of the project.

First, you need data to render. Raw OpenStreetMap data comes in either XML, or a more efficient, but semantically similar binary representation, known as PBF. Neither of these are particularly suitable for rendering a map from -- they are instead designed to simplify editing. Here is an example of a building in raw OSM XML:

```xml
<osm version="0.6" generator="CGImap 0.8.8 (2471524 spike-07.openstreetmap.org)" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
 <way id="590592938" visible="true" version="4" changeset="122480423" timestamp="2022-06-16T20:22:59Z" user="GeorgeHoneywood" uid="10031443">
  <nd ref="5638445937"/>
  <nd ref="5638445938"/>
  <nd ref="5638445939"/>
  <nd ref="5638445940"/>
  <nd ref="5638445937"/>
  <tag k="addr:housenumber" v="21"/>
  <tag k="addr:street" v="Locksley Drive"/>
  <tag k="building" v="detached"/>
 </way>
 <node id="5638445937" lat="50.7929905" lon="-1.8975593" visible="true" version="3" changeset="85567769" timestamp="2020-05-21T17:50:39Z" user="GeorgeHoneywood" uid="10031443" />
 [... more nodes ...]
</osm>
```

Instead of the shape of this building being directly represented (like a GeoJSON LineString), a way is made up of constituent nodes, which can then be looked up by ID, to find their position, to derive geometry of a building. 
