---
title: "Typst + Hugo"
date: 2025-10-27T18:16:01Z
draft: false
description: "Embedding Typst HTML output into Hugo site"
keywords: ["typst", "hugo", "static site generator"]
tags: ["typst", "projects"]
math: false
toc: false
comments: true
---

One slightly vain thing that I've wanted to do for a while is have my CV available in both PDF and HTML form, without the hassle of keeping two different versions in sync.
On the face of it, this sounds pretty trivial, just write in Markdown, then use Pandoc to export to both formats.\
If only I didn't care about styling!

Fortunately for me, [Typst]({{< relref "typst" >}}) (the typesetting system I use for my CV), recently [gained the ability to output HTML](https://typst.app/docs/reference/html/).
It generates unstyled, semantic HTML, which is exactly what you want for embedding it into an existing website.

I've updated my CV template [Alta Typst](https://github.com/GeorgeHoneywood/alta-typst) to use this new feature. The bulk of the work was adding conditionals, for when you want to control exactly how the HTML is structured. Where before I had this tiny one line function:

```plain
#let term(period, location) = {
  text(9pt)[#icon("calendar") #period #h(1fr) #icon("location") #location]
}
```

I now have this 20 line monstrosity:

```plain
#let term(period, location) = context {
  // PDF == paged
  if target() == "paged" { 
    text(9pt, {
      icon("calendar")
      period
      h(1fr)
      icon("location")
      location
    })
  } else {
    html.div(
      style: "display: flex; align-items: center; gap: 10px;",
      {
        icon("calendar")
        html.div(period)
        icon("location")
        html.div(location)
      },
    )
  }
}
```

Admittedly, you could make this a lot smaller, but this is what the formatter wants! This will give you HTML output that lays out fairly similar to the PDF, thanks to the inline style.

{{< image
	path="html-vs-pdf"
	alt="Comparison of Typst rendered to HTML (top) and PDF (bottom)"
	caption="Above is HTML output, below is PDF output"
>}}

The magical part is the icons, these are embedded as SVG directly in the HTML doc -- it's not particularly efficient when you've got the same icon reused a few times, but it sure is easy! This also works for maths, it just gets directly embedded as SVG.

There are only a couple of primitives:

* Insert specific HTML elements using e.g. `html.div()` or `html.span()`, and add any attributes as desired.
* Render Typst content direct to SVG, with `html.frame()`. This is useful for icons, diagrams, and maths, things that don't directly correspond to HTML. 

Hugo (the static site generator used for this blog), can plonk the Typst generated HTML inside the site base template, so it inherits the usual styling and navigation.

I'm definitely not a Hugo expert, but the following seems to work for embedding a single Typst page.\
I added the new page to the main menu in `config.toml`:

```toml
# config.toml

[[menu.main]]
  identifier = "cv"
  name = "CV"
  title = "CV"
  url = "/cv/"

# hack to make hugo rebuild when the CV changes
# still need to refresh the page manually, live-reload doesn't work
[module]
  [[module.mounts]]
    source = "cv/georgehoneywood-cv.html"
    target = "assets/georgehoneywood-cv.html"

  [[module.mounts]]
    source = 'assets'
    target = 'assets'
```

In parallel, I run Typst exporting to HTML from the `cv` folder:

```bash
~/george.honeywood.org.uk/cv
> typst watch --format html --features html georgehoneywood-cv.typ
```

Template for the `/cv/` page:

```plain
<!-- layouts/page/cv.html -->

<!-- pick up styling from scss/pages/cv.scss -->
{{ define "styles" }}
    {{ $.Scratch.Set "style_opts" (dict "src" "scss/pages/cv.scss" "dest" "css/cv.css") }}
{{ end }}

<!-- wrap in base template -->
{{ define "main" }}
{{ $file := resources.Get "georgehoneywood-cv.html" }}
{{ $file = $file.Content }}

<!-- strip out typst HTML boilerplate, we just need raw body -->
{{ $file = index (strings.Split $file "<body>\n    <div>\n      ") 1 }}
{{ $file = index (strings.Split $file "</div>\n  </body>") 0 }}

<div class="flex-wrapper">
    <div class="post__container">
        <div class="post">
            <article class="post__content">
                <!-- print out the CV content -->
                {{ $file | safeHTML}}
                {{ partial "anchored-headings.html" .Content }}
            </article>
            <footer class="post__footer">
                {{ partial "social-icons.html" .}}
                <p>{{ replace .Site.Copyright "{year}" now.Year | safeHTML}}</p>
            </footer>
        </div>
    </div>
</div>
{{ end }}
```

As Typst outputs a standalone HTML document, including `<head>` and `<body>`, you need to strip these out if you want to embed the output in a template.
You'll also need some boilerplate content file:

```markdown
# content/cv.md
---
layout: cv
title: CV
---
```

In the aforementioned CSS file, the only clever thing is inverting the colour of the Typst `html.frame()` SVG elements when the browser is set to dark mode.

```css
/* scss/pages/cv.scss */

@media (prefers-color-scheme: dark) {
    .typst-frame {
        filter: invert(1);
    }
}
```

Go forth and [view the HTML result!]({{< relref "cv" >}}) (cf. the original [PDF version](/georgehoneywood-cv.pdf)). This is generated from [this Typst source](https://github.com/GeorgeHoneywood/george.honeywood.org.uk/blob/master/cv/georgehoneywood-cv.typ), using my [Alta Typst template](https://github.com/GeorgeHoneywood/alta-typst/blob/master/alta-typst.typ).

I'm reasonably pleased with how it looks. While this setup works well enough for one-off pages, it doesn't really scale to writing individual posts in Typst. I think you could hack something together with page resources and a shortcode to handle that case.
