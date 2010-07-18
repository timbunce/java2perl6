use v6;

use java::sql::DriverManager;
use java::sql::Connection;
use java::sql::Statement;
#use java::sql::ResultSet;

class DBDI::Statement does java::sql::Statement {

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

class DBDI::Connection does java::sql::Connection {

    multi method createStatement (
    --> java::sql::Statement   #  java.sql.Statement
    ) {
        say "> createStatement";
        my $stmt = DBDI::Statement.new;
        say "< createStatement";
        return $stmt;
    }

}

class DBDI does java::sql::DriverManager {

    multi method getConnection (
        Str $v1,  # java.lang.String
        Str $v2,  # java.lang.String
        Str $v3,  # java.lang.String
    --> java::sql::Connection   #  java.sql.Connection
    ) {
        say "> getConnection";
        my $con = DBDI::Connection.new;
        say "< getConnection";
        return $con;
    }

}
