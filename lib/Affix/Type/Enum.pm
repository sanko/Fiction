package Affix::Type::Enum 0.5 {
    use strict;
    use warnings;
    use parent 'Exporter';
    our ( @EXPORT_OK, %EXPORT_TAGS );
    $EXPORT_TAGS{all} = [ @EXPORT_OK = qw[Enum IntEnum UIntEnum CharEnum] ];
    {
        @Affix::Type::Enum::ISA    = 'Affix::Type';
        @Affix::Type::IntEnum::ISA = @Affix::Type::UIntEnum::ISA = @Affix::Type::CharEnum::ISA = 'Affix::Type::Enum';
    }

    sub _Enum : prototype($) {
        my (@elements) = @{ +shift };
        my $text;
        my $index = 0;
        my $enum;
        my $tmp = {};
        for my $element (@elements) {
            ( $element, $index ) = @$element if ref $element eq 'ARRAY';
            if ( $index =~ /[+|-|\*|\/|^|%|\D]/ ) {
                $index =~ s[(\w+)][$tmp->{$1}//$1]xeg;
                $index = eval $index;
            }
            $tmp->{$element} = $index;
            push @$enum, [ $element, $index ];
            push @$text, sprintf '%s => %s', $element, $index++;
        }
        return $text, $enum;
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
            push @$text, sprintf '%s => %s', $element, $index++;
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
        for my $index ( 0 .. $#{ $self->[5] } ) {
            *{ $name . '::' . $self->[5][$index][0] } = sub () {
                bless [ ( map { $self->[$_] } 0 .. 5 ), $index ], 'Affix::Type::Enum::Magic';
            };
        }
        1;
    }

    sub magic : prototype($) {
        $_[0] = bless shift, 'Affix::Type::Enum::Magic';
    }

    package Affix::Type::Enum::Magic {
        use overload
            fallback => 1,

            # https://perldoc.perl.org/overload#Minimal-Set-of-Overloaded-Operations
            '+' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            my $index = $self->[6] + $a;
            warn $index;
            $self->[6] = $index %= scalar @{ $self->[5] };
            $self;
            },
            '++' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            my $index = $self->[6] + 1;
            $self->[6] = $index %= scalar @{ $self->[5] };
            $self;
            },
            '--' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            my $index = $self->[6] + 1;
            $self->[6] = $index %= scalar @{ $self->[5] };
            $self;
            },
            '*=' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            my $index = $self->[6] *= $a;
            $self->[6] = $index %= scalar @{ $self->[5] };
            $self;
            },
            '-=' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            my $index = $self->[6] -= $a;
            $self->[6] = $index %= scalar @{ $self->[5] };
            $self;
            },
            '+=' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            my $index = $self->[6] += $a;
            $self->[6] = $index %= scalar @{ $self->[5] };
            $self;
            },
            #
            '""' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            $self->[5]->[ $self->[6] ][0];
            },
            'int' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            $self->[5][ $self->[6] ][1];
            },
            '0+' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            $self->[5][ $self->[6] ][1];
            },
            'bool' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            !!$self->[5][ $self->[6] ][1];
            },
            #
            '~~' => sub : prototype($$$) {
            my ( $self, $a, $b ) = @_;
            ...;
            };
    }
};
1;
