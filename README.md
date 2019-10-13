# SMT Mobile Conference site

Visit the site online at https://guide.societymusictheory.org.

This is a repository for a conference webpage for the Society for Music Theory
annual meeting.

For details, issues, comments, or questions, contact the SMT webmaster at
webmaster@societymusictheory.org. For technical issues (if you want to work on
the site itself), contact Michael McClimon (michael@mcclimon.org).

## So you want to work on the website

Great. You're already a hero in my book. You will need a few things:

1. Some knowledge of HTML and CSS. (There is a very small amount of JavaScript
   here, but it's all very straightforward and probably you won't need to
   think about it too much.)
1. A rudimentary understanding of [git](https://git-scm.com/). Git is a
   version control system, and we use it to manage the source for
   the website. A search for "introduction to git" turns up plenty of
   resources.
1. A working copy of [Jekyll](https://jekyllrb.com/docs/step-by-step/01-setup/).
   This isn't _strictly_ necessary, but it will let you run the site locally,
   which is much faster and less error-prone than making changes locally and
   having to upload them to the real site to check.
1. A text editor. (That is, one that edits plain text, not a word processor.)
   You probably have one of these on your computer already (Notepad on Windows
   or TextEdit on Mac), but you'll be happier if you download one for
   programmers, which have way more features. Searching for "best free
   programming text editor" will find a bunch; any of them are fine.


## High-level Overview

This site is written in [Jekyll](//jekyllrb.com), and hosted with [GitHub
Pages](https://pages.github.com/). This is so that it's dead simple to write and
update, without having to SSH around to a bunch of different places or needing
to copy files in and out. All you need to do is `git push` and the website is
updated automatically.

Over the years, we have developed a system which is pretty flexible, and should
be reasonably easy to maintain. It _does_ mean that some of the implementation
is kind of icky (there are some...interesting things done with Jekyll
templates), but that's all in service of making the rest nice and simple.

### File structure

Here's what's what in the root of the repository:

- `_bin/`: This folder has a bunch of little programs I (Michael) have used to
  automate parts of building the site in the past. They're all in Perl, which is
  my native programming language, and while you could run them if you got a
  Perl environment set up, you can probably just ignore them.
- `_data/`: Important! This is where most of the actual _content_ of the site is.
  (That is: information about individual papers and sessions.) More about this later.
- `_includes/`: These are all HTML fragments used to generate parts of the pages.
  Some of these are fairly complex, but we'll get to that later.
- `_layouts/`: More Jekyll framework stuff. All of our pages use either the
  "page" or "session" layouts.
- `_sass/`: CSS files, which are all included in the main file, which is
  `css/main.scss`. (These are all [Sass](https://sass-lang.com/) files.)
- `css/`: This is where the CSS files live.
- `ics/`: This is where the calendar resources live. There's one for each
  session. More on this later.
- `img/`: Images (served directly). Easy peasy.
- `js/`: JavaScript files (served directly)
- Other random .html and .md files: these are all pages that live at the root of
  the site. Jekyll turns them into HTML files. (For example: maps.md winds up at
  https://guide.societymusictheory.org/maps).
- `sessions/`: This is the other important content directory, served by Jekyll.
  More on it later.
- `_config.yml`: Jekyll's configuration file. There's some low-level
  configuration here, but the most important thing is the title of the site,
  which you'll need to update for every year.
- `CNAME`: This is necessary to tell GitHub Pages that the site is actually
  being served from guide.societymusictheory.org, rather than
  societymusictheory.github.io.
- `Gemfile`: This is a file used by Ruby (the programming language Jekyll is
  written in) that's necessary for GitHub pages
- `Gemfile.lock`: The same, but slightly different for reasons that aren't important.
- `README.md`: This file! Congratulations, you're already reading it.
- `index.html`: The home page!
- `favicon.ico`: The favicon.

## The sessions directory

The sessions directory (which I'll type out with no leading underscore because
Markdown gets very confused) is served directly by Jekyll. There are subfolders
for each day, and then for each chunk of time therein (morning, afternoon,
evening). Any HTML or Markdown files you stick in here will be turned into real
files by Jekyll. By convention, there are usually morningMeetings.html,
noontime.html, and eveningMeetings.html in a day directory.

Inside of a time-chunk directory (e.g., sessions/fri), there is an HTML page for
every sesion, plus two other files: index.md and index-short.md. (Index is the
main page for each session, and index-short is the title-only version of it.)

### sessions/day/time/index.md

Here's the index page for a session:

```markdown
---
layout: default
title: Friday Afternoon Sessions
---

# Friday Afternoon Sessions

[View session titles only](index-short)

## 2:15--5:15

{% include session-short.html session="diversity-theory-pedagogy" %}

## 2:15--3:45

{% include session-short.html session="listening-seeing-moving" %}
{% include session-short.html session="improvising-thoroughbass-partimenti" %}
{% include session-short.html session="composing-in-paris" %}
```

The stuff between `---` lines at the beginning is called the "front matter", and
it just gives the title for the page and tells it what layout to use. The rest
of it is just Markdown.

The interesting part, of course, is the `{% include session-short.html
session="session-name" %}`. This is where the templating stuff comes into play:
include is a templating directive that tells Jekyll to go and get the content
from `_includes/session-short.html`, and to pass the text "session-name" into
its `session` variable. If you look at that template file, you'll see that it
uses the `session` variable (named there as `include.session`) to pull out the
session with that name from `site.data.sessions`. (Again, more on this in a
bit.) It then uses the data it finds there to generate a hunk of HTML for that
session. index-short.html is basically exactly the same, but the HTML hunks in
generates are, well, shorter.

Sometimes, you'll need to include things on a session index that's not really
supported by the templates. That's ok! They're just HTML files; put whatever you
want in there.

### sessions/day/time/session.md

The other important files here are the ones for the actual sesions. Here's an
example of one of those:

```
---
title: "Cross-Modal Perception in Multimedia and Virtual Reality"
slug: cross-modal-perception
layout: session
---

{% include session_title.html %}
{% include paper_titles.html %}

--<h2>Abstracts</h2>
{% include paper_abstracts.html %}
```

Again, we see the front matter: it has a title, the layout, and (importantly) a
thing called "slug", which must match the session in the data/ directory (I
promise I'm getting around to that). Again, it's mostly includes; each of those
includes pulls out the data it needs (based on the slug), and generates all the
necessary HTML. Feel free to have a look at those templates.

As with the index pages, you'll sometimes need to include things on a session
index that's not really supported by the templates. It's slightly more common
with sessions, because there might be (for example) some extra text in the
program book, especially for special or sponsored sessions, etc. Again, they're
just HTML files, so just include whatever you need.

## The data directory

By far the most important directory here is `_data` (which I'll type without the
leading underscore because Markdown gets confused). It has two subdirectories:
one for sessions, one for papers.