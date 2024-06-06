package Affix::Type::Struct 0.5 {
    use strict;
    use warnings;
    use Carp qw[];
    $Carp::Internal{ (__PACKAGE__) }++;
    use Scalar::Util qw[dualvar];
    use parent -norequire, 'Exporter', 'Affix::Type::Parameterized';
    our ( @EXPORT_OK, %EXPORT_TAGS );
    $EXPORT_TAGS{all} = [ @EXPORT_OK = qw[Struct] ];

    sub typedef : prototype($$) {
        my ( $self, $name ) = @_;
        no strict 'refs';
        warn 'TODO: generate mutators';

        #~ for my $key ( keys %{ $self->[5] } ) {
        #~ my $val = $self->[5]{$key};
        #~ *{ $name . '::' . $key } = sub () { dualvar $val, $key; };
        #~ }
        1;
    }

    sub Struct : prototype($) {
        my (@types) = @{ +shift };
        my @fields;
        my $sizeof = 0;
        my $packed = 0;
        my @store;
        for ( my $i = 0; $i < $#types; $i += 2 ) {
            my $field    = $types[$i];
            my $subtype  = $types[ $i + 1 ];
            my $__sizeof = $subtype->sizeof;
            my $__align  = $subtype->align;
            $subtype->[Affix::SLOT_TYPE_OFFSET] = $sizeof + Affix::Platform::padding_needed_for( $sizeof + $__sizeof, $__align );    # offset
            $subtype->[Affix::SLOT_TYPE_FIELD]  = $field;                                                                            # field name
            push @store, $subtype;
            push @fields, sprintf '%s => %s', $field, $subtype;

            #~ warn sprintf 'Before: struct size: %d, element size: %d, align: %d', $sizeof, $__sizeof, $__align;
            $sizeof += $__sizeof + Affix::Platform::padding_needed_for( $sizeof + $__sizeof, $__align );

            #~ warn sprintf 'After:  struct size: %d, element size: %d', $sizeof, $__sizeof;
        }
        bless [
            sprintf( 'Struct[ %s ]', join ', ', @fields ),                                              # SLOT_TYPE_STRINGIFY
            Affix::STRUCT_FLAG(),                                                                       # SLOT_TYPE_NUMERIC
            $sizeof,                                                                                    # SLOT_TYPE_SIZEOF
            $sizeof + Affix::Platform::padding_needed_for( $sizeof, Affix::Platform::BYTE_ALIGN() ),    # SLOT_TYPE_ALIGNMENT
            undef,                                                                                      # SLOT_TYPE_OFFSET
            \@store,                                                                                    # SLOT_TYPE_SUBTYPE
            1,                                                                                          # SLOT_TYPE_ARRAYLEN
            !1,                                                                                         # SLOT_TYPE_CONST
            !1,                                                                                         # SLOT_TYPE_VOLATILE
            !1,                                                                                         # SLOT_TYPE_RESTRICT
            undef,                                                                                      # SLOT_TYPE_TYPEDEF
            undef,                                                                                      # SLOT_TYPE_AGGREGATE
            undef                                                                                       # SLOT_TYPE_FIELD
            ],
            'Affix::Type::Struct';
    }
};
1;
