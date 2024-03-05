use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
subtest 'Pointer[Void]' => sub {
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Void], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest scalar => sub {
        subtest defined => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Void], 'This is a test' ), ['Affix::Pointer'], 'This is a test';
            $ptr->dump(16);
            is $ptr->sv,                                         'This is a test', '$ptr->sv';
            is $ptr->raw( Affix::Platform::SIZEOF_CHAR() * 14 ), 'This is a test', '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() * 14 . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };

    # TODO: CStruct
};
subtest 'Pointer[Bool]' => sub {
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Bool], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, F(), '$ptr->sv is false';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest true => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Bool], 1 ), ['Affix::Pointer'], 'true';
        $ptr->dump( Affix::Platform::SIZEOF_BOOL() );
        is $ptr->sv,                                    T(),   '$ptr->sv is true';
        is $ptr->raw( Affix::Platform::SIZEOF_BOOL() ), chr 1, '$ptr->raw( ' . Affix::Platform::SIZEOF_BOOL() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest false => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Bool], 0 ), ['Affix::Pointer'], 'false';
        $ptr->dump( Affix::Platform::SIZEOF_BOOL() );
        is $ptr->sv,                                    F(),   '$ptr->sv is false';
        is $ptr->raw( Affix::Platform::SIZEOF_BOOL() ), chr 0, '$ptr->raw( ' . Affix::Platform::SIZEOF_BOOL() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Bool], [ 1, 1, 0, 1, 0, 0 ] ), ['Affix::Pointer'], 'false';
        $ptr->dump( Affix::Platform::SIZEOF_BOOL() * 6 );
        is $ptr->sv,                                        [ T(), T(), F(), T(), F(), F() ], '$ptr->sv';
        is $ptr->raw( Affix::Platform::SIZEOF_BOOL() * 6 ), pack( 'c6', 1, 1, 0, 1, 0, 0 ),   '$ptr->raw( ' . Affix::Platform::SIZEOF_BOOL() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
};
subtest 'Pointer[Char]' => sub {
    subtest 97 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 97 ), ['Affix::Pointer'], '97';
        $ptr->dump(1);
        is $ptr->at(0), 'a', '$ptr->at(0) == a';
        $ptr->dump(8);
        is $ptr->sv,                                        'a',   '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_CHAR() ) ], ['a'], '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest "'97'" => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], '97' ), ['Affix::Pointer'], "'97'";
        $ptr->dump(1);
        is $ptr->at(0), '9', '$ptr->at(0) == 9';
        is $ptr->at(1), '7', '$ptr->at(0) == 7';
        $ptr->dump(3);
        use Data::Dump;
        ddx $ptr->sv;
        is $ptr->sv,                                            '97',   '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_CHAR() * 2 ) ], ['97'], '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() * 2 . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest 'a' => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'a' ), ['Affix::Pointer'], 'a';
        $ptr->dump(1);
        is $ptr->at(0), 'a', '$ptr->at(0) == a';
        $ptr->dump(8);
        is $ptr->sv,                                    'a', '$ptr->sv';
        is $ptr->raw( Affix::Platform::SIZEOF_CHAR() ), 'a', '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest string => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'This is a string of text.' ), ['Affix::Pointer'], 'This is...';
        use Data::Dump;
        ddx $ptr;
        $ptr->dump(30);
        is $ptr->at(0),  'T', '$ptr->at(0) == T';
        is $ptr->at(20), 't', '$ptr->at(20) == t';
        $ptr->dump(40);
        is $ptr->sv,                                         'This is a string of text.', '$ptr->sv';
        is $ptr->raw( 25 * Affix::Platform::SIZEOF_CHAR() ), 'This is a string of text.', '$ptr->raw( ' . 25 * Affix::Platform::SIZEOF_CHAR() . ' )';
        is $ptr->at( 24, '?' ),                              '?',                         '$ptr->at(24, "?") == ?';
        is $ptr->sv,                                         'This is a string of text?', '$ptr->sv after update';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
};
subtest 'Pointer[UChar]' => sub {
    subtest 97 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UChar], 97 ), ['Affix::Pointer'], '97';
        $ptr->dump(1);
        is $ptr->at(0), 'a', '$ptr->at(0) == a';
        $ptr->dump(8);
        is $ptr->sv,                                         'a',   '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_UCHAR() ) ], ['a'], '$ptr->raw( ' . Affix::Platform::SIZEOF_UCHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest "'97'" => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UChar], '97' ), ['Affix::Pointer'], "'97'";
        $ptr->dump(1);
        is $ptr->at(0), '9', '$ptr->at(0) == 9';
        is $ptr->at(1), '7', '$ptr->at(0) == 7';
        $ptr->dump(3);
        use Data::Dump;
        ddx $ptr->sv;
        is $ptr->sv,                                             '97',   '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_UCHAR() * 2 ) ], ['97'], '$ptr->raw( ' . Affix::Platform::SIZEOF_UCHAR() * 2 . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest 'a' => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UChar], 'a' ), ['Affix::Pointer'], 'a';
        $ptr->dump(1);
        is $ptr->at(0), 'a', '$ptr->at(0) == a';
        $ptr->dump(8);
        is $ptr->sv,                                     'a', '$ptr->sv';
        is $ptr->raw( Affix::Platform::SIZEOF_UCHAR() ), 'a', '$ptr->raw( ' . Affix::Platform::SIZEOF_UCHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest string => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UChar], 'This is a string of text.' ), ['Affix::Pointer'], 'This is...';
        $ptr->dump(30);
        is $ptr->at(0),  'T', '$ptr->at(0) == T';
        is $ptr->at(20), 't', '$ptr->at(20) == t';
        $ptr->dump(40);
        is $ptr->sv, 'This is a string of text.', '$ptr->sv';
        is $ptr->raw( 25 * Affix::Platform::SIZEOF_UCHAR() ), 'This is a string of text.',
            '$ptr->raw( ' . 25 * Affix::Platform::SIZEOF_UCHAR() . ' )';
        is $ptr->at( 24, '?' ), '?',                         '$ptr->at(24, "?") == ?';
        is $ptr->sv,            'This is a string of text?', '$ptr->sv after update';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
};



subtest 'Pointer[Short]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Short], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                  5, '$ptr->sv';
        is unpack( 's', $ptr->raw( Affix::Platform::SIZEOF_SHORT() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_SHORT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Short], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Short], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 's*', $ptr->raw( 21 * Affix::Platform::SIZEOF_SHORT() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_SHORT() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Short], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};


subtest 'Pointer[UShort]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UShort], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                  5, '$ptr->sv';
        is unpack( 'S', $ptr->raw( Affix::Platform::SIZEOF_USHORT() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_USHORT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UShort], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [UShort], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'S*', $ptr->raw( 21 * Affix::Platform::SIZEOF_USHORT() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_USHORT() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [UShort], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};











subtest 'Pointer[Int]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                  5, '$ptr->sv';
        is unpack( 'i', $ptr->raw( Affix::Platform::SIZEOF_INT() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_INT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'i*', $ptr->raw( 21 * Affix::Platform::SIZEOF_INT() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_INT() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
done_testing;
