package Java::Javap::Generator;
use strict; use warnings;

use File::Spec;

sub get_generator {
    my $class     = shift;
    my $subclass  = shift;
    my $module    = join '::', $class, $subclass;

    my @classpath = split /::/, $class;
    my $pm_file   = File::Spec->catfile( @classpath, "$subclass.pm" );

    require $pm_file;

    return $module->new( @_ );
}

1;

=head1 NAME

Java::Javap::Generator - Factory for Perl 6 generators

=head1 SYNOPSIS

    use Java::Javap::Generator;

    my $gen = Java::Javap::Generator->get_generator( 'NAME', @args );

    my $output = $gen->generate( @more_args );

=head1 DESCRIPTION

This is a factory class which returns a Java -> Perl 6 generator.
All generators must live in the Java::Javap::Generator:: namespace.
They must supply a C<new> method.  They should supply a C<generate>
method.

To use a particular generator, see its POD.

=head1 KNOWN GENERATORS

    Java::Javap::Generator::TT - uses TT templates

=head1 METHODS

This moduule provides only one method which returns an instance of the
supplied generating class.

=head2 get_generator

Call C<get_generator> with the name of the generator you want to use.
Pass any additional arguments expected by the C<new> method of your
genertor's class.  Example:

    my $generator = Java::Javap::Generator->get_generator(
            'TT', \%tt_args
    );

=head2 EXPORT

None.  Call C<get_generator> as a class method.

=head1 SEE ALSO

All the modules in the Java::Javap::Generator:: namespace.

=head1 AUTHOR

Phil Crow, E<lt>crow.phil@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

