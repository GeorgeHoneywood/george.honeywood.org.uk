---
title: "CV"
comments: false
layout: cv
---
#import "alta-typst/alta-typst.typ": alta, name, skill, styled-link, target, term

#alta(
  name: "George Honeywood",
  links: (
    (name: "email", link: "mailto:contact@george.honeywood.org.uk"),
    (name: "website", link: "https://george.honeywood.org.uk", display: "george.honeywood.org.uk"),
    (name: "github", link: "https://github.com/GeorgeHoneywood", display: "@GeorgeHoneywood"),
    (name: "linkedin", link: "https://linkedin.com/in/georgeHoneywood", display: "George Honeywood"),
  ),
  tagline: context [
    Computer Scientist, Royal Holloway graduate.
    Currently working as an Infrastructure Assistant at GSA Capital.

    #if target() != "paged" {
      [(CV also available as #styled-link("../georgehoneywood-cv.pdf")[a PDF].)]
    }
  ],
  context [
    == Experience

    === Infrastructure Assistant \
    #name[GSA Capital]
    #term[Sep 2023 --- Present][London]

    - Maintaining and monitoring internal infrastucture, including an extensive Linux estate, VMware cluster and Slurm compute cluster.
    - Promptly and professionally handling a wide range of internal user queries, across OS support, cluster compute, networking, and desktop support.
    - Config management via Puppet and Terraform.
    - Automation in Python, streamlining existing processes.
    - Datacenter work, racking & patching servers and appliances.

    === Junior Software Engineer \
    #name[Cudo]
    #term[Jul 2021 --- Jul 2022][Bournemouth, Dorset]

    - Helped develop their first Go microservice, as part of an agile team. This reduced risk exposure when exchanging user balances.
    - Added metrics to track performance data, using Prometheus and Grafana.
    - Worked on their Vue.js web app and Loopback-based API, fixing long-standing bugs and issues in the platform.
    - Implemented a Docker based testing workflow to ensure correctness in database interactions.

    === Junior Systems Administrator \
    #name[Royal Holloway Physics Dept.]
    #term[Oct 2019 --- Jul 2021][Egham, Surrey]

    - Helped with migration from legacy Nagios monitoring system to Icinga, to ensure service continuity.
    - Installed & imaged rack mounted servers for use within a Hadoop compute cluster.

    _References available on request._

    == Education

    === B.Sc. Computer Science (Year in Industry), 1st \
    #name[Royal Holloway, University of London]
    #term[Sep 2019 --- Jul 2023][Egham, Surrey]

    - Final Year Project: offline HTML5 map viewer app. I implemented a TypeScript parser for the binary Mapsforge file format, along with a HTML canvas-based map renderer.
    - Studied modules including: Software Language Engineering, Functional Programming, User-Centred Design, Multi-Agent Systems, Databases, and Operating Systems.

    === A-Levels \
    #name[Bournemouth School Sixth Form]
    #term[Sep 2017 --- Aug 2019][Bournemouth, Dorset]

    - Computer Science (B), Geography (B), Resistant Materials (C), and Physics (D)

    // #if target() == "paged" {
    //  colbreak()
    // }

    == Projects

    === #link("https://github.com/GeorgeHoneywood/drazil")[Web Music Player]

    Created a Spotify-like online music player for your private music collection, with a Go backend and a Vue frontend. Has an album artwork view, and you can queue up songs.

    === #link("https://github.com/GeorgeHoneywood/thegoodmap/")[The Good Map]

    Collaboratively developed a cross-platform mobile app in Flutter, to allow users to find ecofriendly establishments, using data from OpenStreetMap.

    === Employee Appraisal System

    - University project, worked as part of a 4-person team to create a web app, designed to evaluate employees of a company.
    - Developed an API in Flask to conform to a Requirements Specification and Design Description.

    === Hackathons

    / #link(
        "https://github.com/GeorgeHoneywood/PubHub",
      )[Pub Hub]: collaborated on a tool designed to find the optimal route for a pub crawl, providing a solution for the travelling salesman problem.
    / #link(
        "https://github.com/JoeRourke123/metamap",
      )[Metamap]: developed a location based social media app for Android, with the concept of only showing posts within a certain radius of the user.

    === Homelab

    I administrate a headless server which hosts utilities and storage for my home network. It runs Proxmox VE as a hypervisor, with ZFS to provide storage. Each service runs in a separate LXC container, which provides some isolation, without the overhead of full VMs. \
    I also use a small VPS to run other services, like my #link("https://george.honeywood.org.uk")[personal website] #if target() != "paged" [(that you are currently viewing!)] and a WireGuard#sym.trademark.registered VPN.

    == Interests

    - Using and contributing to free & open-source software
    - Editing OpenStreetMap, using JOSM or Every Door
    // - Volunteered with the Scouts as a Young Leader
    // - Amateur photography

    // == Skills

    // #skill("Go", 4)
    // #skill("TypeScript", 5)
    // #skill("Python", 4)
    // #skill("Java", 3)

    // #skill("Linux", 5)
    // #skill("Git", 4)
    // #skill("Docker", 4)
  ],
)
