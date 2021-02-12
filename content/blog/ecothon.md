---
title: "ecothon!"
date: 2021-02-12T11:46:43Z
slug: ""
description: "ecothon is a social network for those who care about the environment"
keywords: ["hackathon", "ecothon", "github"]
draft: true
tags: ["projects"]
math: false
toc: false
---

## demo

Last weekend I took part in hackathon working with 3 of my housemates. We decided to make an social network app that inspires people to live a more eco-concious lifestyle. It has a concept of achievements, which are simple changes or tasks that people can make to reduce their impact.

{{< container-image path="images/ecothon/achievement.jpg" method="Resize" options="400x png Lanczos" width="45%" margin="10px" alt="Achievement" >}}

You can either privately complete an achievement, or create a post linked to that specific achievement. Either of these will add to your "carbon score", which is displayed on a leaderboard against people you are following.

{{< container-image path="images/ecothon/leaderboard.jpg" method="Resize" options="400x png Lanczos" width="45%" margin="10px" alt="Leaderboard" >}}

You can also like and comment on posts, or view a map of where posts were made from. As you can see we don't get out of the house much...

{{< container-image path="images/ecothon/map.jpg" method="Resize" options="400x png Lanczos" width="45%" margin="10px" alt="Leaderboard" >}}

The app opens to a feed, showing all the posts that have been made in your area. These are normally associated with an image, but it is possible to make a post without one.

{{< container-image path="images/ecothon/feed.jpg" method="Resize" options="400x png Lanczos" width="45%" margin="10px" alt="Leaderboard" >}}

## how it works

The app itself was made using Flutter, a cross platform UI toolkit -- theoretically it should work on mobile, desktop and web. However we only tested it on Android, and I'm not sure quite how theoretical Flutter's support for the others is.

We made the backend in Go, using `go-fiber` as a framework. None of us had properly used Go before and it was a good introduction to it. Personally I really like it so far, other than getting used to things that I'd do in one line on Python have to be done on 2 or more to handle functions returning `error` alongside their results. There is the obvious upside to this that you actually have to think about handling these errors, encouraging correct code. It also means Go is unencumbered by exceptions being thrown all over the place, part of why it is so fast.

The backend is hosted entirely on Digital Ocean, as they were kind enough to provide free credit for their product. I set up Github actions to automatically build a docker image and push it to Digital Ocean's container registry. The workflow then logs into their Kubernetes platform, deploying the new version by updating the config so that the latest push to `master` is deployed.

We run two nodes in the cluster, with traffic split between them using a load balancer (which is completely unnecessary for the level of traffic). User images are uploaded to their equivalent of S3, and the data is all stored in a MongoDB instance hosted by Atlas. As I'd never used it before, setting up Kubernetes was a fairly large learning curve, but tutorials like [this one](https://www.digitalocean.com/community/tutorials/how-to-deploy-resilient-go-app-digitalocean-kubernetes) really helped get us up and running fairly quickly.

## github repository

You can see the repository [here,](https://github.com/JoeRourke123/ecothon) or even try it out if you are feeling brave.
