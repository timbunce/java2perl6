use v6;

use DBDI;

my $con = DBDI.getConnection('', '', '');
my $stmt = $con.createStatement;
my $result = $stmt.executeQuery('select * from pg_database');
die $! if $!;
say $result.perl;
