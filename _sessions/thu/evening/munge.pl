#!perl
use v5.24;
use warnings;
use Path::Tiny;
use Data::Dumper::Concise;
use YAML::XS;
use Encode;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');


my $SESSION_PATH = path('/Users/michael/code/smt/societymusictheory.github.io/_data/sessions');


=pod

my $given = <<EOF;
---
title: "Embodiment and Voice in Contemporary Music"
slug: embodiment-voice-contemporary-music
society: SMT
layout: session
time: 'Thursday evening, 8:00–9:30'
room: ''
chair:
    name: Judith Lochhead
    institution: Stony Brook University
papers:
    - jakubowski
    - mason
    - oinas
EOF

=cut

my $append_paper = <<EOF;
---

{% include session_title.html %}
{% include paper_titles.html %}

<h2>Abstracts</h2>
{% include paper_abstracts.html %}
EOF

my $append_panel = <<EOF;
---

{% include session_title.html %}
{% include panelist_info.html %}
EOF


my @lines = <STDIN>;
@lines = map {; encode('utf-8', $_) } @lines;
my $given = join '', @lines;

my $struct = Load($given);
my $slug = $struct->{slug};

my $html_path = path("$slug.html");
my $yaml_path = $SESSION_PATH->child("$slug.yml");


my $append_what = $struct->{panelists} ? $append_panel : $append_paper;

$html_path->spew($given . $append_what);
$yaml_path->spew(join '', @lines[1..$#lines]);

print decode('utf-8', $_) for @lines;




