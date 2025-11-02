#!/usr/bin/env bash

echo "compiling cv to PDF"
# get only the file content after the second '---' (skips YAML frontmatter)
awk 'BEGIN{count=0} /^---$/{count++; next} count==2' "content/cv/index.typ" | typst compile - "static/georgehoneywood-cv.pdf"
