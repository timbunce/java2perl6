package Java::Javap;

use strict;
use warnings;
use Carp;

our $VERSION = '0.06';
our $JAVAP_EXECUTABLE = 'javap';

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

            $answers{ $type_name }++
                unless $type_name eq $tree->{java_qualified_name};
            #warn "Noted $element->{name} type $type_name\n";
        }
    }

    return [ keys %answers ];
}

sub invoke_javap {
	my ($self, $classes, $options) = @_;

	if (! $classes) {
		croak "No classes to be parsed";
	}

	if (! ref $classes) {
		$classes = [ $classes ];
	}

	$options ||= {};

	# Open the real javap executable and read output from it
	open(my $javap_fh, '-|', $JAVAP_EXECUTABLE, %$options, @$classes)
		or croak "'$JAVAP_EXECUTABLE @{[ %$options ]} @$classes' failed: $!";

	my $javap_output = q{};

	while (<$javap_fh>) {
		$javap_output .= $_;
	}

	# When dealing with a pipe, we also want to get errors from close
	close $javap_fh
		or croak "'$JAVAP_EXECUTABLE @{[ %$options ]} @$classes' failed: $!";

	return $javap_output;
}

*javap = *invoke_javap;

# Shortcut for the test suite
sub javap_test {
	my ($self) = @_;
	my $output;
	eval { $output = $self->invoke_javap(['java.lang.String']) };
	return $output ? 1 : 0;
}

# Returns true if type casts to a builtin perl6 type
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

=head2 invoke_javap

=head2 javap

Invokes the C<javap> process and return the output.
Throws an exception if something goes wrong, like C<javap> is
not found.

=head3 Parameters

=over

=item \@classes

List of classes to be decompiled. It can also be supplied as a string,
if a single class should be decompiled.

=item \%options

Options to be passed to the C<javap> process.

=back

=head3 Example

    my @classes = ('java.lang.String');
    my %options = ();
    my $output = Java::Javap->javap(\@classes, \%options);

	# or ...

    my $output = Java::Javap->javap('java.lang.String');

=head1 SEE ALSO

=over

=item C<java2perl6>

=item C<Java::Javap::Generator>

=item C<Java::Javap::Generator::Std>

=item C<javap.grammar>

=back

=head1 AUTHORS

Philip Crow, E<lt>crow.phil@gmail.comE<gt>
Cosimo Streppone, E<lt>cosimo@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Philip Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
