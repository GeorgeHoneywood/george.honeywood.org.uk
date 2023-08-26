#!/usr/bin/env bash

echo "compiling cv..."
typst compile "cv/georgehoneywood-cv.typ"
echo "copying cv in"
mv "cv/georgehoneywood-cv.pdf" "static/"