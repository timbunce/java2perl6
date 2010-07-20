use v6;

use DBDI;

my $conninfo = "host=localhost user=testuser password=testpass dbname=zavolaj";

my $con    = DBDI.getConnection($conninfo, '', '');

my $stmt   = $con.createStatement;

my $result = $stmt.executeQuery('select * from pg_database');
my $meta   = $result.getMetaData;

my @names = map { $meta.getColumnLabel($_) }, 1..$meta.getColumnCount;
say @names.join(", ");

while ( $result.next ) {
    my @row = map { $result.getString($_) }, 1..$meta.getColumnCount;
    say @row.join(", ");
}
