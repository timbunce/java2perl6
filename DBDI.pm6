use v6;

use java::sql::DriverManager;

use DBDI_pg;

class DBDI does java::sql::DriverManager {

    multi method getConnection (
        Str $v1,  # java.lang.String
        Str $v2,  # java.lang.String
        Str $v3,  # java.lang.String
    --> java::sql::Connection   #  java.sql.Connection
    ) {
        say "> getConnection $v1";
        my %opt;
        my $con = DBDI_pg::Driver.connect($v1, %opt);
        say "< getConnection";
        return $con;
    }

}
