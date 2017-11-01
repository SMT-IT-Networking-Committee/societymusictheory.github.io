#!perl
use v5.24;
use warnings;
use Path::Tiny qw(path);
use YAML ();
use Data::Dumper::Concise;
use experimental qw(signatures);

# Read YAML sessions

my $session_dir = path('sessions');
my %papers;

for my $f ($session_dir->children) {
  next unless $f =~ /yml$/;

  my $yml = YAML::LoadFile( "$f" );

  my $time = compute_time($yml->{time});
  my $link = "/sessions/$time/$yml->{slug}.html";

  $papers{$_} = $link for $yml->{papers}->@*;
}

$papers{$_} = '/sessions/sat/afternoon' for qw(horlacher rings tenzer);

# Do the papers

my $papers_dir = path('papers');

for my $f ($papers_dir->children) {
  next unless $f =~ /yml$/;

  my $key = $f->basename('.yml');
  my $link = $papers{$key};
  warn "No link for $key\n" and next unless $link;

  my @lines = $f->lines_utf8;

  my $out = Path::Tiny->tempfile;

  for my $l (@lines) {
    $out->append_utf8($l);
    $out->append(qq{link: "$link"\n}) if $l =~ /^title/;
  }

  $out->move("$f");
}



my %days;

BEGIN {
  %days = (
    Thursday => 'thu',
    Friday   => 'fri',
    Saturday => 'sat',
    Sunday   => 'sun',
  );
}

sub compute_time ($s) {
  my @words = split /[ ,]/, $s;

  return "" . $days{ $words[0] } . "/" . $words[1];
}

