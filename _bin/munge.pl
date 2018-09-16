#!perl
use v5.24;
use warnings;
use Path::Tiny;
use Data::Dumper::Concise;
use Getopt::Long::Descriptive;
use YAML::XS;
use Encode;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

my ($opt, $usage) = describe_options(
  '%c %o <STDIN>',
  [ 'force|f', "create even if there's already a session with this slug" ],
);

# This is a dumb program, meant to be called as a vim filter. Highlight some
# yaml front matter and call this as a filter. It'll dump out the two
# necessary files with the right filenames.

my $SESSION_PATH = path('/Users/michael/code/smt/societymusictheory.github.io/_data/sessions');

my $append_paper = <<EOF;
{% include paper_titles.html %}

<h2>Abstracts</h2>
{% include paper_abstracts.html %}
EOF

my $append_panel = <<EOF;
{% include panelist_info.html %}
EOF


my @lines =  <STDIN>;
@lines = map {; encode('utf-8', $_) } @lines;
my $given = join '', @lines;

my $struct = Load($given);
my $slug = $struct->{slug};
die "no slug" unless $slug;

my $html_path = path("$slug.html");
my $yaml_path = $SESSION_PATH->child("$slug.yml");

die 'duplicate session' if $yaml_path->exists && ! $opt->force;

my $html = <<EOF;
---
title: "$struct->{title}"
slug: $struct->{slug}
layout: session
---

{% include session_title.html %}
EOF


my $append_what = $struct->{panelists} ? $append_panel : $append_paper;

# ->spew rather than ->spew_utf8 because we have octets here.
$html_path->spew($html . $append_what);
$yaml_path->spew(join '', @lines[1..$#lines]);

# ...but vim wants characters
print decode('utf-8', $_) for @lines;





