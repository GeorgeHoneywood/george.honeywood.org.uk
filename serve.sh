#!/usr/bin/env bash

while true; do inotifywait -e modify content/cv/index.typ; ./cv.sh; done &

~/code/contrib/hugo/hugo -D serve --disableFastRender "$@"
