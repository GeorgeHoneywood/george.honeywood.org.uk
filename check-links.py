#!/bin/python3

from os.path import isdir

try:
    with open("links.txt", "r") as f:
        # read the lines, and remove the newline
        urls = [line.strip() for line in f.readlines()]
except FileNotFoundError:
    print("links.txt not found, exiting")
    exit(1)


broken_links = 0

for path in urls:
    if not isdir("public" + path):
        print(f"{path} is a broken link")
        broken_links += 1

if broken_links != 0:
    exit(1)
