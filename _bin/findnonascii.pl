#!perl
use warnings;
use strict;
use v5.14;

# Searches the file 'author-index.html' and alerts with non-ascii characters,
# along with the line number where they are.

open my $fh, "<:utf8", "author-index.html" or die "can't open file: $!";
binmode(STDOUT, ":utf8");

while (<$fh>) {
    chomp;
    my @hits = m/([^A-Za-z0-9<> \-=."\/:(),])/g;
    if (@hits) {
        say "$.:\t@hits";
    }
}
