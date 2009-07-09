#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

my $perl6 = "$ENV{HOME}/perl6/rakudo/perl6";

system qq{make};

system qq{rm -rf jdbclib.prev; mv -f jdbclib jdbclib.prev};

system qq{perl -Mblib blib/script/java2perl6 --outdir jdbclib --recurse --nest `cat jdbc_classes.txt`};

system qq{diff -r -u jdbclib.prev jdbclib} if -d "jdbclib.prev";

# would be nice to validate these from the 'bottom up'
# XXX could build this into java2perl6 as an option
# but java2perl6 need to be restructured to actually recurse
system qq{find jdbclib -name \*.pm | xargs -L 1 -t $perl6};

