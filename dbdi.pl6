use v6;

use DBDI;

my $conninfo = "host=localhost user=testuser password=testpass dbname=zavolaj";

my $con    = DBDI.getConnection($conninfo, '', '');

my $stmt   = $con.createStatement;

my $result = $stmt.executeQuery('select * from pg_database');

while ( $result.next ) {
    say $result.getString(1);
}
