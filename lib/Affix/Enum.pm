package Affix::Enum {
    use parent 'Exporter';
    use vars qw[@EXPORT_OK @EXPORT %EXPORT_TAGS];
    $EXPORT_TAGS{all} = [ @EXPORT_OK = qw[Enum] ];

    sub Enum ($) {
        my ($values) = @_;
        my $x = 0;
        $values = [
            map {
                ref $_ eq 'ARRAY' ?
                    sub {
                    $x = $_->[1] + 1;
                    $_;
                    }
                    ->() :
                    [ $_ => $x++ ]
            } @$values
        ];
        bless [ $values, 0 ], 'Affix::Enum';
    }
    #
    use v5.36;
    use overload
        fallback => 1,

        # https://perldoc.perl.org/overload#Minimal-Set-of-Overloaded-Operations
        '+' => sub ( $self, $a, $b ) {
        my $index = $self->[1] + $a;
        $self->[1] = $index %= scalar @{ $self->[0] };
        $self;
        },
        '++' => sub ( $self, $a, $b ) {
        my $index = $self->[1] + 1;
        $self->[1] = $index %= scalar @{ $self->[0] };
        $self;
        },
        '--' => sub ( $self, $a, $b ) {
        my $index = $self->[1] + 1;
        $self->[1] = $index %= scalar @{ $self->[0] };
        $self;
        },
        '*=' => sub ( $self, $a, $b ) {
        my $index = $self->[1] *= $a;
        $self->[1] = $index %= scalar @{ $self->[0] };
        $self;
        },
        '-=' => sub ( $self, $a, $b ) {
        my $index = $self->[1] -= $a;
        $self->[1] = $index %= scalar @{ $self->[0] };
        $self;
        },
        '+=' => sub ( $self, $a, $b ) {
        my $index = $self->[1] += $a;
        $self->[1] = $index %= scalar @{ $self->[0] };
        $self;
        },
        #
        '""' => sub ( $self, $a, $b ) {
        $self->[0]->[ $self->[1] ][0];
        },
        'int'  => sub ( $self, $a, $b ) { $self->[0][ $self->[1] ][1] },
        '0+'   => sub ( $self, $a, $b ) { $self->[0][ $self->[1] ][1] },
        'bool' => sub ( $self, $a, $b ) { !!$self->[0][ $self->[1] ][1] },
        #
        '~~' => sub ( $self, $a, $b ) {...};

    sub typedef ( $self, $name ) {
        no strict 'refs';
        for my $index ( 0 .. $#{ $self->[0] } ) {
            *{ $name . '::' . $self->[0][$index][0] } = sub () {
                bless [ $self->[0], $index ], 'Affix::Enum';
            };
        }
        1;
    }
};
1;
