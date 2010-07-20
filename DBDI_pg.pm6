use v6;

use java::sql::Driver;
use java::sql::Connection;
use java::sql::Statement;
#use java::sql::ResultSet;

use libpq;

class DBDI_pg::Statement does java::sql::Statement {

    method executeQuery (
        Str $v1,  # java.lang.String
    --> java::sql::ResultSet   #  java.sql.ResultSet
    ) {
        say "> executeQuery";
        my $result = 1; #DBDI::ResultSet.new;
        say "< executeQuery";
        return $result;
    }

}

class DBDI_pg::Connection does java::sql::Connection {

    has $conn;

    multi method createStatement (
    --> java::sql::Statement   #  java.sql.Statement
    ) {
        say "> createStatement";
        my $stmt = DBDI_pg::Statement.new;
        say "< createStatement";
        return $stmt;
    }

}

class DBDI_pg does java::sql::Driver {

    multi method connect (
        Str $v1,  # java.lang.String
        Hash $v2,
    --> java::sql::Connection   #  java.sql.Connection
    ) {
        say "> connect";
        my $conninfo = "host=localhost user=testuser password=testpass dbname=zavolaj";
        my $conn = PQconnectdb($conninfo);
        # Check to see that the backend connection was successfully made
        if (PQstatus($conn) != CONNECTION_OK)
        {
            $*ERR.say: sprintf( "Connection to database failed: %s",
                    PQerrorMessage($conn));
            exit_nicely($conn);
        }

        say "< connect";
        return $conn;
    }

}
