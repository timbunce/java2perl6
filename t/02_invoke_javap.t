use strict;
use warnings;

use lib 'lib';

use Test::More;
use Java::Javap;

plan skip_all => "javap from Java SDK required: $@"
	unless Java::Javap->javap_test;

plan tests => 2;

my $decomp = Java::Javap->javap(
	['com.example.NestedIntTest'],
	{-classpath=>'testjavas'}
);

diag($decomp);

ok($decomp, 'received some output from javap');
like($decomp, qr{Compiled from}m, 'javap output seems sane');

