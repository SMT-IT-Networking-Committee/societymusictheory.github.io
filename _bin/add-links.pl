#!perl
use v5.24;
use warnings;
use Path::Tiny qw(path);
use YAML ();
use Data::Dumper::Concise;
use experimental qw(signatures);
use utf8;

# Read YAML sessions

my %days = (
  Thursday => 'thu',
  Friday   => 'fri',
  Saturday => 'sat',
  Sunday   => 'sun',
);

sub compute_time ($s) {
  my @words = split /[ ,]/, $s;
  my $out = "" . $days{ $words[0] } . "/" . $words[1];
  return $out;
}

my $session_dir = path('_data/sessions');
my %papers;

for my $f ($session_dir->children) {
  next unless $f =~ /yml$/;

  my $slug;

  $f->edit_lines(sub {
    my $l = $_;
    chomp $l;

    if ($l =~ /^slug:/) {
      ($slug) = $l =~ /^slug:\s*(.*)/;
    }

    if (my ($time) = $l =~ /^time: ['"](.*)['"]/) {
      my $link = compute_time($time);
      $_ = "$l\nlink: /sessions/$link/$slug\n";
    }
  });
}
