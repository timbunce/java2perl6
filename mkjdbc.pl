#!/usr/bin/env perl

# process and check the classes related to JDBC (listed in jdbc_classes.txt)

use strict;
use warnings;
use autodie;
use Cwd qw(getcwd);

my $outdir = 'jdbclib';

$ENV{PERL6LIB} .= ":$outdir"; # XXX %Config pathsep

system qq{make};

system qq{rm -rf $outdir.prev; mv -f $outdir $outdir.prev};

system qq{perl -Mblib blib/script/java2perl6 --outdir $outdir --recurse --nest --check `cat jdbc_classes.txt`};

system qq{diff -r -u $outdir.prev $outdir} if -d "$outdir.prev";

