package Java::Javap::TypeCast;

my $type_casts = {
    int                => 'Int',
    float              => 'Num',
    double             => 'Num',
    'java.lang.String' => 'Str',
};

sub set_type_casts {
    my $class   = shift;
    $type_casts = shift;
}

sub get_type_casts {
    return $type_casts;
}

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub cast {
    my $self      = shift;
    my $java_type = shift;

    return $type_casts->{ $java_type } if $type_casts->{ $java_type };

    $java_type    =~ s/\./::/g;

    return $java_type;
}
