use strict;

use Test::More tests => 1;

BEGIN { use_ok('Java::Javap') };

my $version = qx(java -version 2>&1); # XXX make portable
diag $version;
