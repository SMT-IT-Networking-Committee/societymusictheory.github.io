#!/usr/bin/env perl
use warnings;
use strict;
use v5.14;
use utf8;

# Requires JSON module, for data loading
use JSON;
use Data::Dumper;
my $DATA_FILE = "./js/sessionData.json";

my %data = %{readFile()};

for my $key (keys %data) {
    my %info = %{$data{$key}};

    my $room = $info{room};
    $room = $room =~ s/[)(]//gr;
    my $session = $info{session};
    my $time = $info{time};
    $time = $time =~ s/--/–/r;  #en-dash

    my $title = $info{title};

    my $infoP = qq{<p class="sessionInfo">$room • $session, $time</p>};

    # process that file
    my $path = '.' . $info{path};
    processFile($path, $infoP, $title);
}


sub readFile {
    my $data;
    my $dataString;

    open my $in, "<:utf8", $DATA_FILE or die "Can't open $DATA_FILE: $!";
    $dataString .= $_ for <$in>;
    $data = from_json($dataString);
}

sub processFile {
    my ($path, $infoP, $title) = @_;

    my $newPath = "$path.new";

    open my $in, "<:utf8", $path or die "can't open $path: $!";
    open my $out, ">:utf8", $newPath or die "can't open $newPath: $!";

    while (<$in>) {
        if (/^<h1>/) {
            say $out $infoP;
            say $out qq{<h1>$title</h1>};
            next;
        }

        print $out $_;
    }

    rename($newPath, $path);
}
