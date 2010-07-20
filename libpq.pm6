module libpq;

use NativeCall;  # from project 'zavolaj'

# -------- foreign function definitions in alphabetical order ----------

# hacked from http://github.com/jnthn/zavolaj/blob/master/examples/postgresqlclient.p6
# See http://www.postgresql.org/docs/9.0/static/libpq-example.html


sub PQclear( OpaquePointer $res )
    is native('libpq') is export
    { ... }

sub PQconnectdb( Str $conninfo )
    returns OpaquePointer
    is native('libpq') is export
    { ... }

sub PQerrorMessage( OpaquePointer $conn )
    returns Str
    is native('libpq') is export
    { ... }

sub PQexec( OpaquePointer $conn, Str $command )
    returns OpaquePointer
    is native('libpq') is export
    { ... }

sub PQfinish( OpaquePointer $conn )
    is native('libpq') is export
    { ... }

sub PQfname( OpaquePointer $res, Int $fieldnum )
    returns Str
    is native('libpq') is export
    { ... }

sub PQgetvalue( OpaquePointer $res, Int $tuplenum, Int $fieldnum )
    returns Str
    is native('libpq') is export
    { ... }

sub PQnfields( OpaquePointer $res )
    returns Int
    is native('libpq') is export
    { ... }

sub PQntuples( OpaquePointer $res )
    returns Int
    is native('libpq') is export
    { ... }

sub PQresultStatus( OpaquePointer $res )
    returns Int
    is native('libpq') is export
    { ... }

sub PQstatus( OpaquePointer $conn )
    returns Int
    is native('libpq') is export
    { ... }

 # from libpq-fe.h  These should of course be constants or perhaps even enums
sub CONNECTION_OK     is export { 0 }
sub CONNECTION_BAD    is export { 1 }

sub PGRES_EMPTY_QUERY is export { 0 }
sub PGRES_COMMAND_OK  is export { 1 }
sub PGRES_TUPLES_OK   is export { 2 }
