---
title: "Typst"
date: 2024-02-18T10:34:22Z
draft: false
description: "Document preparation with Typst"
keywords: ["typst", "latex"]
tags: ["thoughts", "typst"]
math: false
toc: false
comments: true
---

Typst is pretty much what I have been looking for since I was about 15 and had to write my first long form report for school. I didn't like using Word; I spent too much time fighting the formatting and I couldn't easily run it on my PC at home. At the same time, I needed a bit more control over layout than what I could easily get using Markdown and pandoc.

{{< image path="typst" alt="My CV, prepared using Typst" caption="An example of a document prepared using Typst, my CV" lazy=false >}}

At the time the solution I settled upon was LaTeX. LaTeX is pretty cool. You write whatever you want, then let it produce a pretty document for you. Unfortunately, the UX is not really up to modern standards. To compile a document with a bibliography you have to run a byzantine incantation of commands, such as [`pdflatex` -> `biber` -> `pdflatex` -> `pdflatex`](https://tex.stackexchange.com/a/204298) (or you can use `latexmk` which handles this stuff for you). It's not hard to install, but it does eat a lot of space (the equivalent of about 20 electron apps!):

```bash
$ du -sh /usr/share/tex{live,mf}
2.9G	/usr/share/texlive
408M	/usr/share/texmf
```
I initially avoided some of this complexity by using ShareLaTeX [^1], a web based LaTeX editor. Whether you use a local install or an online editor, you are still stuck with the underlying language. You better pray that you don't want to change any formatting other than the margins or something that there is not an existing package for. TeX is macro based, and feels exactly like it was released in 1978, with pretty poor tooling to match.

[^1]: ShareLaTeX has since been bought out by Overleaf, the other big player in the online LaTeX space. In a slightly unusual move, Overleaf then replaced their own editor with better one of ShareLaTeX.

For context, have fun trying to figure out what output [this macro](https://github.com/liantze/AltaCV/blob/74bc05df383c08ceacfcc6d438c1aa2b207cd1dc/altacv.cls#L328-L337) would produce:

```latex
\newcommand{\cvskill}[2]{%
  \textcolor{emphasis}{\textbf{#1}}\hfill
  \BeginAccSupp{method=plain,ActualText={#2}}
  \foreach \x in {1,...,5}{%
    \ifdimequal{\x pt - #2 pt}{0.5pt}%
    {\clipbox*{0pt -0.25ex {.5\width} {\totalheight}}{\color{accent}\cvRatingMarker}%
     \clipbox*{{.5\width} -0.25ex {\width} {\totalheight}}{\color{body!30}\cvRatingMarker}}
    {\ifdimgreater{\x bp}{#2 bp}{\color{body!30}}{\color{accent}}\cvRatingMarker}%
  }\EndAccSupp{}\par%
}
```

You'd think a system from the 1970s would be quick on modern computers. This is not the case. Once your document grows to have a decent number of embedded figures, everything takes a while. You can work around this, but it feels like it should just work. From scratch, compiling the [Final Year Project report](https://github.com/GeorgeHoneywood/final-year-project/files/11584765/george-honeywood-final-report.pdf) I wrote for uni took a solid 23 seconds, and it isn't even that large of a document, only about 50 pages and 13 figures. Subsequent compiles are a bit quicker, taking about 5 seconds, but that is still quite far from ideal.

```bash 
$ time latexmk -pdf -silent main.tex 
Latexmk: Run number 1 of rule 'pdflatex'
Latexmk: Run number 1 of rule 'biber main'
Latexmk: Run number 2 of rule 'pdflatex'
Latexmk: Run number 3 of rule 'pdflatex'
Latexmk: Run number 4 of rule 'pdflatex'

real    0m23.588s

$ time latexmk -pdf -silent main.tex
Latexmk: Run number 1 of rule 'pdflatex'

real    0m5.509s
```

LaTeX's markup also seems quite archaic to me. Most people are used to Markdown syntax, so any similarity to that will ease the learning curve. Here is how you'd create the equivalent of a `<h4>` and include an image. It is fine once you get used to it, but that can take a while.

```latex
\subsubsection{Sub-files}

\begin{figure}[ht]
    \centering
    \includegraphics[width=0.8\textwidth]{../proof-of-concepts/4-rendering-osm-data/screenshots/high-detail-at-low-zoom.png}
    \caption{Raw tiled data from zoom 14 base tiles}\label{fig:rendering-tiles}
\end{figure}

Sub-files store map data for a range of zoom levels. For example, [-snip-]
```

Now I've established the motivation, I can extol the virtues of Typst. Typst is a fresh take on document preparation. It combines the good bits of LaTeX, but with much faster compiles and a smaller learning curve. Here's how you'd do the same in Typst:

```typst
==== Sub-files

#figure(
  image(
    "../proof-of-concepts/4-rendering-osm-data/screenshots/high-detail-at-low-zoom.png",
    width: 80%,
  ),
  caption: [
    Raw tiled data from zoom 14 base tiles.
  ],
) <fig:rendering-tiles>

Sub-files store map data for a range of zoom levels. For example, [-snip-]
```

This syntax makes far more sense to me, as it is pretty standard C-like language. It has all the usual constructs like functions, variables, loops, conditionals, etc. In testament to this, I decided to rewrite my CV from LaTeX to Typst. I had been using the [AltaCV](https://github.com/liantze/AltaCV) class, and wanted to see how hard it would to recreate in Typst. It only took a few hours.

Here is a Typst recreation of the `\cvskill` TeX macro we saw before:

```typst
#let skill(name, rating) = {
  let max_rating = 5
  let i = 1

  name
  h(1fr)

  while (i <= max_rating){
    let colour = rgb("#c0c0c0") // grey

    if (i <= rating){
      colour = primary_colour
    }

    box(circle(
      radius: 4pt,
      fill: colour
    ))

    // add spacing on all but last
    if (i != max_rating){
      h(2pt)
    }

    i += 1
  }
  
  [\ ]
}

== Skills

Here are some of my skills!

#skill("Go", 5)
#skill("TypeScript", 3)
#skill("Git", 1)
#skill("Typst", 1)
```

{{< image path="skills" alt="List of skills, with name and rating" caption="Rendered output of the snippet above, calling the `skill()` function">}}

For some context, Typst mixes content and scripting together. While writing content, you can insert script, by prepending a `#`. While in the script context, i.e. inside the `skill()` function above, you no longer need to prepend `#` to functions, and can include arbitrary content inside `[` square brackets `]`.

Compilation is pretty much instant. Typst uses incremental compilation, enabled by a system of constrained memoization. The lack of delay between keypress and render is appreciated, but the technical details go way over my head.

I'd wholeheartedly recommend Typst to anyone who might be thinking of learning LaTeX, or wants a document preparation system that is comparable in simplicity to Markdown, but with the power to represent pretty much anything. I wish that it had been around 10 years ago for 15-year-sold me!

If you'd like to learn more about Typst, [their tutorial](https://typst.app/docs/tutorial/) is excellent.  
For a more detailed overview, see [Laurenz Mädje's master's dissertation](https://laurmaedje.github.io/programmable-markup-language-for-typesetting.pdf).
