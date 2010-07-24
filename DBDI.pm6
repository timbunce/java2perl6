use v6;

use java::sql::DriverManager;

use DBDI_pg;

class DBDI does java::sql::DriverManager {

    multi method getConnection (
        Str $url,
        Str $user,
        Str $pass,
    --> java::sql::Connection
    ) {
        my $conninfo = "host=localhost $url user=$user password=$pass";
        my %opt;
        my $con = DBDI_pg::Driver.connect($conninfo, %opt);
        return $con;
    }

}
