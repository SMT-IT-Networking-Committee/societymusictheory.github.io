# `_bin` Folder

This is a folder for the Perl scripts used to hack together from the Word
document. It is not guaranteed that they will work similarly in the future,
but I wanted to preserve them for posterity.

## Some notes

The initial conversion from Word file to HTML was done using
[Pandoc](http://pandoc.org/), which is absolutely wonderful. I then cleaned
the raw HTML output up a bit, saving it one file called `sessions.html`
(containing just the session listings, from the first part of the program
book), and another containing everything, including abstracts.

All of these are done in Perl, which is my favorite language for doing text
hacking. Sorry (but not really) to the Perl haters. All of these need Perl
v5.14 or later, for the indispensable `/r` flag to `s///`.

## Program descriptions

### addSessionInfo.pl

This was used to add the `<p class="sessionInfo">` line to every session file.
It reads the sessionData JSON and edits all of the individual session files in
a batch.


### compileData.pl

This parses all of the `index.md` pages and generates a JSON file (on STDOUT).
This was used to generate the [sessionData.json](../js/sessionData.json) file.

### compileFromIndex.pl

This is my favorite of these: it takes an `index.md` file from a session page
and generates the `complete.html` page for that session. For example, the
invocation
```
perl _bin/compileFromIndex.pl _sessions/thu/afternoon/index.md
```
would generate the file `_sessions/thu/afternoon/complete.md`, with links and
everything as appropriate. Ta-da!

### findDupes.pl

This was used to find duplicate authors in the generated authors list.
I grepped the entire directory for `<p class="author">` and dumped those into
a file, then stripped the `<p>` tags and added `<a>` tags with links to the
files where they came from. After sorting (see below), this got dumped into
`sortedAuthors.txt`, which this file runs through, alerting about any
duplicates on STDOUT.

### findnonascii.pl

To make the JavaScript author filtering work reasonably, I needed to know
which non-ASCII characters there were in the input. This script finds them and
prints them out, along with the line number of the input where they were found.


### gensessions.pl

This is probably the least useful for the future, since it's fairly dependent
on the structure of the generated Word document. Nevertheless, it might be
useful so I'm putting it here. This file takes the generated document
(sessions.html) and puts out a bunch of `index.md` files. It's
useful, if nothing else, for generating link names (slugs) from session titles.

### parsesessions.pl

Again, probably not useful in the future, but maybe. This parses the
sessions.html file and pukes out a whole bunch of files: one for each
individual session. This is a little error prone (and sometimes break things
in weird ways), but in any case is easier than starting from scratch and
pasting things directly from a Word file.

### sortAuthors.pl

This file takes a list of authors (inside <a> tags) and sorts them
alphabetically by last name. It doesn't work for non-ASCII characters (see
above), but it's close enough, and there are few enough of them that it's not
too hard to move them manually.
