---
title: "Typst"
date: 2024-02-18T10:34:22Z
draft: true
description: "Document preparation with Typst"
keywords: ["typst", "latex"]
tags: ["thoughts"]
math: false
toc: false
comments: true
---

Typst is pretty much what I was looking for since I was about 15, and had to write my first long form report for school. I didn't like using Word I spent too much time fighting the formatting, and I couldn't easily run it on my PC at home.

At the time the answer to that was LaTeX. LaTeX is pretty cool. You just write whatever you want, then let it produce a pretty document for you. Unfortunately, the UX is not really up to modern standards. To compile a document with a bibliography you have to run a byzantine incantation of commands, such as [`pdflatex` -> `biber` -> `pdflatex` -> `pdflatex`](https://tex.stackexchange.com/a/204298) (or you can use `latexmk` which handles this stuff for you). 

You best pray that you don't want to change any formatting other than perhaps the margins and the font. Everything is handled through a macro based language that feels exactly like it was released in 1978. It's not hard to install, but it does eat a lot of space (the equivalent of about 20 electron apps!):

```bash
➜ du -sh /usr/share/tex{live,mf}
2.9G	/usr/share/texlive
408M	/usr/share/texmf
```

For a system from the 1970s it is also weirdly slow. Once your document grows to have a decent number of embedded figures everything takes a while. You can workaround this, but it feels like it should just work. From scratch, compiling the [Final Year Project report](https://github.com/GeorgeHoneywood/final-year-project/files/11584765/george-honeywood-final-report.pdf) I wrote for uni took a solid 23 seconds, and it isn't even that large of a document, only about 50 pages and 13 figures. Subsequent compiles are a bit quicker, taking about 5 seconds, but that is still quite far from ideal. 

```bash 
➜ time latexmk -pdf -silent main.tex 
Latexmk: Run number 1 of rule 'pdflatex'
Latexmk: Run number 1 of rule 'biber main'
Latexmk: Run number 2 of rule 'pdflatex'
Latexmk: Run number 3 of rule 'pdflatex'
Latexmk: Run number 4 of rule 'pdflatex'

real    0m23.588s

➜ time latexmk -pdf -silent main.tex
Latexmk: Run number 1 of rule 'pdflatex'

real    0m5.509s
```

LaTeX's markup also seems quite archaic to me. Most people are used to Markdown syntax, so any similarity to that will ease the learning curve. Here is how you'd create the eqivalent of a `<h4>` and include an image. It is fine once you get used to it, but that can take a while.

```latex
\subsubsection{Sub-files}

\begin{figure}[ht]
    \centering
    \includegraphics[width=0.8\textwidth]{../proof-of-concepts/4-rendering-osm-data/screenshots/high-detail-at-low-zoom.png}
    \caption{Raw tiled data from zoom 14 base tiles}\label{fig:rendering-tiles}
\end{figure}

Sub-files store map data for a range of zoom levels. For example, [-snip-]
```

Now I've established the motivation, I can extole the virtues of Typst. Typst was released fairly recently, and is a fresh take on document preparation. It combines the good bits of LaTeX, but with much faster compiles and a smaller learning curve. Here's how you'd do the same in Typst:

```plain
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
