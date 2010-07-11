use strict;
use warnings;

use lib 'lib';

use Test::More;
use File::Spec;
use File::Path qw(rmtree);
use Java::Javap;

plan skip_all => "javap from Java SDK required: $!"
	unless Java::Javap->javap_test();

plan tests    => 5;

my $perl       = $^X;
my $java2perl6 = File::Spec->catfile( 'bin', 'java2perl6api' );
my $java2perl6cmd = "$perl $java2perl6 --trace 0 --javapopts '-classpath testjavas'";
my $testclass  = 'IntTest';

#--------------------------------------------------------------------
# Output to current directory.
#--------------------------------------------------------------------

`$java2perl6cmd $testclass`;

if ( -f "$testclass.pm6" ) {
    ok( "$testclass.pm6 in current dir" );
    unlink "$testclass.pm6";
}
else {
    fail( "$testclass.pm6 in current dir" );
}

#--------------------------------------------------------------------
# Output to another directory.
#--------------------------------------------------------------------

`$java2perl6cmd --outdir newdir $testclass`;
my $output_file = File::Spec->catfile( 'newdir', "$testclass.pm6" );

if ( -f $output_file ) {
    ok( "$testclass.pm6 in new dir" );
    rmtree 'newdir', 1;
}
else {
    fail( "$testclass.pm6 in new dir" );
}

#--------------------------------------------------------------------
# Nested output of packaged module under current directory.
#--------------------------------------------------------------------

$testclass = 'com.example.NestedIntTest';

`$java2perl6cmd --nest $testclass`;
my $nested_location = File::Spec->catfile(
        'com', 'example', 'NestedIntTest.pm6'
);

if ( -f $nested_location ) {
    ok( "$nested_location under current dir" );
    rmtree 'com', 1;
}
else {
    fail( "$nested_location under current dir" );
}

#--------------------------------------------------------------------
# Nested output of packaged module under another directory.
#--------------------------------------------------------------------

`$java2perl6cmd --nest --outdir newdir $testclass`;
$nested_location = File::Spec->catfile(
        'newdir', 'com', 'example', 'NestedIntTest.pm6'
);

if ( -f $nested_location ) {
    ok( "$nested_location under alternate dir" );
    rmtree 'newdir', 1;
}
else {
    fail( "$nested_location under alternate dir" );
}

#--------------------------------------------------------------------
# Recursive nested output of packaged module under current directory.
#--------------------------------------------------------------------

`$java2perl6cmd --nest --recurse $testclass`;
my $original_nested_location = File::Spec->catfile(
        'com', 'example', 'NestedIntTest.pm6'
);
my $second_nested_location = File::Spec->catfile(
        'com', 'example', 'Second.pm6'
);

if ( -f $second_nested_location ) {
    ok( "$second_nested_location under current dir" );
    rmtree 'com';
}
else {
    fail( "$second_nested_location under current dir" );
}

