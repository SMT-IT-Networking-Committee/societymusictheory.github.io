#!perl
use warnings;
use strict;
use v5.14;

open my $in, "<", "sessions.html" or die "can't open file: $!";


my $sessionCounter = 0;
my $fileOpen = 0;
my $out;

while (<$in>) {
    # Loop through lines. If we see an <h2>, that's a session: close anything
    # that's already open, then open a new file and start puking lines out
    # there.
    if (/<h2/) {
        if ($fileOpen) {
            close $out;
            $fileOpen = 0;
        }

        my $line = (/<h2.*?>(.*)<\/h2>/)[0];   # delete surrounding tag
        my ($title, $soc, $room) = $line =~ m{(.*)\((.*?)\)\s*(\(.*\))};

        # generate a reasonable short string for the filename
        my $id = genSlug($title);
        my $fn = sprintf("%03d-%s.html", $sessionCounter, $id);
        my $folder = getFolderName($sessionCounter);
        $sessionCounter++;

        # Open a new out file
        open $out, ">", "$folder/$fn" or die "can't open outfile: $!";
        $fileOpen = 1;

        # Print the header
        say $out qq{---};
        say $out qq{layout: session};
        say $out qq{title: "$title"};
        say $out qq{---};
        say $out qq{};

        # print h1 using munged data
        say $out qq{<h1>$title <span class="room">$room</span></h1>};
        say $out qq{<p class="society">$soc</p>};
        say $out qq{\n};

        next;
    }


    if ($fileOpen) {
        my ($auth, $title) = /(.*?), “(.*)/;

        unless ($auth) {
            print $out $_;
            next;
        }

        $auth = $auth =~ s/<p.*?>//r;            # strip opening tag
        $title = $title =~ s/”//r;               # trim close quote
        $title = $title =~ s!</p>!!r;            # strip close tag

        say $out qq{<p class="author">$auth</p>};
        say $out qq{<p class="title">$title</p>};
    }
}

# pass the number, return the folder name (no trailing slash)
sub getFolderName {
    my $num = shift;
    my $folder = "sessions/";

    if ($num >= 0 && $num <= 16) {
        $folder .= "thu/afternoon";
    } elsif ($num >= 17 && $num <= 30) {
        $folder .= "thu/evening";
    } elsif ($num >= 31 && $num <= 45) {
        $folder .= "fri/morning";
    } elsif ($num >= 46 && $num <= 60) {
        $folder .= "fri/afternoon";
    } elsif ($num >= 61 && $num <= 70) {
        $folder .= "fri/evening";
    } elsif ($num >= 71 && $num <= 90) {
        $folder .= "sat/morning";
    } elsif ($num >= 91 && $num <= 104) {
        $folder .= "sat/afternoon";
    } elsif ($num >= 105 && $num <= 108) {
        $folder .= "sat/evening";
    } elsif ($num >= 109 && $num <= 127) {
        $folder .= "sun/morning";
    } else {
         die "unrecognized number!";
    }

    return $folder;
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
