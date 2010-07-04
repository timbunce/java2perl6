package Java::Javap::TypeCast;

=head1 NAME

Java::Javap::TypeCast - map Java types to Perl 6 equivalents

=head1 SYNOPSIS

    use Java::Javap::TypeCast;

    $type_caster = Java::Javap::TypeCast->new();

    $perl_type   = $type_caster->cast( $java_type );

=head1 DESCRIPTION

Provides a mechanism to map java type names (classes and interfaces) into
corresponding perl type names (typically roles).

=head1 METHODS

=cut

use strict;
use warnings;

use Carp;

=head2 new

    $type_caster = Java::Javap::TypeCast->new();

Returns a new type caster instance with a default set of type casts.

The default set of type mappings should I<not> be relied upon as it's likely to
change over time with unpredictable results for your application. You should call
L</set_type_casts> and perhaps a method like L</add_type_casts_from_file> to
load in your own set of type mappings.

=cut

sub new {
    my $class = shift;
    my $self = bless { }, $class;
    $self->_add_type_casts_from_DATA();
    return $self;
}

=head2 set_type_casts

    $self->set_type_casts(\%hash)

Replaces the current set of type casts with the specified set.

=cut

sub set_type_casts {
    my ($self, $new_casts) = @_;
    $self->{casts} = { %$new_casts };
    return;
}


=head2 add_type_casts

    $self->add_type_casts(\%hash)

Adds the specified set of type casts to the current set, overriding any that
have the same names.

=cut

sub add_type_casts {
    my ($self, $new_casts) = @_;
    $self->{casts}{$_} = $new_casts->{$_}
        for keys %$new_casts;
    return;
}


=head2 add_type_casts_from_filehandle

    $self->add_type_casts_from_filehandle($fh, $name)

Reads lines defining type mappings from the specified filehandle.
Each is specified as two non-blank fields separated by whitespace.
The first specified a Java type and the second a corresponding Perl type.
Comments starting with a # character are ignored, as are blank lines.

A warning is issued for lines that aren't in the correct format.
The $name argument is only used in that warnig message.

=cut

sub add_type_casts_from_filehandle {
    my ($self, $fh, $name) = @_;
    while (<$fh>) {
        chomp;
        s/#.*//;             # remove comments
        next if m/^ \s* $/x; # ignore blank lines
        my @items = split /\s+/;
        if (@items != 2) {
            warn "Ignored line $. in $name: $_\n";
            next;
        }
        my ($javatype, $perltype) = @items;
        $self->{casts}{$javatype} = $perltype;
    }
}

=head2 add_type_casts_from_file

    $self->add_type_casts_from_file($filename)

Opens $filename for reading and calls L</add_type_casts_from_filehandle>.

=cut

sub add_type_casts_from_file {
    my ($self, $filename) = @_;
    open my $fh, '<', $filename
        or croak "Unable to open '$filename' for reading: $!";
    return $self->add_type_casts_from_filehandle($fh, $filename);
}


# _add_type_casts_from_DATA - private

sub _add_type_casts_from_DATA {
    my ($self, $filename) = @_;
    local $.; # don't add chunk/filename to future warning messages
    my $position = tell( DATA );
    $self->add_type_casts_from_filehandle(\*DATA, 'default DATA');
    seek DATA, $position, 0; # Reset the filehandle for next time
    return;
}


=head2 cast

    $perl_type = $type_caster->cast( $java_type );

Returns a perl type for the corresponding java type argument.

Firstly java type is looked up in the type mapping. If a defined value is found
then it's returned.

If there's no explicit match for the full type name then cast() checks for
wildcard matches by removing trailing words and appending a '*'. For example,
if there's no entry for 'sun.lang.annotation.foo' the cast() would look for
each of these in turn:

    sun.lang.annotation.foo
    sun.lang.annotation.*
    sun.lang.*
    sun.*
    *

If no match is found then cast() calls fallback_cast().

=cut

sub cast {
    my $self      = shift;
    my $java_type = shift;
  
    my $casts = $self->{casts};

    my $perl6_type = $casts->{ $java_type };

    if (not defined $perl6_type) {
        # no specific type cast so look for wildcard ones
        my @parts = split /\./, $java_type;
        while (@parts) {
            $parts[-1] = '*'; # replace last word with *
            $perl6_type = $casts->{ join '.', @parts };
            last if defined $perl6_type;
            pop @parts;
        }
    }

    if (not defined $perl6_type) {
        $perl6_type = $self->fallback_cast($java_type);
    }

    return $perl6_type;
}


=head2 fallback_cast()

    $perl_type = $type_caster->cast( $java_type );

Returns a perl type for the corresponding java type argument by editing the
java type name, without consulting the type mapping.
 
 - dots are changed to double colons
 - dollar symbols are changed to _PRIVATE_

=cut

sub fallback_cast {
    my $self      = shift;
    my $java_type = shift;

    (my $perl6_type = $java_type) =~ s/\./::/g;
    $perl6_type =~ s/\$/_PRIVATE_/g; # handle '$' in type names

    return $perl6_type;
}


=head1 AUTHOR

Tim Bunce, E<lt>tim.bunce@pobox.comE<gt>,
Phil Crow, E<lt>crow.phil@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010, Tim Bunce
Copyright (C) 2007, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

__DATA__

# References
# http://perlcabal.org/syn/S02.html#Built-In_Data_Types
# http://perlcabal.org/syn/S32/ 'Settings library' (containers, numeric, io etc)

# XXX these are quite vague and very likely to change
# XXX do not rely on these defaults

# --- java native types ---
# http://java.sun.com/docs/books/tutorial/java/nutsandbolts/datatypes.html
# these will change to perl6's native types when rakudo supports them
int                Int
long               Int
short              Int
byte               Int
char               Int
float              Num
double             Num
boolean            Bool

# --- java.lang ---
java.lang.Object        Mu
java.lang.Class         Any
java.lang.String        Str
java.lang.Number        Num
java.lang.CharSequence  Str
java.lang.Exception     Mu # XXX Failure?

# --- java.math ---
java.math.BigInteger    Int
java.math.BigNumber     Num
java.math.BigDecimal    Num # XXX Rat when available?

# --- java.util ---
# interfaces:
java.util.Collection    Bag
java.util.Enumeration   Iterable
java.util.Iterator      Any
java.util.Map           Hash # KeyHash?
java.util.Set           Set
# classes:
java.util.Hashtable     Hash # KeyHash?
java.util.Properties    Hash # persistent Hashtable
java.util.Calendar      DateTime
java.util.Date          DateTime
java.util.Time          DateTime
java.util.TimeStamp     DateTime

# --- java.io ---
java.io.InputStream     IO

# --- java.nio ---
java.nio.ByteBuffer     Buf
java.nio.CharBuffer     Str
