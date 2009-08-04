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

system qq{perl -Mblib blib/script/java2perl6 --outdir $outdir --recurse --nest --check `cat jdbc_classes.txt`};

system qq{diff -r -u $outdir.prev $outdir} if -d "$outdir.prev";

