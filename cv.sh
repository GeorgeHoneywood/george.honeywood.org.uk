#!/usr/bin/env bash

echo "compiling cv to PDF"
typst compile "content/cv/index.typ" "static/georgehoneywood-cv.pdf"
