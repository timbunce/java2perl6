use strict;
use warnings;

use lib 'lib';

use Test::More;
use Data::Dumper;

use Java::Javap;
use Java::Javap::Generator;
use Java::Javap::Grammar;

plan skip_all => "javap from Java SDK required: $!"
	unless Java::Javap->javap_test();

plan tests    => 1;

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = Java::Javap->javap('FinalClassTest', {-classpath => 'testjavas'});

my $tree   = $parser->comp_unit( $decomp );

my $expected_tree = {
          'parent' => 'java.lang.Object',
          'perl_qualified_name' => 'FinalClassTest',
          'qualifiers' => [
                            'final'
                          ],
          'access' => 'public',
          'contents' => [
                          {
                            'body_element' => 'constructor',
                            'returns' => {
                                           'array_depth' => 0,
                                           'name' => 'FinalClassTest',
                                           'array_text' => ''
                                         },
                            'access' => 'public',
                            'name' => 'new',
                            'args' => [],
                            'throws' => [],
                            'native' => ''
                          },
                          {
                            'attrs' => [
                                         'final'
                                       ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 0,
                                           'array_text' => '',
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [],
                            'name' => 'openStream',
                            'throws' => []
                          }
                        ],
          'class_or_interface' => 'class',
          'compiled_from' => 'FinalClassTest.java',
          'java_qualified_name' => 'FinalClassTest',
          'methods' => {
                         'openStream' => 1,
                         'new' => 1
                       },
          'constructors' => 1,
          'implements' => undef
        };

is_deeply( $tree, $expected_tree, 'final class' )
    or print "---vvv---\n".Dumper($tree)."---^^^---\n";

