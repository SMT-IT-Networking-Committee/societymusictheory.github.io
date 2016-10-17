#!perl
use warnings;
use strict;
use v5.14;

open my $in, "<", "sessions.html" or die "can't open file: $!";


my $sessionCounter = 0;
my $fileOpen = 0;
my @sessions;
my $out;

while (<$in>) {
    # Loop through lines. If we see an <h2>, we need to add that to a list of
    # session names, and then when we get to a new chunk of sessions, that
    # needs to be written and flushed.
    if (/^<h2/) {
        if ($fileOpen) {
            close $out;
            $fileOpen = 0;
        }

        my $line = (/<h2.*?>(.*)<\/h2>/)[0];   # delete surrounding tag
        my ($title, $soc, $room) = $line =~ m{(.*)\((.*?)\)\s*(\(.*\))};

        $title = $title =~ s/\s+$//r;

        # generate a reasonable short string for the filename
        my $id = genSlug($title);
        my $link = "$id.html";

        push @sessions, [$title, $link, $room];

        # if we need to flush, do that now
        if (my $folder = getFolderName($sessionCounter)) {
            flushit($folder);

        }


        $sessionCounter++;
    }
}

# one laa--ast tiii-iiime.
flushit(getFolderName($sessionCounter));


sub flushit {
    my ($folder) = shift;

    my $session = getTimeString($folder);
    my $time = getTimesForSession($folder);

    open $out, ">", "$folder/index.md" or die "can't open outfile: $!";

    # Print the header
    say $out qq{---};
    say $out qq{layout: default};
    say $out qq{title: $session Sessions};
    say $out qq{---};
    say $out qq{};

    # print h1 using munged data
    say $out qq{[Complete list of $session sessions](complete.html)};
    say $out qq{};
    say $out qq{# $session Sessions};
    say $out qq{};
    say $out qq{## Full-Length Sessions, $time};
    say $out qq{};

    for my $title (@sessions) {
        say $out "- [" . $title->[0] . "](" . $title->[1] .") " .
          "<span class=\"room\">" . $title->[2] . "</span>";
    }


    undef @sessions;
}

# This returns the folder name if we need to flush, otherwise returns false.
# These numbers are hardcoded
sub getFolderName {
    my $num = shift;

    my $folder = "sessions/";

    if ($num == 16) {
        $folder .= "thu/afternoon";
    } elsif ($num == 30) {
        $folder .= "thu/evening";
    } elsif ($num == 45) {
        $folder .= "fri/morning";
    } elsif ($num == 60) {
        $folder .= "fri/afternoon";
    } elsif ($num == 70) {
        $folder .= "fri/evening";
    } elsif ($num == 90) {
        $folder .= "sat/morning";
    } elsif ($num == 104) {
        $folder .= "sat/afternoon";
    } elsif ($num == 108) {
        $folder .= "sat/evening";
    } elsif ($num == 127) {
        $folder .= "sun/morning";
    } else {
        return 0;
    }

    return $folder;
}

# take the folder name, get back a nice string
sub getTimeString {
    my $folder = shift;
    my %days = (
        thu => "Thursday",
        fri => "Friday",
        sat => "Saturday",
        sun => "Sunday",
    );

    $folder = $folder =~ s|sessions/||r;

    my ($day, $time) = split /\//, $folder;

    return $days{$day} . " " . ucfirst($time);
}

sub getTimesForSession {
    my $folder = shift;
    my $time = $folder =~ s|.*/||r;

    if ($time eq 'morning') {
        return "9:00--12:00";
    } elsif ($time eq 'afternoon') {
        return "2:00--5:00";
    } elsif ($time eq 'evening') {
        return "8:00--11:00";
    }

    return "";
}

sub genSlug {
    my $title = shift;
    my $id;
    $id = $title =~ s/\s+$//r;       # trim space
    $id = $id =~ s/<.*?>//gr;        # delete tags
    $id = $id =~ s/ /-/gr;           # convert spaces to dashes
    $id = $id =~ s/:.*?$//gr;        # delete subtitle
    $id = lc $id;                    # downcase
    $id = $id =~ s/[^a-z\-]//gr;     # delete non-alpha

    return $id;
}
