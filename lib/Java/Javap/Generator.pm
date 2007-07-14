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

    Java::Javap::Generator::Std - uses TT templates

=head1 METHODS

This moduule provides only one method which returns an instance of the
supplied generating class.

=head2 get_generator

Call C<get_generator> with the name of the generator you want to use.
Pass any additional arguments expected by the C<new> method of your
genertor's class.  Example:

    my $generator = Java::Javap::Generator->get_generator( 'Std' );

=head1 GENERATOR API

Each generator must live in the Java::Javap::Generator:: namespace and
must implement two methods:

=head2 new

A constructor called by C<get_generator> in this module.  Your constructor
will receive all of the parameters passed to C<get_generator>, except
the name of the subclass (but C<new> is invoked through the fully
qualified subclass name, so you get that too).

C<java2perl6> allows callers to supply these parameters as a string on the
command line with the C<-p> (or C<--genopts>) flag, whose value is split
on whitespace before the call.

=head2 generate

This method returns a single string containing the full text of a Perl
module corresponding to the abstract syntax tree of a Java module.
Someone else will decide what to do with the output, all you need to do
is make the string.

Parameters are supplied to your C<generate> in a single hash reference.
These are the ones supplied by the C<java2perl6> command line tool:

=over 4

=item class_file

The name of the Java .class file which was run through javap.

=item ast

The abstract syntax tree made from the class file by C<Java::Javap::Grammar>.

=item javap_flags

The command line flags passed to javap (like -classpath ...).  These
are included so you can dump them into a comment in the generated output.

=back

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

