#!perl
use warnings;
use strict;
use v5.14;

# This file runs through a list of authors and prints any duplicates on STDOUT.

open my $in, "<", "sortedAuthors.html" or die "can't open file: $!";

my $lookingAt = "";

while (<$in>) {
    my ($auth) = /<a.*?>(.*?)</;
    next unless $auth;
    say "found dupe: $auth" if ($auth eq $lookingAt);
    $lookingAt = $auth;
}
