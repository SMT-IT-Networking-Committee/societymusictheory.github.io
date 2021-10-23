#!perl
use warnings;
use v5.24;
use utf8;
use experimental qw(signatures);
use Path::Tiny;
use YAML::XS;
use Data::Dumper::Concise;
use Data::GUID qw(guid_string);
use DateTime;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

my %days = (
  'November 4'  => '20211104',
  'November 5'  => '20211105',
  'November 6' => '20211106',
  'November 7' => '20211107',
);

my %names = (
  Thursday => 'thu',
  Friday   => 'fri',
  Saturday => 'sat',
  Sunday   => 'sun',
);

sub compute_time ($s) {
  my @words = split /[ ,]/, $s;

  my $out = "" . $names{ $words[0] } . "/" . $words[1];
  return $out;
}

my $session_dir = path('_data/sessions');
my $cal_dir = path('ics');
$cal_dir->mkpath;

my $prelude = <<'EOF';
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//SMT Conference Guide 2021
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:America/New_York
BEGIN:DAYLIGHT
TZNAME:EDT
RRULE:FREQ=YEARLY;UNTIL=20060402T070000Z;BYDAY=1SU;BYMONTH=4
DTSTART:20000402T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
END:DAYLIGHT
BEGIN:DAYLIGHT
TZNAME:EDT
RRULE:FREQ=YEARLY;BYDAY=2SU;BYMONTH=3
DTSTART:20070311T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
END:DAYLIGHT
BEGIN:STANDARD
TZNAME:EST
RRULE:FREQ=YEARLY;UNTIL=20061029T060000Z;BYDAY=-1SU;BYMONTH=10
DTSTART:20001029T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
END:STANDARD
BEGIN:STANDARD
TZNAME:EST
RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=11
DTSTART:20071104T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
END:STANDARD
END:VTIMEZONE
EOF

$prelude =~ s/\n/\r\n/g;

for my $f ($session_dir->children) {
  next unless $f =~ /yml$/;
  next if $f =~ /__blank/;

  warn $f->basename . "\n";

  my $struct = Load($f->slurp);
  my $time = $struct->{time};
  die "no time: " . Dumper($struct) unless $time;

  # 'Saturday midday, November 14, 12–12:50 CST'

  my ($day, $date, $start, $end) = $time =~ m{
    ^(\w+)                      # day
    .*?
    (November\s\d+),\s+         # date
    ([0-9]{1,2}(?::[0-9]{2})?)  # start
    .*?
    ([0-9]{1,2}(?::[0-9]{2})?)  # end
  }x;


  if ($time =~ /(midday|afternoon)/n) {
    my ($sh, $sm) = split /:/, $start;
    $sm //= 0;
    $sh += 12 if $sh != 12;
    $start = sprintf("%02d%02d00", $sh, $sm);

    my ($eh, $em) = split /:/, $end;
    $em //= 0;
    $eh += 12 if $eh != 12;
    $end = sprintf("%02d%02d00", $eh, $em);
  } else {
    my ($sh, $sm) = split /:/, $start;
    $sm //= 0;
    $start = sprintf("%02d%02d00", $sh, $sm);

    my ($eh, $em) = split /:/, $end;
    $em //= 0;
    $end = sprintf("%02d%02d00", $eh, $em);
  }

  my $dtstart = sprintf("DTSTART;TZID=America/New_York:%sT%s", $days{$date}, $start);
  my $dtend =   sprintf("DTEND;TZID=America/New_York:%sT%s", $days{$date}, $end);

  my $now = DateTime->now(time_zone => 'UTC');
  my $dtstamp = $now->ymd('') . 'T' . $now->hms('') . 'Z';
  my $guid = guid_string;

  my $out = $cal_dir->child("$struct->{slug}.ics");

  # reuse dtstamp / guid
  if ($out->exists) {
    for my $l ($out->lines) {
      if (my ($stamp) = $l =~ /^DTSTAMP:(.*?)[\r\n]+$/) {
        $dtstamp = $stamp;
      }
      if (my ($uid) = $l =~ /^UID:(.*?)[\r\n]+$/) {
        $guid = $uid;
      }
    }
  }

  my $title = $struct->{title}; #  . ' - ' . $struct->{room};
  my $vevent = <<EOF;
BEGIN:VEVENT
DTSTAMP:$dtstamp
UID:$guid
SUMMARY:$title
$dtstart
$dtend
END:VEVENT
END:VCALENDAR
EOF

  $vevent =~ s/\n/\r\n/g;

  $out->spew_utf8($prelude . $vevent);
}
