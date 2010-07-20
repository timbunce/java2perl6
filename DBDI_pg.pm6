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

    has $db_conn;

    multi method createStatement (
    --> java::sql::Statement   #  java.sql.Statement
    ) {
        say "> createStatement";
        my $stmt = DBDI_pg::Statement.new;
        say "< createStatement";
        return $stmt;
    }

}

class DBDI_pg::Driver does java::sql::Driver {

    multi method connect (
        Str $v1,  # java.lang.String
        #Hash $v2,
    --> java::sql::Connection   #  java.sql.Connection
    ) {
        say "> connect $v1";
        my $db_conn = PQconnectdb($v1);
        if (PQstatus($conn) != CONNECTION_OK) {
            $*ERR.say: sprintf( "Connection to database ($v1) failed: %s",
                    PQerrorMessage($conn));
            #exit_nicely($conn);
        }
        my DBDI_pg::Connection $conn .= new( :$db_conn );

        say "< connect";
        return $conn;
    }

}
