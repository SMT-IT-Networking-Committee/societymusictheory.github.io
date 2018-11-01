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
  Thursday => '20181101',
  Friday   => '20181102',
  Saturday => '20181103',
  Sunday   => '20181104',
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
PRODID:-//SMT Conference Guide 2018
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:America/Chicago
BEGIN:DAYLIGHT
TZNAME:CDT
RRULE:FREQ=YEARLY;UNTIL=20060402T080000Z;BYDAY=1SU;BYMONTH=4
DTSTART:20000402T020000
TZOFFSETFROM:-0600
TZOFFSETTO:-0500
END:DAYLIGHT
BEGIN:DAYLIGHT
TZNAME:CDT
RRULE:FREQ=YEARLY;BYDAY=2SU;BYMONTH=3
DTSTART:20070311T020000
TZOFFSETFROM:-0600
TZOFFSETTO:-0500
END:DAYLIGHT
BEGIN:STANDARD
TZNAME:CST
RRULE:FREQ=YEARLY;UNTIL=20061029T070000Z;BYDAY=-1SU;BYMONTH=10
DTSTART:20001029T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0600
END:STANDARD
BEGIN:STANDARD
TZNAME:CST
RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=11
DTSTART:20071104T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0600
END:STANDARD
END:VTIMEZONE
EOF

$prelude =~ s/\n/\r\n/g;

for my $f ($session_dir->children) {
  next unless $f =~ /yml$/;

  my $struct = Load($f->slurp);
  my $time = $struct->{time};
  die "no time" unless $time;

  my ($day, $start, $end) = $time =~ /^(\w+).*?([0-9]{1,2}:[0-9]{2}).*?([0-9]{1,2}:[0-9]{2})/;

  if ($time =~ /(afternoon|evening)/n) {
    my ($sh, $sm) = split /:/, $start;
    $sh += 12 if $sh != 12;
    $start = sprintf("%02d%02d00", $sh, $sm);

    my ($eh, $em) = split /:/, $end;
    $eh += 12 if $eh != 12;
    $end = sprintf("%02d%02d00", $eh, $em);
  }

  my $dtstart = sprintf("DTSTART;TZID=America/Chicago:%sT%s", $days{$day}, $start);
  my $dtend =   sprintf("DTEND;TZID=America/Chicago:%sT%s", $days{$day}, $end);

  my $now = DateTime->now(time_zone => 'UTC');
  my $dtstamp = $now->ymd('') . 'T' . $now->hms('') . 'Z';
  my $guid = guid_string;

  my $title = $struct->{title} . ' - ' . $struct->{room};
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

  my $where = compute_time($time);
  my $out = $cal_dir->child("$struct->{slug}.ics");
  $out->spew_utf8($prelude . $vevent);
}
