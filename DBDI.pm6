use v6;

class java::sql::Driver { ... };
class java::sql::Connection { ... };

use java::sql::DriverManager;

class DBDI::DriverManager does java::sql::DriverManager {

    my %drivers;

    method registerDriver ( java::sql::Driver $driver ) {
        say "registerDriver($driver)";
        %drivers{$driver} = $driver;
    } # throws java.sql.SQLException

    multi method getConnection (
        Str $url,
        Str $user,
        Str $pass,
    --> java::sql::Connection
    ) {
        say "> getConnection($url, $user, $pass)";

        my Hash $opt .= new;
        $opt.<user> = $user;
        $opt.<password> = $pass;

        my $con;
        for %drivers.values -> $driver {
            $con = $driver.connect($url, $opt);
            last if $con;
        }
        die "Unable to find a driver to handle $url" if not $con;

        say "< getConnection $con";
        return $con;
    }

}
