#import "alta-typst/alta-typst.typ": alta, term, skill

#alta(
  name: "George Honeywood",
  links: (
    (name: "email", link: "mailto:contact@george.honeywood.org.uk"),
    (name: "website", link: "https://george.honeywood.org.uk", display: "george.honeywood.org.uk"),
    (name: "github", link: "https://github.com/GeorgeHoneywood", display: "@GeorgeHoneywood"),
    (name: "linkedin", link: "https://linkedin.com/in/georgeHoneywood", display: "George Honeywood"),
  ),
  tagline: [Computer Scientist, Royal Holloway graduate. Currently looking for a new role.],
  [
    == Experience

    === Junior Software Engineer \
    _Cudo_\
    #term[Jul 2021 --- Jul 2022][Bournemouth, Dorset]

    - Helped develop their first Go microservice, as part of an agile team. This reduced risk exposure when exchanging user balances.
    - Added metrics to track performance data, using Prometheus and Grafana.
    - Worked on their Vue.js web app and Loopback-based API, fixing long-standing bugs and issues in the platform.
    - Implemented a Docker based testing workflow to ensure correctness in database interactions.

    === Junior Systems Administrator \ 
    _Royal Holloway Physics Dept._\
    #term[Oct 2019 --- Jul 2021][Egham, Surrey]

    - Migrated from legacy Nagios monitoring system to Icinga to ensure service continuity. This included setting up Icinga Director, which allows new hosts to be added through a web interface.
    - Installed & imaged rack mounted servers for use within a Hadoop compute cluster

    References available on request

    == Education

    === B.Sc. Computer Science (Year in Industry), 1st \
    _Royal Holloway, University of London_\
    #term[Sep 2019 --- Jul 2023][Egham, Surrey]

    - Final Year Project: offline HTML5 map viewer app, for which I implemented a TypeScript parser for the binary Mapsforge file format. I also developed a canvas-based map renderer.
    - Studied modules including: Software Language Engineering, Functional Programming, User-Centred Design, Multi-Agent Systems, Databases, and Operating Systems.

    === A-Levels \
    _Bournemouth School Sixth Form_\
    #term[Sep 2017 --- Aug 2019][Bournemouth, Dorset]

    - Computer Science (B), Geography (B), Resistant Materials (C), and Physics (D)

    == Interests

    - Using and contributing to free & open-source software
    - Editing OpenStreetMap, using JOSM or Every Door
    // - Volunteered with the Scouts as a Young Leader
    // - Amateur photography
  ],
  [
    == Projects

    ==== #link("https://github.com/GeorgeHoneywood/drazil")[Web Music Player]

    Created a Spotify-like online music player for your private music collection, with a Go backend and a Vue frontend. Has an album artwork view, and you can queue up songs.

    ==== #link("https://github.com/GeorgeHoneywood/thegoodmap/")[The Good Map]

    Collaboratively developed a cross-platform mobile app (in Flutter) to allow people to find environmentally friendly establishments, using data from OpenStreetMap.

    ==== Employee Appraisal System

    - Worked as part of a 4-person team to create a web app, designed to evaluate employees of a company.
    - Developed an API in Flask to conform the Requirements Specification and Design Description.
    - After development was completed, wrote an Acceptance Testing report, for a delivered solution from another team.

    ==== Hackathons

    / #link("https://github.com/GeorgeHoneywood/PubHub")[Pub Hub]: collaborated on a tool designed to find the optimal route for a pub crawl, providing a solution for the travelling salesman problem.
    / #link("https://github.com/JoeRourke123/metamap")[Metamap]: developed a location based social media app for Android, with the concept of only showing posts within a certain radius of the user.

    ==== Homelab

    - I administrate a headless server which hosts utilities and storage for my home network. It runs Proxmox VE as a hypervisor, with ZFS to provide storage.
    - Each service runs in a separate LXC container, to ensure isolation & security. It also enables me to safely update programs, as you can roll back if issues occur.
    - NGINX is used as a reverse proxy, to allow external access to internal services, such as a Nextcloud instance.
    
    ==== VPS
    
    - I use a small VPS to run other services, like Gitea, which is used to host Git repositories for projects that I am developing.
    - As it has a fast internet connection, I also use it as a VPN (through WireGuard) to protect my traffic on unsecured Wi-Fi.

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
