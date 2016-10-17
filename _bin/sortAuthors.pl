#!perl
use v5.14;
use warnings;
use strict;

# This file takes a list of authors (inside <a> tags) and sorts them
# alphabetically by last name.

my $fn = shift or die "need filename to sort.";

open my $fh, "<", $fn or die "can't open file: $!";

# slurp file into memory
my @lines;
while (<$fh>) {
    chomp;
    push @lines, $_;
}

# Schwartzian transform, using function 'sortme' to do the sorting
my @sorted =
  map { $_->[0] }
  sort sortme
  map { [$_, (m/<a.*?>(.*?)</)[0] ] } @lines;

say for @sorted;


sub sortme {
    # n1 and n2 are just the names
    my $n1 = $a->[1];
    my $n2 = $b->[1];

    # Grab the last name (everything from the final space until the
    # end). I know this isn't *really* a last name, but it's close
    # enough for us. It also fails on nonAscii characters. I could fix
    # this by using Unicode properly, but there are few enough of them
    # that it's easier to move them manually.
    my ($last1) = lc ($n1 =~ m/(\S+)$/);
    my ($last2) = lc ($n2 =~ m/(\S+)$/);

    return $last1 cmp $last2;
}
