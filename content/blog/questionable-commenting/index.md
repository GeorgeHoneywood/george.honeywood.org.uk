---
title: "Questionable Commenting"
date: 2022-01-08T14:50:12Z
draft: true
description: "A weird way to comment"
keywords: ["development", "comments", "go", "golang"]
tags: ["development", "projects"]
math: false
toc: false
comments: true
---

I've had this idea in my head for a while about how it would be cool if there was a commenting system based around emails. It would be fairly inconvenient and impractical -- which goes to explain why I've never seen it before. So I decided to try it out.

Before I started working on anything properly I decided to first see how it could be integrated with [Hugo](https://gohugo.io/), the static site generator I'm using. Browsing the docs I found [data driven templates](https://gohugo.io/templates/data-templates/), which are basically a way of storing some arbitrary structured data in a file, and using that to render out a page. I think this makes the most sense with an example, so below is an example of one of the data files.

```json
[
  {
    "to": "comments@honeyfox.uk",
    "from": "george@honeyfox.uk",
    "from_name": "George Honeywood",
    "subject": "Comment: questionable-commenting",
    "post": "questionable-commenting",
    "message_id": "cmu-lmtpd-3808603-1641656191-0@sloti47n17",
    "body": "test comment testing",
    "timestamp": "2022-01-02T11:23:21Z"
  },
  {...}
]
```
 
I then have a partial that loops over the comments and renders them out. You can get Hugo to do some magic; loading a structure containing the data in a file. Using [page bundles](https://gohugo.io/content-management/page-bundles/), means you don't need to worry about associating comments files to posts, as you can just have each bundle contain its own `comments.json` file.

```go-html-template
{{ $comments := .Resources.GetMatch "comments.json" | default "{}" | transform.Unmarshal }}

{{ range $comments }}
  <div class="comment">
    <div class="comment__author">
      <span class="comment__author-name">
        {{ with .from_name }} {{ . }} {{ else }} anon {{ end }}
      </span>
      <span class="commment__author-wrote">wrote at</span>
      <span class="comment__author-date">
        <time datetime="{{ .timestamp }}">
        {{ .timestamp | time.Format $.Site.Params.dateFormat }} 
        </time>
      </span>
    </div>
    <div class="comment__body">
      {{ .body | htmlEscape | markdownify }}
    </div>
  </div>
{{ else }}
  <p>No comments yet.</p> 
{{ end }}
```

The `transform.Unmarshal` is the important part of this snippet, taking the JSON array and turning it into something that `range` can iterate over. The pipe through `default "{}"` is just a way of making sure that if the `comments.json` file doesn't exist, the JSON is parsed as an empty object[^1] -- this means I can just have a single `{{ else }}<p>No comments</p>{{ end }}` clause.

[^1]: For some reason `default "[]"` doesn't work, even though `[]` should be valid JSON. Looking at [the source](https://github.com/gohugoio/hugo/blob/44954497bcb2d6d589b9340a43323663061c7b42/parser/metadecoders/format.go#L77) it looks like it guesses the JSON format from the presence of a `{`.

{{< image path="comments" alt="The comments section you should be able to see below :)" >}}

With a sprinkling of SCSS we now have something that at least looks like a comment section. Now all we need to do is transport some emails into these JSON files and we're good to go!

To this end I made a little Go program that connects to my email provider over IMAP, and IDLEs waiting for new emails to arrive. When one comes in to the correct address, it checks if the subject matches up to a post, and if it does, it adds the comment to the page bundle JSON file. This should be pretty straightforward, but [`go-imap`](http://github.com/emersion/go-imap) is a bit of a pain to work with. Below is most of the code that waits for new emails to arrive in the inbox.

```go {hl_lines=["27-29"],linenostart=17}
for {
  // Create a channel to receive mailbox updates
  // need to recreate the updates channel for some reason each loop
  updates := make(chan client.Update, 1)
  a.c.Updates = updates

  stop := make(chan struct{})
  done := make(chan error, 1)
  go func() {
    done <- a.c.Idle(stop, nil)
  }()

WAIT:
  log.Println("waiting for updates")
  select {
  case update := <-updates:
    log.Println("update received:", update)

    mailboxUpdate, ok := update.(*client.MailboxUpdate)
    if !ok {
      log.Println("not a mailbox update, skipping")
      goto WAIT
    }

    log.Println("mailbox update received:", mailboxUpdate)

    close(stop)
    <-done
    log.Println("finished idling")

    a.fetchMessages(mailboxUpdate.Mailbox.Messages, nil, nil)
  case err := <-done:
    if err != nil {
      log.Println("something went wrong whilst idling; restarting:", err)
    }
    log.Println("not idling anymore")
    return
  }
}
```

The main thing that I'd complain about is that after you receive an update through your IDLE channel, you cannot actually go and fetch the message until you've closed the IDLE client[^2]. This means you have to do a dance with stopping and starting the IDLE each time an update comes in. You must also make sure to recreate the updates channel, or it will silently fail to fetch the mail.

[^2]: To be fair this is presumably one of IMAPs many limitations, so maybe `go-imap` is not to blame. I'm still unsure why IDLEing means you are only told *something* happened, instead of it including the actual message(s) that arrived.

I decided that it was best to have the comments committed to the Git repository. This means that whenever a comment is added, my GitHub action will run, and it will be rendered into the site by Hugo. The downside is that these comments being committed will clog up the repo history, and I'm not really sure it makes sense to store them alongside the actual posts.

Hugo can also load data over HTTP, so I could reasonably have this program run a HTTP server, and just fetch the comments from it whenever is needed -- but this would mean I'd need some external solution for rebuilding the site on new comments.

To make the system a little more usable, I also decided to add some extra functionality to the server -- it will reply to your emails with a confirmation message if everything went okay; or an error if everything is on fire.
