# Arlington Heights history through art

## Page for artists
[artist page](https://arlington-heights-historical-society.github.io/ah-history-through-art/)
can be found at that link.

It is a Jekyll site, the code lives in [docs](docs/)

The root webpage is the markdown file: [index.md](docs/index.md)


## Infrastructure
All infra tools require the [hydrate local env](hydrate-local-env.sh) script.
* upload images
* convert PNG files to webp files for image autosizing in the site


## Cursor CLI
The Dockerfile was setup to run the Cursor CLI in a container as a sandbox where the docker mount maps container<->local file system.


## Wiki 
[The wiki](wiki/) section holds other useful information that is not directly needed to be published to a public facing website. Living in the repo is fine.

