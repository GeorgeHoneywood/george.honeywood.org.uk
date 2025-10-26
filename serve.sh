#!/usr/bin/env bash

# you probably also want to run this in another terminal
# typst watch --format html --features html cv/georgehoneywood-cv.typ &

hugo -D serve --disableFastRender "$@"
