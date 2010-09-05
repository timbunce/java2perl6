use strict;
use warnings;

use lib 'lib';

use Test::More;
use Java::Javap;

plan skip_all => "javap from Java SDK required: $@"
	unless Java::Javap->javap_test;

plan tests => 4;

my $java_class = 'com.example.NestedIntTest';

my $decomp = Java::Javap->javap(
	[$java_class],
	[ qw(-verbose -classpath testjavas) ]
);

note($decomp);

ok($decomp, 'received some output from javap');
like($decomp, qr{Compiled from}m, 'javap output contains a "Compiled from" statement');
like($decomp, qr{$java_class}m, 'javap output contains the original class name');
ok(length($decomp) > length($java_class), 'javap output is longer than the class name');

