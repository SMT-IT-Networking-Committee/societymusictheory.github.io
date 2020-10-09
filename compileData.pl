#!/usr/bin/env perl
use warnings;
use strict;
use v5.14;

# This script requires the JSON module, installable from CPAN.
use File::Find;
use File::Basename;
use JSON;

# Data structure for later, looks like this:
# { filename.html =>
#      title => "Session title"
#      session => "Thursday afternoon" (or the like)
#      time => "3:30--5:00"  (or similar)
#      path => /_sessions/thu/afternoon/filename.html
# }
my %data;

# Find all of the 'index.md' files, process them, then output to JSON.
my $dir = shift @ARGV || ".";
find({wanted => \&wanted, no_chdir => 1}, ($dir));
storeIt();


# Step 1: find the index pages
sub wanted {
    if (/index[.]md$/) {
        process_index($_);
    }
}

# Step 2: Parse the index file, and
# Step 3: Store it in %data
sub process_index {
    my $path = shift;
    my $dir = dirname($path) =~ s|^\./||r;

    my $session = prettySession($dir);

    open my $fh, "<:utf8", $path or die "can't open $path: $!";

    my $time;

    while (<$fh>) {
        # keep track of the current session times
        if (/^### /) {
            ($time) = /^### .*, (.*?)$/;
        }

        if (/^- /) {
            my ($title, $link, $roomSpan) =
              m{^-\s+            # dash plus space
                \[(.*?)\]        # $1: title, any text inside square brackets
                \((.*?\.html)\)  # $2: href, a link inside parens
                \s+              # some space
                (<span.*/span>)  # $3 a room <span> tag
               }x;

            $data{$link} = {
                title => $title,
                path  => "/$dir/$link",
                session => $session,
                time => $time,
                room => $roomSpan,
            };
        }
    }

}

sub prettySession {
    my $dir = shift;

    my ($day, $block) = $dir =~ m|_sessions/(\w{3})/(.*)|;

    my %days = (
        nov7 => "November 7",
        nov8 => "November 8",
        nov14 => "November 14",
        nov15 => "November 15",
    );

    return $days{$day} . " " . (ucfirst($block));
}

# Step 4: Store it
sub storeIt {
    my $json = to_json(\%data, {pretty => 1, utf8 => 1});
    say $json;
}
