use v6;

use DBDI;
use DBDI_pg;

my $dbname = @*ARGS.shift || prompt 'Database: ';

my $con = DBDI::DriverManager.getConnection("dbdi:postgres:dbname=$dbname", 'testuser', 'testpass');

while prompt 'SQL: ' -> $sql {

    my $result = $con.createStatement.executeQuery($sql);
    my $meta   = $result.getMetaData;

    my @names = map { $meta.getColumnLabel($_) }, 1..$meta.getColumnCount;
    say @names.join(", ");

    while ( $result.next ) {
        my @row = map { $result.getString($_) }, 1..@names.elems;
        say @row.join(", ");
    }
}
