---
title: "Building a digital map from the ground up"
date: 2023-07-04T11:19:09Z
draft: true
description: "A summary of how one might go about building a digital map from the ground up."
keywords: ["maps", "projection", "tiles", "openstreetmap"]
tags: ["openstreetmap", "projects"]
math: false
toc: false
comments: true
---

This is a summary of the Final Year Project that I completed as part of my last year at Royal Holloway. The task was to produce an "Offline HTML5 Map Application".

This is a slightly weird thing to do. Most web maps are decidedly online, fetching tiles dynamically from a tile sever whenever they are required. Most offline map applications are native apps for mobile devices, which fulfil the main use case for an offline map, navigation. However, it is possible to build offline web apps, through technologies like Service Workers, and it seemed like a good opportunity for me to understand the lower levels of how web maps work.

What follows is a summary of how a digital map is built, in more of a logical order than strictly adhering to the chronology of the project developed.

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

Instead of the shape of this building being directly represented (like a GeoJSON LineString), a way is made up of constituent nodes, which can then be looked up by ID, to find their position, to derive the geometry of a building. Each of these ways is linearly stored in the file, one after the other, with no geospatial indexing.

In order to allow for real-time performant rendering, we have to make two main optimizations: tiling, and zoom simplification. These are both processes that have to be done in advance.

Tiling is the process of splitting the map data into a grid of tiles. Dividing the area up into a grid means that we only need to send (and render) the data currently within the clients' viewport. For example, if a user is zoomed in on Trafalgar Square in London, there is no point sending detailed map data for the whole of the UK, or even the whole of London, as it will not be on the screen. Each zoom level has its own set of tiles, and these can be accessed through Z/X/Y coordinates, where the maximum X/Y values double as Z increases by one.

Simplification is less relevant for a zoomed in view, but is very necessary for a zoomed out region or country zoom level. It is simply not possible (in real time) to render all the detail of a whole country -- and besides, rendering the exact geometry of a road is not necessary, as it can't be seen from the zoomed out view. Therefore, in advance, we must simplify the data in order to remove unnecessary detail. This is effectively invisible to the user if executed well, as it should only remove what is imperceptible. The Douglas-Peucker algorithm is a popular algorithm for achieving this, but some manual tag-based checks are also required, so that you only preserve large roads and other important details when zoomed out.

As part of this, you need to decide at how many zoom levels you provide simplified versions of the geometry. There is a trade-off here -- if you stored a simplified version for every zoom level between 1 and 20, the versions only one level apart will basically be duplicates, storing almost the same data, wasting space. For the zoom levels you don't store a simplified version for, you can either "under-zoom" a more detailed one, or "over-zoom" in the other direction. For example, if you stored a simplified copy at zoom 14, you could still render data at z12, albeit at a performance loss, as you are rendering unperceivable details. Equally, you could also render at z16, but the artefacts introduced by simplification may become visible (TODO: add sample image of overzoom).

Developing my own map file format that handles both of these issues would have been a significant undertaking, so I decided that using an existing option would the best strategy. Luckily for me, the Mapsforge project has developed a file format (TODO: CITE HERE) which satisfies both of these requirements. Therefore, for this project, I decided it made sense to interpret these files, and render them to a canvas. (FIXME: reword this)

As far as I can tell, there is not an existing library for reading Mapsforge format map files in JavaScript/TypeScript, apart from this effort by [ThomasHubelbauer](https://github.com/TomasHubelbauer/mapsforge/blob/main/index.js) -- which goes as far as decoding the file header.

The basic structure of the Mapsforge file format is as follows (see the [specification for details](https://github.com/mapsforge/mapsforge/blob/master/docs/Specification-Binary-Map-File.md)):

* Header: contains metadata about the map, such as bounding boxes, details about the zoom levels that simplified geometry is stored for (referred to as "zoom intervals").
* For each zoom interval, a subfile, which itself contains:
    * An index, allowing you to locate simplified tile data via Z/X/Y tile coordinates.
    * The simplified tile data itself, first Point of Interest (PoI) data, then Way data.

There are a number of neat tricks the format uses to eke out extra performance. For example, each zoom simplified tile is stored with a "zoom table", which is used to limit the number of features that are rendered if a tile is being over-zoomed or under-zoomed. This seems a little odd, but as both the data is stored in priority order, Ways/PoIs that should be rendered at the lowest zooms are stored first, and therefore if we just stop rendering features after the depth specified in the zoom table, we can render extra features as we zoom, even though we are only storing a single simplified version of the tile.

* delta encoding/ double delta
* varible length encoding for ints etc
* packing multiple values into a single byte

As I'd never written any binary parsing code before, this was quite an instructive process for me. Although the [specification](https://github.com/mapsforge/mapsforge/blob/master/docs/Specification-Binary-Map-File.md) was very helpful, it was often not exactly obvious how to utilize the decoded data, and there were some confused details. At one point I had to dig into the Java sources of the reference implementation, as the specification did not align with what was actually in the files [^1]. I even wrote a simple hexdump function to help me debug issues with my parser.

[^1]: I ended up contributing [a PR](https://github.com/mapsforge/mapsforge/pull/1374) to clarify the wording of the specification. 

The next step is actually rendering the data. At a basic level this isn't too complicated. You first need to project the coordinates from WGS-84 to your desired projection, in my case Web Mercator. The Web Mercator projection is conformal, meaning it preserves angles (locally) whilst distorting area. Once you've projected the coordinates, you can draw the data to the canvas -- although you might need to scale the coordinates so that they fit within the viewport of the canvas.
