#!/usr/bin/env perl

=head1 NAME

mkjdbc.pl - generate the perl6 translation of the classes related to JDBC

=head1 SYNOPSIS

    perl mkjdbc.pl

=head1 DESCRIPTION

This is just a quick hack to exercise java2perl6api with the use case that
interests us most: JDBC.

The jdbc_classes.txt class file lists the Java classes related to JDBC.
This script translates those classes into the corresponding perl6 classes and
roles in the jdbclib directory.

If a jdbclib directory already exists it's renamed to jdbclib.prev and, at the
end of the run, the contents of the directory are compared.

=cut

use strict;
use warnings;
use autodie qw(:all);
use Cwd qw(getcwd);

my $outdir = 'jdbclib';

system qq{rm -rf $outdir.prev} if -d "$outdir.prev";
system qq{mv -f $outdir $outdir.prev} if -d $outdir;

system qq{time perl -Mlib=lib bin/java2perl6api --outdir $outdir @ARGV `cat jdbclib-classes.txt`};

system qq{diff -wr --exclude=*.pir -u $outdir.prev $outdir} || warn "Output differs\n"
    if -d "$outdir.prev";

