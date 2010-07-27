use v6;

use DBDI;
use DBDI_pg;

# e.g. "dbdi:postgres:dbname=$dbname"
my $url = @*ARGS.shift || prompt "Enter a 'dbdi:driver:...' URL: ";

my $con = DBDI::DriverManager.getConnection($url, 'testuser', 'testpass');

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
