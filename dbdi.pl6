use v6;

use DBDI;

my $con = DBDI.getConnection('', '', '');
die $! if $!;
say $con;
say $con.perl;

my $stmt = $con.createStatement;
die $! if $!;
say $stmt;
say $stmt.perl;

my $result = $stmt.executeQuery('');
