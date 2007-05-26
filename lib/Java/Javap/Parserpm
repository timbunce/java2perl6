use v6;

module Java::Javap::Parser;

#grammar JavapParser {
    rule method_decl { Method = <ws>* <mode>?
                                <ws>+ <method_name>
                                \(
                                    <arg_list>
                                \) \;
                     }

    rule mode        { Mode = ( public | private | protected ) }
    rule method_name { Name = ( <IDENT> [ <dot>   <IDENT> ]* ) }
    rule arg_list    { Args = ( <ARG>   [ <comma> <ARG>   ]* ) }

    rule ARG         { ( <IDENT> [ <array> ]* ) }
    rule IDENT       { ( \w+ ) }
#}

sub parse_javap( Str $raw_javap ) is export {
    my $raw_method = '    public java.lang.String(byte[], int, int);';

#    $raw_method ~~ m:keepall/<JavaParser.method_decl>/;
#    say $/;
    my $parse_tree;

    $raw_method ~~ /$<ast> := <method_decl>/;
#    $raw_method ~~ /$<ast> := <JavaParser.method_decl>/;

    say "$/<ast>.Method";
#    given $raw_method {
#        $parse_tree = m:keepall/<JavaParser.method_decl>/;
#    }

#    say $parse_tree<Method>;
#    say $parse_tree;

    return $parse_tree;
}
