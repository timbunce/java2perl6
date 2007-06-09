package Java::Javap::Generator::TT;
use strict; use warnings;

use Template;
use Java::Javap;
use Java::Javap::TypeCast;

sub new {
    my $class   = shift;
    my $tt_args = shift || { INCLUDE_PATH => 'templates:.', POST_CHOMP => 1 };

    my $self    = bless { }, $class;
    $self->tt_args_set( $tt_args );

    return $self;
}

sub tt_args_set {
    my $self = shift;
    my $args = shift;

    $self->{__TT_ARGS__} = $args;
}

sub tt_args {
    my $self = shift;
    return $self->{__TT_ARGS__};
}

sub generate {
    my $self       = shift;
    my $class_file = shift;
    my $ast        = shift;
    my $template   = shift;

    my $tt         = Template->new( $self->tt_args );

    my $tt_vars = {
        ast        => $ast,
        gen_time   => scalar localtime(),
        version    => $Java::Javap::VERSION,
        class_file => $class_file,
        type_caster=> Java::Javap::TypeCast->new(),
        command_line_flags => [
            '--classpath testjavas',
        ],
    };

    my $retval;
    $tt->process( $template, $tt_vars, \$retval ) || die $tt->error();

    return $retval;
}

1;

=head1 NAME

Java::Javap::Generator::TT - uses TT to spit out Perl 6

=head1 SYNOPSIS

    useJava::Javap::Generator; 
    my $gen = Java::Javap::Generator->get_generator( 'TT', \%tt_args );
    my $output = $gen->generate(
            'com.example.InterfaceName',
            $tree,
            $template
    );

where C<$tree> is a Java::Javap abstract syntax tree (AST).

=head1 DESCRIPTION

This is a generator which uses TT to make output.

=head1 METHODS

=over 4

=item get_generator

Call this as a class method on C<Java::Javap::Generator>.  Pass it
C<TT> to ask it for an instance of this class.  Also (optionally)
pass it a hash reference of Template Toolkit constructor arguments.
These are passed directory to C<Template>'s C<new> method, so see
its docs for what is allowed.

If you do not supply TT constructor arguments, you will get these by
default:

    {
        INCLUDE_PATH => 'templates:.',
        POST_CHOMP   => 1
    }

=item generate

This is the workhorse of this module.  It takes information about your
java .class file and generates Perl 6 code.  Actually, what it generates
depends entirely on the TT template you supply.  That could be Perl 5
or even (horrors) Python or Ruby code.

Parameters:

    class_file - for documentation, the name of the java .class file
    ast        - the syntax tree you got from the parser
    template   - the name of a TT template

Use C<Java::Javap::Grammar> to generate the ast.  The template
will have to live in the current directory or a subdirectory of it
called 'templates', unless you pass TT constructor args.

The template fully controls the output.

=item new

For use by C<Java::Javap::Generator>.  You could call it directly, passing
it the TT constructor arguments as described above.  That would bypass
the factory.

=item tt_args_set

Accessor for changing the TT constructor arguments.  You may call this
at any time.  The C<new> method uses this accessor.

Since C<generate> makes a new TT object for each call, any changes you
make via this method will apply to subsequent calls.

=item tt_args

Accessr for getting the TT constructor arguments.  Mainly for internal
use.

=back

=head1 EXPORT

Nothing, it's all OO

=head2 SEE ALSO

    Java::Javap::Generator
    Java::Javap
    Java::Javap::Grammar

=head1 AUTHOR

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
