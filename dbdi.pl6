use v6;

use DBDI;

my $con = DBDI.getConnection('', '', '');

my $stmt = $con.createStatement;
die $! if $!;
say $stmt;
say $stmt.perl;
my $result = $stmt.executeQuery('');
