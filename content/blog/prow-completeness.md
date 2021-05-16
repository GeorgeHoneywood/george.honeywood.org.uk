---
title: "Measuring PRoW completeness"
date: 2021-05-12T11:46:43Z
slug: ""
description: "figuring out how well public rights of way are represented in OpenStreetMap"
keywords: ["openstreetmap", "prow", "rights of way"]
draft: true
tags: ["openstreetmap"]
math: false
toc: false
---

Recently I stumbled upon on a [page](https://wiki.openstreetmap.org/wiki/Contributors) on the OpenStreetMap wiki which details some of the significant non-volunteer sources for OSMs data (and takes an amusingly long time to load). Near the bottom I discovered that Dorset (my Local Authority) publishes an OGLv3 licensed dataset of public rights of way within its boundaries, including public footpaths, bridleways, restricted byways, and the rare BOAT (byway open to all traffic). These somewhat confusingly do not directly overlap with OpenStreetMaps normal tagging schemes, as a public footpath/bridleway/... may be part of a service road, residential road or a cycleway for example. To address this need another [wiki page](https://wiki.openstreetmap.org/wiki/Access_provisions_in_the_United_Kingdom#Public_Rights_of_Way) details a schema for tagging this extra information, using `designation=public_${xyz}` and `prow_ref=${yzx}`.

Looking at the shapefile in QGIS I found that quite a significant number of the paths had not been added to OSM. I think a large part of the disparity is due to that a significant portion of the rights of way are not in a usable state, or a more convenient permissive route is present. However, I think it is still important to include this data in OpenStreetMap as more paths to explore is always good. When I find one such unusable path, usually by looking at the Strava Heatmap I tend to map the route anyway and then add `highway=no` to indicate that the route is impassable. When the chosen route of the public deviates a little from the public footpath I will tend to adjust the official route to the well used one, especially if it is obvious that the definitive version is unusable. If the actual footpath is far away from where it should be I normally draw the actual route seperate from the right of way, tagging both respectively.

In order to help me determine which PRoWs were missing I used QGIS to analyse the data, with the following methodology (bear in mind I am a complete amateur at GIS):

* Download the `.osm.pbf` file for Dorset from Geofabrik, for comparing it to the PRoW dataset.
* Use [`osmium`](https://osmcode.org/osmium-tool/) to filter the `.pbf` to only include specify highway tags that are likely to support a PRoW, such as `highway=footway`, `highway=service`, `highway=residential` and so on. 
* Import the datasets into QGIS, reprojecting into a different CRS if necessary.
* Use the [points along geometry](https://docs.qgis.org/3.16/en/docs/user_manual/processing_algs/qgis/vectorgeometry.html#points-along-geometry) tool to place points at a regular interval (I used 25m) on both the OSM and PRoW datasets. This is to ensure that straight sections of line still contain vertices, which is important for the next step of analysis.
* Employ the [hub to hub distance](https://docs.qgis.org/3.16/en/docs/user_manual/processing_algs/qgis/vectoranalysis.html#distance-to-nearest-hub-points) tool to find the nearest node in OSM from each node in the PRoW, which is done by setting the PRoWs as the source, and OSM as the destination. We can't use the [join attributes by nearest](https://docs.qgis.org/3.16/en/docs/user_manual/processing_algs/qgis/vectorgeneral.html#qgisjoinbynearest) for this as it works based on line centeroids, which may be completely different in the datasets. For example if a public footpath begins halfway up the length of a residential road, then they end at the same point, their centeroids will be quite far apart, despite their significant overlap and hence will not conflate.
* Add a virtual layer, I called mine `missing_prow_list`. This will allow you to write arbitrary SQL to create a list of the missing PRoWs route codes. I ended up using something like the below -- this will select any rights of way which are on average more than 30m away from a `highway=*` in OSM:

```SQL
SELECT route_code, AVG(hub_to_hub_dist) as avg_hub_dist,
FROM prow_dataset_distances
GROUP BY route_code
HAVING avg_hub_dist > 40;
```

* Use another virtual layer to get the actual geometries out of the original PRoW lines, using a join:

```SQL
SELECT route_code, designation, geometry
FROM prow_dataset
INNER JOIN missing_prow_list
ON missing_prow_list.route_code = prow_dataset.route_code
```

* Select your second virtual layer in QGIS and export it as a shapefile. This can then be imported into JOSM, or any editor of your choice, then manually merged into OpenStreetMap after being tagged up appropriately. Hint -- this is by far the hardest step.
* Job done :)

This method is not perfect, as it will miss smaller footpaths, such as those that join two roads only a short distance apart -- and hence it is more useful for rural areas. On the other hand it seems to rarely produce false positives.

Ideally when OSM has further matured this will become simpler, as we could just compare the list of PRoW route codes to the `prow_ref=*` tags. Unfortunately it seems a significant amount of PRoWs haven't been given this tag yet, meaning it is not yet viable due to the number of false positives.

Let me know if you have any ideas on how to compare OSM to other datasets :)