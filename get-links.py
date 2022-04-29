#!/bin/python3

from xml.etree import ElementTree as ET
from urllib.parse import urlparse

# get the links from the sitemap.xml
tree = ET.parse('public/sitemap.xml')
urls = [url.text for url in tree.findall('.//{http://www.sitemaps.org/schemas/sitemap/0.9}loc')]

# remove the hostname from the urls
urls = [urlparse(url).path for url in urls]

# write the links to a file if they aren't already there
try:
    with open('links.txt', 'r') as f:
        # read the lines, and remove the newline
        existing_urls = [line.strip() for line in f.readlines()]
except FileNotFoundError:
    existing_urls = []

added_urls = 0
with open('links.txt', 'a') as f:
    for url in urls:
        if url not in existing_urls:
            f.write(url + '\n') 
            added_urls += 1

print(f"added {added_urls} new URLs, and skipped {len(existing_urls) - added_urls} existing URLs")
