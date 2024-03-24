package Affix::Type::Enum 0.5 {
    use strict;
    use warnings;
    use Carp qw[];
    $Carp::Internal{ (__PACKAGE__) }++;
    use Scalar::Util qw[dualvar];
    use parent 'Exporter';
    our ( @EXPORT_OK, %EXPORT_TAGS );
    $EXPORT_TAGS{all} = [ @EXPORT_OK = qw[Enum IntEnum UIntEnum CharEnum] ];
    {
        @Affix::Type::Enum::ISA    = 'Affix::Type';
        @Affix::Type::IntEnum::ISA = @Affix::Type::UIntEnum::ISA = @Affix::Type::CharEnum::ISA = 'Affix::Type::Enum';
    }

    sub _Enum : prototype($) {
        my (@elements) = @{ +shift };
        my $fields;
        my $index = 0;
        my $enum;
        for my $element (@elements) {
            if ( ref $element eq 'ARRAY' ) {
                ( $element, $index ) = @$element if ref $element eq 'ARRAY';
                push @$fields, sprintf q[[%s => '%s']], $element, $index;
            }
            else {
                push @$fields, qq['$element'];
            }
            if ( $index =~ /[+|-|\*|\/|^|%|\D]/ ) {
                $index =~ s[(\w+)][$enum->{$1}//$1]xeg;
                $index = eval $index;
            }
            $enum->{$element} = $index++;
        }
        return $fields, $enum;
    }

    sub Enum : prototype($) {
        my ( $text, $enum ) = &_Enum;
        bless(
            [   sprintf( 'Enum[ %s ]', join ', ', @$text ),
                Affix::INT_FLAG(),
                Affix::Platform::SIZEOF_INT(),
                Affix::Platform::ALIGNOF_INT(),
                undef, $enum, 0
            ],
            'Affix::Type::Enum'
        );
    }

    sub IntEnum : prototype($) {
        my ( $text, $enum ) = &_Enum;
        bless(
            [   sprintf( 'IntEnum[ %s ]', join ', ', @$text ),
                Affix::INT_FLAG(),
                Affix::Platform::SIZEOF_INT(),
                Affix::Platform::ALIGNOF_INT(),
                undef, $enum, 0
            ],
            'Affix::Type::IntEnum'
        );
    }

    sub UIntEnum : prototype($) {
        my ( $text, $enum ) = &_Enum;
        bless(
            [   sprintf( 'UIntEnum[ %s ]', join ', ', @$text ),
                Affix::UINT_FLAG(),
                Affix::Platform::SIZEOF_UINT(),
                Affix::Platform::ALIGNOF_UINT(),
                undef, $enum, 0
            ],
            'Affix::Type::UIntEnum'
        );
    }

    sub CharEnum : prototype($) {
        my (@elements) = @{ +shift };
        my $text;
        my $index = 0;
        my $enum;
        for my $element (@elements) {
            ( $element, $index ) = @$element if ref $element eq 'ARRAY';
            if ( $index =~ /[+|-|\*|\/|^|%]/ ) {
                $index =~ s[(\w+)][$enum->{$1}//$1]xeg;
                $index =~ s[\b(\D)\b][ord $1]xeg;
                $index = eval $index;
            }
            push @$enum, [ $element, $index =~ /\D/ ? ord $index : $index ];
            push @$text, sprintf '[%s => %s]', $element, $index;
            $index++;
        }
        bless(
            [   sprintf( 'CharEnum[ %s ]', join ', ', @$text ),
                Affix::CHAR_FLAG(),
                Affix::Platform::SIZEOF_CHAR(),
                Affix::Platform::ALIGNOF_CHAR(),
                undef, $enum, 0
            ],
            'Affix::Type::CharEnum'
        );
    }

    sub typedef : prototype($$) {
        my ( $self, $name ) = @_;
        no strict 'refs';
        for my $key ( keys %{ $self->[5] } ) {
            my $val = $self->[5]{$key};
            *{ $name . '::' . $key } = sub () { dualvar $val, $key; };
        }
        1;
    }
};
1;
