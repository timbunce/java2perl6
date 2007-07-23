package Java::Javap;
use strict; use warnings;

our $VERSION = '0.04';

use Java::Javap::TypeCast;

my $caster   = Java::Javap::TypeCast->new();

sub get_included_types {
    shift; # invoked through this class, discard our name
    my $tree     = shift;
    my %answers;

    # first, get parent type
    my $parent   = $tree->{ parent };
    $answers{ $parent }++ unless ( _skip_it( $parent ) );

    # now get types from the children
    my $contents = $tree->{ contents };

    ELEMENT:
    foreach my $element ( @{ $contents } ) {
        next ELEMENT unless $element->{ body_element } eq 'method';

        # check return value
        my $return_type = $element->{ returns }{ name };

        $answers{ $return_type }++ unless ( _skip_it( $return_type ) );

        # check args
        foreach my $arg ( @{ $element->{ args } } ) {
            my $arg_type = $element->{ returns }{ name };
            $answers{ $return_type }++ unless ( _skip_it( $arg_type ) );
        }
    }

    return [ keys %answers ];
}

sub _skip_it {
    my $type    = shift;

    return 1 unless defined $type;

    my $cast    = $caster->cast( $type );
    $cast       =~ s/::/./g;

    my $skip_it = 0;

    $skip_it++ if ( $type ne $cast ) or ( $type eq 'void' );

#    $skip_it++ if $type =~ /^java\.util/;
#    $skip_it++ if $type =~ /^java\.math/;

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
