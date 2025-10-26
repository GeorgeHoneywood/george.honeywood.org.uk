#!/usr/bin/env bash

echo "compiling cv to PDF and HTML..."
typst compile "cv/georgehoneywood-cv.typ"
typst compile --format html --features html "cv/georgehoneywood-cv.typ"
echo "copying cv in"
mv "cv/georgehoneywood-cv.pdf" "static/"