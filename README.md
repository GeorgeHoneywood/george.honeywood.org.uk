## [`george.honeywood.org.uk`](https://george.honeywood.org.uk/)

My personal blog, mostly about, but not limited to, GIS and Software Engineering.

<img src="https://user-images.githubusercontent.com/25514836/228018785-ac38d65f-2fe9-422f-9b28-05c6e497446f.png" width="700"></img>

Compiles to static HTML using Hugo. The theme is based on [Codex](https://github.com/jakewies/hugo-theme-codex), with an added dark theme.

Deploys to prod with a simple [`rsync` script](deploy.sh) to my VPS. For staging, GitHub Actions automatically deploys new commits to [Sourcehut Pages](https://master.staging.george.honeywood.org.uk/). 
