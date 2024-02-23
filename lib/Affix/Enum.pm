package Affix::Enum 0.5 {
    use strict;
    use warnings;
    use parent 'Exporter';
    use vars qw[@EXPORT_OK %EXPORT_TAGS];
    $EXPORT_TAGS{all} = [ @EXPORT_OK = qw[Enum IntEnum UIntEnum CharEnum] ];
    use Affix qw[];
    {
        @Affix::Type::Enum::ISA    = 'Affix::Type';
        @Affix::Type::IntEnum::ISA = @Affix::Type::UIntEnum::ISA = @Affix::Type::CharEnum::ISA = 'Affix::Type::Enum';
    }

    sub _Enum : prototype($) {
        my (@elements) = @{ +shift };
        my $text;
        my $index = 0;
        my $enum;
        for my $element (@elements) {
            ( $element, $index ) = @$element if ref $element eq 'ARRAY';
            if ( $index =~ /[+|-|\*|\/|^|%|\D]/ ) {
                $index =~ s[(\w+)][$enum->{$1}//$1]xeg;
                $index = eval $index;
            }
            push @$enum, [ $element, $index ];
            push @$text, sprintf '%s => %s', $element, $index++;
        }
        return $text, $enum;
    }

    sub Enum : prototype($) {
        my ( $text, $enum ) = &_Enum;
        use Data::Dump;
        bless(
            [   sprintf( 'Enum[ %s ]', join ', ', @$text ), Affix::INT_FLAG(), Affix::Platform::SIZEOF_INT(), Affix::Platform::ALIGNOF_INT(), $enum,
                0
            ],
            'Affix::Type::Enum'
        );
    }

    sub IntEnum : prototype($) {
        my ( $text, $enum ) = &_Enum;
        use Data::Dump;
        bless(
            [   sprintf( 'IntEnum[ %s ]', join ', ', @$text ),
                Affix::INT_FLAG(),
                Affix::Platform::SIZEOF_INT(),
                Affix::Platform::ALIGNOF_INT(),
                $enum, 0
            ],
            'Affix::Type::IntEnum'
        );
    }

    sub UIntEnum : prototype($) {
        my ( $text, $enum ) = &_Enum;
        use Data::Dump;
        bless(
            [   sprintf( 'UIntEnum[ %s ]', join ', ', @$text ),
                Affix::UINT_FLAG(),
                Affix::Platform::SIZEOF_UINT(),
                Affix::Platform::ALIGNOF_UINT(),
                $enum, 0
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
                $enum, 0
            ],
            'Affix::Type::CharEnum'
        );
    }

    package Affix::Type::Enum 0.5 {
        #
        use v5.36;
        use overload
            fallback => 1,

            # https://perldoc.perl.org/overload#Minimal-Set-of-Overloaded-Operations
            '+' => sub ( $self, $a, $b ) {
            my $index = $self->[5] + $a;
            warn $index;
            $self->[5] = $index %= scalar @{ $self->[4] };
            use Data::Dump;
            ddx $self;
            $self;
            },
            '++' => sub ( $self, $a, $b ) {
            my $index = $self->[5] + 1;
            $self->[5] = $index %= scalar @{ $self->[4] };
            $self;
            },
            '--' => sub ( $self, $a, $b ) {
            my $index = $self->[5] + 1;
            $self->[5] = $index %= scalar @{ $self->[4] };
            $self;
            },
            '*=' => sub ( $self, $a, $b ) {
            my $index = $self->[5] *= $a;
            $self->[5] = $index %= scalar @{ $self->[4] };
            $self;
            },
            '-=' => sub ( $self, $a, $b ) {
            my $index = $self->[5] -= $a;
            $self->[5] = $index %= scalar @{ $self->[4] };
            $self;
            },
            '+=' => sub ( $self, $a, $b ) {
            my $index = $self->[5] += $a;
            $self->[5] = $index %= scalar @{ $self->[4] };
            $self;
            },
            #
            '""' => sub ( $self, $a, $b ) {
            $self->[4]->[ $self->[5] ][0];
            },
            'int'  => sub ( $self, $a, $b ) { $self->[4][ $self->[5] ][1] },
            '0+'   => sub ( $self, $a, $b ) { $self->[4][ $self->[5] ][1] },
            'bool' => sub ( $self, $a, $b ) { !!$self->[4][ $self->[5] ][1] },
            #
            '~~' => sub ( $self, $a, $b ) {...};

        sub typedef ( $self, $name ) {
            no strict 'refs';
            for my $index ( 0 .. $#{ $self->[4] } ) {
                *{ $name . '::' . $self->[4][$index][0] } = sub () {
                    bless [ ( map { $self->[$_] } 0 .. 4 ), $index ], ref $self;
                };
            }
            1;
        }
    }
};
1;
