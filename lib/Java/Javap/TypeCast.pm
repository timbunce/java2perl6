package Java::Javap::TypeCast;

# http://perlcabal.org/syn/S02.html#Built-In_Data_Types

# XXX these are all quite vague and liable to change XXX
#
my $default_type_casts = {
    # http://java.sun.com/docs/books/tutorial/java/nutsandbolts/datatypes.html
    # these may change to perl6's native types at some point
    int                => 'Int',
    long               => 'Int',
    short              => 'Int',
    byte               => 'Int',
    char               => 'Int',
    float              => 'Num',
    double             => 'Num',
    boolean            => 'Bool',

    'java.lang.Object'      => 'Mu',
    'java.lang.Class'       => 'Any',
    'java.lang.String'      => 'Str',
    'java.lang.Number'      => 'Num',
    'java.lang.CharSequence'=> 'Str',
    'java.lang.Exception'   => 'Mu', # XXX Failure?

    'java.math.BigInteger'  => 'Int',
    'java.math.BigNumber'   => 'Num',
    'java.math.BigDecimal'  => 'Num', # XXX should be Rat when available

    # java.util interfaces:
    'java.util.Collection'  => 'Bag',
    'java.util.Enumeration' => 'Iterable',
    'java.util.Iterator'    => 'Any',
    'java.util.Map'         => 'Hash', # KeyHash?
    'java.util.Set'         => 'Set',
    # java.util classes:
    'java.util.Hashtable'   => 'Hash', # KeyHash?
    'java.util.Properties'  => 'Hash', # persistent Hashtable
    'java.util.Calendar'    => 'DateTime',
    'java.util.Date'        => 'DateTime',
    'java.util.Time'        => 'DateTime',
    'java.util.TimeStamp'   => 'DateTime',

    'java.net.URI'          => 'Str',
    'java.net.URL'          => 'Str',

    'java.io.InputStream'   => 'IO',

    'java.nio.ByteBuffer'   => 'Buf',
    'java.nio.CharBuffer'   => 'Str',
};

sub set_type_casts {
    my ($self, $casts) = @_;
    $self->{casts} = { %$casts };
    return;
}

sub get_type_casts {
    my $casts = shift->{casts};
    return { %$casts };
}

sub new {
    my $class = shift;
    my $self = bless { }, $class;
    $self->set_type_casts($default_type_casts);
    return $self;
}

sub cast {
    my $self      = shift;
    my $java_type = shift;
  
    my $casts = $self->{casts};
    return $casts->{ $java_type } if $casts->{ $java_type };

    # fallback handling of special cases if there's no explicit mapping
    return 'Any' if $java_type =~ m/^sun\.reflect\./;
    return 'Any' if $java_type =~ m/^sun\.lang\.annotation/;
    return 'Any' if $java_type =~ m/^sun\.lang\.reflect/;
    return 'Any' if $java_type =~ m/\$/;

    (my $perl6_type = $java_type) =~ s/\./::/g;
    $perl6_type =~ s/\$/_PRIVATE_/g; # handle '$' in type names

    return $perl6_type;
}

=head1 NAME

Java::Javap::TypeCast - hash mapping common Java types to Perl 6 equivalents

=head1 SYNOPSIS

In a C<Java::Javap::Generator::> module:

    use Java::Javap::TypeCast;

    my $type_caster = Java::Javap::TypeCast->new();

    my $perl_type   = $type_caster->cast( $java_type );

To adjust the type cast table:

    my $current_types = $type_caster->get_types();

    $current_types->{ 'com.example.ShouldBeInt' } = 'Int';

To replace the whole table:

    $type_caster->set_types( { ... } );

=head1 DESCRIPTION

This is a convenience module for C<Java::Javap::Generator::> modules.
They can use it to have a common place to keep conversions of Java
type to Perl 6 types.  But, generators are under no obligation to use
this module.

=head1 METHODS

=over 4

=item new

Constructs a type caster.

Parameters: none

Returns: a TypeCaster object.

=item cast

Parameter: a Java type name

Returns: the Perl conversion, if one is in the hash, or the original
Java type, with dots replaced by double colons, if not.

=item get_type_casts

Returns: the current hash (reference).  Note that this is a class attribute,
so there is only one for all users.

=item set_type_casts

Parameter: a hash reference to use in all future casts.  Again, note that
this is a class attribute, so all instaces share it.

=back

=head1 AUTHOR

Phil Crow, E<lt>crow.phil@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
