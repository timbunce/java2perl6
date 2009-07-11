#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Cwd qw(getcwd);

my $outdir = 'jdbclib';

my $perl6 = shift || "$ENV{HOME}/perl6/rakudo/perl6";
$ENV{PERL6LIB} .= ":$outdir";

system qq{make};

system qq{rm -rf $outdir.prev; mv -f $outdir $outdir.prev};

system qq{perl -Mblib blib/script/java2perl6 --outdir $outdir --recurse --nest `cat jdbc_classes.txt`};

system qq{diff -r -u $outdir.prev $outdir} if -d "$outdir.prev";

# would be nice to validate these from the 'bottom up'
# XXX could build this into java2perl6 as an option
# but java2perl6 need to be restructured to actually recurse
system qq{find $outdir -name \*.pm | xargs -L 1 -t $perl6};

