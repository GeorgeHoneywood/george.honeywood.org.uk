---
title: "Proper Hugo Typst support"
date: 2025-11-02T12:29:41Z
draft: false
description: "Extending Hugo to render Typst natively"
keywords: ["typst", "hugo", "static site generator"]
tags: ["projects", "typst", "development"]
math: false
toc: false
comments: true
---

#show math.equation: it => html.div(class: "typst-equation", html.frame(it))
#show math.equation.where(block: false): box
#show raw.where(block: true): it => html.div(class: "typst-code", it)

This post is written in Typst!

I had a first pass at making Hugo deal with Typst's HTML export support last weekend, see #link("{{< relref "typst-and-hugo" >}}")[Typst + Hugo]. It worked, but not very well!
It was OK for one dedicated page, but not good enough for writing normal blog posts with. You had to add a dedicated template for each page, and manually export the `.typ` files to HTML out of band from Hugo.

A couple of years ago, this topic got a bit of discussion on the #link("https://discourse.gohugo.io/t/how-can-i-introduce-a-new-markup-language-typst-for-hugo/44848")[Hugo forum]. This was before Typst could natively export HTML, however, so it would have had to be done via `pandoc` or some other third-party tool --- it makes much more sense now Typst can render its' own HTML.

Conveniently Hugo's codebase is pretty pluggable when it comes to markup formats, it's not wedded to Markdown. Hugo also has support for Asciidoc, pandoc, and reStructuredText/RST, among others.
The `pandoc` support uses pandoc as as an "external renderer", where Hugo just shells out to the system `pandoc` binary generate the HTML --- this is pretty much exactly what I want. I asked GitHub Copilot to have a go and it did quite a good job, I had #link("https://github.com/gohugoio/hugo/compare/master...GeorgeHoneywood:hugo:typst")[something working] after only a couple of iterations.

This gives a pretty ideal experience for me. Live reload works properly, and all I have to do to write posts in Typst is create files with a `.typ` extension instead of `.md`!

{{< video path="demo-1276x720.mp4" muted="true" loop="true" >}}

You can do magical Typst stuff like equations:

```typst
$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $
```
Which renders to this:

$ sum_(k=0)^n k
  &= 1 + ... + n \
  &= (n(n+1)) / 2 $

(Don't ask me what this means, I just copied it #link("https://typst.app/docs/reference/math/")[from the docs]!)

Emojis and icons are super easy #emoji.cat, just use `#emoji.cat` #emoji.explosion\
Because it's a proper programming language, you can do loops! This source generates a list:

```typst
#for i in range(3){
  i += 1
  [- Loop #{i}, #{i == 2}, #lower(lorem(i))]
}
```
#for i in range(3){
  i += 1
  [- Loop #{i}, #{i == 2}, #lower(lorem(i))]
}

Because Typst is just generating HTML, the CSS styling works as it normally would on your site.

There are, as always, some sticking points:

- If you want to render into PDF with the normal Typst CLI (`typst compile foo.typ`), Hugo's shortcodes are a bit problematic. In Hugo, you can use the `{{</* relref "typst-and-hugo" */>}}` shortcode to link to other pages, which renders to #sym.arrow.r `{{< relref "typst-and-hugo" >}}`. While being perfectly well understood by Hugo,  these shortcodes are not well formed Typst code, so the Typst compiler will barf when it finds them.\
  I suspect you could get Hugo to just handle the first step of rendering the shortcodes, then dumping this mostly still Typst code to a file. This technique would work for simple things like the `relref` example, where all you get back is text, but wouldn't work for things like images, where the shortcode generates a bunch of HTML that Typst definitely can't understand!
- Adjacent to the previous point, with Hugo you add post metadata in a front meta section of the document, delimited with `---` characters. Typst doesn't mind these characters, but you'll want to strip them somehow if you want to render to PDF as well as HTML, otherwise the raw YAML metadata will show up in your PDF.
- General pain from using a fork of Hugo, it broke my CI. The GitHub Action I had set up to automatically build the site unsurprisingly doesn't know to use my Hugo fork to build things (and it's not super trivial to make it use some custom binary).
- Of course: it doesn't generate HTML in the same way as Hugo's Markdown renderer! This means if your CSS makes some assumptions about how the HTML structured, you'll need to make changes. Expect footnotes and code blocks to behave differently.
- Performance: the Typst compiler is pretty fast, but there is inevitable overhead for rendering via an external process. Once you've got hundreds or thousands of pages, I think this setup will crawl!

To give it a try yourself, you'll need to build #link("https://github.com/GeorgeHoneywood/hugo/tree/typst")[my Hugo fork] from source. I think something like this will work, once you've cloned the repo:

+ Switch to the `typst` branch
+ Build with `CGO_ENABLED=1 go build` (add `-tags extended` if you need it). You'll need a pretty modern Go toolchain, at least `v1.24`
+ Use the built `hugo` binary to generate your site. You can either add it to `$PATH`, or just use an explicit path to the binary, `path/to/clone/of/hugo/hugo`
+ Then make some pages with `.typ` extensions, and Hugo will use the Typst renderer 

Full disclosure: I am not planning on maintaining this fork, but the patchset is pretty mimimal, so should be easy enough to keep up to date with upstream.
For those curious, you can have a look at the source for this post #link("https://raw.githubusercontent.com/GeorgeHoneywood/george.honeywood.org.uk/master/content/blog/typst-and-hugo-properly/index.typ")[here].
