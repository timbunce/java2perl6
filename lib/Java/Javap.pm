package Java::Javap;
use strict; use warnings;

our $VERSION = '0.04';

use Java::Javap::TypeCast;

sub get_included_types {
    shift; # invoked through this class, discard our name
    my $tree     = shift;
    my $caster   = shift;
    
    my %answers;

    # first, get parent type
    my $parent   = $tree->{ parent };
    $answers{ $parent }++ unless ( _skip_it( $parent, $caster ) );

    # now get types from the children
    my $contents = $tree->{ contents };

    ELEMENT:
    foreach my $element ( @{ $contents } ) {
        if ($element->{ body_element } ne 'method') {
            next ELEMENT;
        }

        foreach my $item (
            $element->{ returns },
            @{ $element->{ args } }
        ) {
            my $type_name = $item->{ name };
            next if _skip_it( $type_name, $caster );

            $answers{ $type_name }++;
            #warn "Noted $element->{name} type $type_name\n";
        }
    }

    return [ keys %answers ];
}

# returns true if type casts to a builtin perl6 type
sub _skip_it {
    my $type_name    = shift;
    my $caster  = shift;
    
    return 1 if not defined $type_name;
    return 1 if $type_name eq 'void';

    my $cast = $caster->cast( $type_name );
    $cast    =~ s/::/./g;

    my $skip_it = 0;

    $skip_it++ if ( $type_name ne $cast );
    #warn "Skipping $type_name ($cast)\n" if $skip_it;

    return $skip_it;
}

1;

=head1 NAME

Java::Javap - Java to Perl 6 API translator

=head1 SYNOPSIS

    java2perl6 java.somepackage.Module

=head1 DESCRIPTION

See C<java2perl6> for instructions and advice on use of this module.

This particular module is only a place holder for the version number
of this project (see below).

=head1 METHODS

For script writers, there is one method:

=head2 get_included_types

Call this as a class method.

Parameters: an abstract syntax tree you got from calling comp_unit
an a C<Java::Javap::Grammar> object.

Returns: an array reference of the types in arguments to methods, or
return values (thrown types are not reported).

=head1 SEE ALSO

C<java2perl6>
C<Java::Javap::Generator>
C<Java::Javap::Generator::Std>
C<javap.grammar>

=head1 AUTHOR

Philip Crow, E<lt>crow.phil@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Philip Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
