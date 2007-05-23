# Note about how this is generated.  What java file gave rise to it?
# When was it made?  With which command line switches?  By what version
# of the generator?  etc.

role IntTest {
    method array_returner(
        Str v1,
        Int v2,
        Array of Num v3,
        Array of Array of Num v4
    ) returns Array of Array of Int { ... }

    multi method object_returner() returns Str { ... }

    multi method object_returner(String v1) returns Str { ... }
}
