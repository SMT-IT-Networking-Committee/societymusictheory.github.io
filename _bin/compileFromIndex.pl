#!/usr/bin/env perl
use warnings;
use strict;
use v5.14;

use File::Basename;   # (in core)


# pass the index.md file as an argument
unless (@ARGV) {
    say STDERR "No index file given to parse.";
    say STDERR "Usage:";
    say STDERR "    $0 [session folder]/index.md";
    exit 1;
}

# Setup ----------------------------------------------------------------
my $index = shift @ARGV;
my ($basename, $dirname) = fileparse($index);

chdir($dirname);                # so relative links work correctly
binmode(STDOUT, "utf8");        # so special characters get output correctly


# Main loop ------------------------------------------------------------
#
# Here, we pares the index.md file. That way, the complete listing looks
# just like the index file, only with more information. This works
# better than parsing all of the files individually.

open my $in, "<:utf8", $basename or die "Can't open $index: $!";
open my $out, ">:utf8", "complete.html" or die "Can't open outfile: $!";

while (<$in>) {

    # output page title
    if (/^# /) {
        my ($head) = /# (.*)/;
        printHeader($head);
    }

    # output subheading for session block
    if (/^## /) {
        my ($timeHead) = /## (.*)/;
        say $out qq{<h2>$timeHead</h2>\n};
    }

    # process individual sessions
    if (/^- /) {
        my ($title, $link, $roomSpan) =
          m{^-\s+            # dash plus space
            \[(.*?)\]        # $1: title, any text inside square brackets
            \((.*?\.html)\)  # $2: href, a link inside parens
            \s+              # some space
            (<span.*/span>)  # $3 a room <span> tag
           }x;
        processFile($title, $link, $roomSpan);
    }
}


# Print the file header, including all the YAML nonsense.
sub printHeader {
    my $title = shift;
    say $out qq{---};
    say $out qq{layout: default};
    say $out qq{title: $title};
    say $out qq{---};
    say $out qq{};
    say $out qq{<h1>$title</h1>};
    say $out qq{};
}


# Parse an individual session file.
#
# For this, we run through the whole file, looking for <p> tags with
# "author" and "title" classes. Once we've looked at the file, output a
# <ul> with all of that information.
#
# Note that this doesn't work for panel discussions (since there are no
# <p class="author"> tags), but there are few enough of those that we
# can deal with them manually.
sub processFile {
    my ($sessionTitle, $link, $roomSpan) = @_;

    # print session heading
    say $out qq{<h3><a href="$link">$sessionTitle</a> $roomSpan</h3>};

    open my $fh, "<:utf8", $link or die "Can't open $link: $!";

    my @lis;
    my ($auth, $title);

    while (<$fh>) {
        if (/<p class="author">/) {
            ($auth) = m{<p.*?>(.*)</p>};
            $auth =~ s/\s+\(.*?\)//;      # delete affiliations
        }

        if (/<p class="title">/) {
            ($title) = m{<p.*?>(.*)</p>};
        }

        if ($auth && $title) {
            push @lis, qq{<li>$auth, <span class="title">$title</span></li>};
            $auth = $title = undef;
        }

        if (/^<h2>Abstracts/) {
            say STDERR "no papers found: $link" unless (@lis);

            say $out qq{<ul class="paper-list">};
            say $out "  $_" for @lis;
            say $out "</ul>\n";
            last;
        }
    }
}
