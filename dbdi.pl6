use v6;

use DBDI;

my $dbname = prompt 'Database: ';

my $con = DBDI.getConnection("dbname=$dbname", 'testuser', 'testpass');

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
