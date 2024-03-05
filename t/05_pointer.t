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
    subtest utf8 => sub {
        subtest 'emoji' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], '😀🫠☝🏽🫱🏽‍🫲🏼 This works.' ), ['Affix::Pointer'], '😀🫠☝🏽🫱🏽‍🫲🏼 This works.';
            $ptr->dump(16);
            is $ptr->sv, '😀🫠☝🏽🫱🏽‍🫲🏼 This works.', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'korean' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], '안녕하세요' ), ['Affix::Pointer'], '안녕하세요';
            $ptr->dump(16);
            is $ptr->sv, '안녕하세요', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'japanese' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'こんにちは' ), ['Affix::Pointer'], 'こんにちは';
            $ptr->dump(16);
            is $ptr->sv, 'こんにちは', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'russian' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'Здравствуйте' ), ['Affix::Pointer'], 'Здравствуйте';
            $ptr->dump(16);
            is $ptr->sv, 'Здравствуйте', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'hebrew' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'תקן בבקשה את הטעויות שלי בעברית.' ), ['Affix::Pointer'],
                'תקן בבקשה את הטעויות שלי בעברית.';
            $ptr->dump(16);
            is $ptr->sv, 'תקן בבקשה את הטעויות שלי בעברית.', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'arabic' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'انا لا اتكلم العربية' ), ['Affix::Pointer'], 'انا لا اتكلم العربية';
            $ptr->dump(16);
            is $ptr->sv, 'انا لا اتكلم العربية', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
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
        is $ptr->sv,                                                    5, '$ptr->sv';
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
        is $ptr->sv,                                                     5, '$ptr->sv';
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
subtest 'Pointer[UInt]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UInt], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                   5, '$ptr->sv';
        is unpack( 'I', $ptr->raw( Affix::Platform::SIZEOF_UINT() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_UINT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UInt], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [UInt], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'I*', $ptr->raw( 21 * Affix::Platform::SIZEOF_UINT() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_UINT() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [UInt], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
subtest 'Pointer[Long]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Long], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                    5, '$ptr->sv';
        is unpack( 'l!', $ptr->raw( Affix::Platform::SIZEOF_LONG() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_LONG() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Long], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Long], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'l!*', $ptr->raw( 21 * Affix::Platform::SIZEOF_LONG() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_LONG() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Long], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
subtest 'Pointer[ULong]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [ULong], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                     5, '$ptr->sv';
        is unpack( 'L!', $ptr->raw( Affix::Platform::SIZEOF_ULONG() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_ULONG() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [ULong], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [ULong], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'L!*', $ptr->raw( 21 * Affix::Platform::SIZEOF_ULONG() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_ULONG() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [ULong], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
subtest 'Pointer[LongLong]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [LongLong], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                       5, '$ptr->sv';
        is unpack( 'q', $ptr->raw( Affix::Platform::SIZEOF_LONGLONG() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_LONGLONG() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [LongLong], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [LongLong], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'q*', $ptr->raw( 21 * Affix::Platform::SIZEOF_LONGLONG() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_LONGLONG() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [LongLong], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
subtest 'Pointer[ULongLong]' => sub {
    subtest 5 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [ULongLong], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                        5, '$ptr->sv';
        is unpack( 'Q', $ptr->raw( Affix::Platform::SIZEOF_ULONGLONG() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_ULONGLONG() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [ULongLong], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [ULongLong], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
            $ptr->dump(88);
            is $ptr->at(0),         150,  '$ptr->at(0) == 150';
            is $ptr->at(8),         158,  '$ptr->at(8) == 158';
            is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
            $ptr->dump(40);
            is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
            is [ unpack 'Q*', $ptr->raw( 21 * Affix::Platform::SIZEOF_ULONGLONG() ) ], [ 2000, 151 .. 170 ],
                '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_ULONG() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [ULongLong], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};

#define WCHAR_FLAG 'w'
#define LONGLONG_FLAG 'x'
#define ULONGLONG_FLAG 'y'
#define FLOAT_FLAG 'f'
#define DOUBLE_FLAG 'd'
#define STRING_FLAG 'z'
#define WSTRING_FLAG '<'
#define STDSTRING_FLAG 'Y'
#define STRUCT_FLAG 'A'
#define CPPSTRUCT_FLAG 'B'
#define UNION_FLAG 'u'
#define ARRAY_FLAG '@'
#define CODEREF_FLAG '&'
#define POINTER_FLAG 'P'
#define SV_FLAG '?'
done_testing;
