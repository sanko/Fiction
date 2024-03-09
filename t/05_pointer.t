use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use Config;    # Check for multiplicity support
$|++;
#
my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c
typedef void cb(void);
void fn(cb *callback) {
    callback();
}
void snag(){
    warn("Inside the snag");
}


typedef void (*ptr)(void);


void * getfn() {
warn("Inside getfn");
    return &snag;
}
END
use Data::Dump;
#
ddx Pointer [SV];
ddx Pointer [Void];

#~ 'typedef void cb(void)' => <<'', [ Callback [ [] => Void ] ], Void, [], U(), U();
ddx Affix::find_symbol $lib, 'snag';
ddx Affix::affix $lib,       'snag';
ddx Affix::affix $lib,       'getfn', [], Pointer [Void];
my $fn = getfn();
warn $fn;
ddx $fn;
$fn->dump(16);

#~ my $sub = $fn->cast(Pointer[Int]);
#~ snag();
#
subtest 'Pointer[Void]' => sub {
    subtest scalar => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Void], 'This is a test' ), ['Affix::Pointer'], 'This is a test';
        is $ptr->raw( Affix::Platform::SIZEOF_CHAR() * 14 ), 'This is a test', '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() * 14 . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Void], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
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
        $ptr->dump(8);
        is $ptr->sv,                                        '97',  '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_CHAR() ) ], ['9'], '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest "'97'" => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], '97' ), ['Affix::Pointer'], "'97'";
        $ptr->dump(1);
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
        $ptr->dump(40);
        is $ptr->sv,                                         'This is a string of text.', '$ptr->sv';
        is $ptr->raw( 25 * Affix::Platform::SIZEOF_CHAR() ), 'This is a string of text.', '$ptr->raw( ' . 25 * Affix::Platform::SIZEOF_CHAR() . ' )';
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
        $ptr->dump(8);
        is $ptr->sv,                                         '97',  '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_UCHAR() ) ], ['9'], '$ptr->raw( ' . Affix::Platform::SIZEOF_UCHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest "'97'" => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UChar], '97' ), ['Affix::Pointer'], "'97'";
        $ptr->dump(1);
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
        $ptr->dump(8);
        is $ptr->sv,                                     'a', '$ptr->sv';
        is $ptr->raw( Affix::Platform::SIZEOF_UCHAR() ), 'a', '$ptr->raw( ' . Affix::Platform::SIZEOF_UCHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest string => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [UChar], 'This is a string of text.' ), ['Affix::Pointer'], 'This is...';
        $ptr->dump(30);
        $ptr->dump(40);
        is $ptr->sv, 'This is a string of text.', '$ptr->sv';
        is $ptr->raw( 25 * Affix::Platform::SIZEOF_UCHAR() ), 'This is a string of text.',
            '$ptr->raw( ' . 25 * Affix::Platform::SIZEOF_UCHAR() . ' )';
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 's*', $ptr->raw( 21 * Affix::Platform::SIZEOF_SHORT() ) ], [ 150 .. 170 ],
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'S*', $ptr->raw( 21 * Affix::Platform::SIZEOF_USHORT() ) ], [ 150 .. 170 ],
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'i*', $ptr->raw( 21 * Affix::Platform::SIZEOF_INT() ) ], [ 150 .. 170 ],
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'I*', $ptr->raw( 21 * Affix::Platform::SIZEOF_UINT() ) ], [ 150 .. 170 ],
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'l!*', $ptr->raw( 21 * Affix::Platform::SIZEOF_LONG() ) ], [ 150 .. 170 ],
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'L!*', $ptr->raw( 21 * Affix::Platform::SIZEOF_ULONG() ) ], [ 150 .. 170 ],
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
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'q*', $ptr->raw( 21 * Affix::Platform::SIZEOF_LONGLONG() ) ], [ 150 .. 170 ],
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
            $ptr->dump(40);
            is $ptr->sv, [ 150 .. 170 ], '$ptr->sv';
            is [ unpack 'Q*', $ptr->raw( 21 * Affix::Platform::SIZEOF_ULONGLONG() ) ], [ 150 .. 170 ],
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
subtest 'Pointer[Float]' => sub {
    subtest 5.3 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Float], 5.3 ), ['Affix::Pointer'], '5';
        is $ptr->sv, float( 5.3, tolerance => 0.001 ), '$ptr->sv';
        is unpack( 'f', $ptr->raw( Affix::Platform::SIZEOF_FLOAT() ) ), float( 5.3, tolerance => 0.001 ),
            '$ptr->raw( ' . Affix::Platform::SIZEOF_FLOAT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Float], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 1.2, 2.3, 3, 4.5, 9.75 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Float], [ 1.2, 2.3, 3, 4.5, 9.75 ] ), ['Affix::Pointer'], '[ 1.2, 2.3, 3, 4.5, 9.75 ]';
            $ptr->dump(88);
            $ptr->dump(40);
            is $ptr->sv,
                [
                float( 1.2,  tolerance => 0.001 ),
                float( 2.3,  tolerance => 0.001 ),
                float( 3,    tolerance => 0.001 ),
                float( 4.5,  tolerance => 0.001 ),
                float( 9.75, tolerance => 0.001 )
                ],
                '$ptr->sv';
            is [ unpack 'f*', $ptr->raw( 5 * Affix::Platform::SIZEOF_FLOAT() ) ],
                [
                float( 1.2,  tolerance => 0.001 ),
                float( 2.3,  tolerance => 0.001 ),
                float( 3,    tolerance => 0.001 ),
                float( 4.5,  tolerance => 0.001 ),
                float( 9.75, tolerance => 0.001 )
                ],
                '$ptr->raw( ' . 5 * Affix::Platform::SIZEOF_FLOAT() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Float], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
subtest 'Pointer[Double]' => sub {
    subtest 5.3 => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Double], 5.3 ), ['Affix::Pointer'], '5';
        is $ptr->sv, float( 5.3, tolerance => 0.001 ), '$ptr->sv';
        is unpack( 'd', $ptr->raw( Affix::Platform::SIZEOF_DOUBLE() ) ), float( 5.3, tolerance => 0.001 ),
            '$ptr->raw( ' . Affix::Platform::SIZEOF_DOUBLE() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest undef => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Double], undef ), ['Affix::Pointer'], 'undef';
        $ptr->dump(16);
        is $ptr->sv, U(), '$ptr->sv is undef';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest list => sub {
        subtest '[ 1.2, 2.3, 3, 4.5, 9.75 ]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Double], [ 1.2, 2.3, 3, 4.5, 9.75 ] ), ['Affix::Pointer'], '[ 1.2, 2.3, 3, 4.5, 9.75 ]';
            $ptr->dump(88);
            $ptr->dump(40);
            is $ptr->sv,
                [
                float( 1.2,  tolerance => 0.001 ),
                float( 2.3,  tolerance => 0.001 ),
                float( 3,    tolerance => 0.001 ),
                float( 4.5,  tolerance => 0.001 ),
                float( 9.75, tolerance => 0.001 )
                ],
                '$ptr->sv';
            is [ unpack 'd*', $ptr->raw( 5 * Affix::Platform::SIZEOF_DOUBLE() ) ],
                [
                float( 1.2,  tolerance => 0.001 ),
                float( 2.3,  tolerance => 0.001 ),
                float( 3,    tolerance => 0.001 ),
                float( 4.5,  tolerance => 0.001 ),
                float( 9.75, tolerance => 0.001 )
                ],
                '$ptr->raw( ' . 5 * Affix::Platform::SIZEOF_DOUBLE() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Double], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
note 'String => Pointer[Const[Char]]';
subtest 'String' => sub {
    subtest 97 => sub {
        isa_ok my $ptr = Affix::sv2ptr( String, 97 ), ['Affix::Pointer'], '97';
        $ptr->dump(1);
        $ptr->dump(8);
        is $ptr->sv,                                        '97',  '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_CHAR() ) ], ['9'], '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest "'97'" => sub {
        isa_ok my $ptr = Affix::sv2ptr( String, '97' ), ['Affix::Pointer'], "'97'";
        $ptr->dump(1);
        $ptr->dump(3);
        use Data::Dump;
        ddx $ptr->sv;
        is $ptr->sv,                                            '97',   '$ptr->sv';
        is [ $ptr->raw( Affix::Platform::SIZEOF_CHAR() * 2 ) ], ['97'], '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() * 2 . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest 'a' => sub {
        isa_ok my $ptr = Affix::sv2ptr( String, 'a' ), ['Affix::Pointer'], 'a';
        $ptr->dump(1);
        $ptr->dump(8);
        is $ptr->sv,                                    'a', '$ptr->sv';
        is $ptr->raw( Affix::Platform::SIZEOF_CHAR() ), 'a', '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest string => sub {
        isa_ok my $ptr = Affix::sv2ptr( String, 'This is a string of text.' ), ['Affix::Pointer'], 'This is...';
        $ptr->dump(30);
        $ptr->dump(40);
        is $ptr->sv,                                         'This is a string of text.', '$ptr->sv';
        is $ptr->raw( 25 * Affix::Platform::SIZEOF_CHAR() ), 'This is a string of text.', '$ptr->raw( ' . 25 * Affix::Platform::SIZEOF_CHAR() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest utf8 => sub {
        subtest 'emoji' => sub {
            isa_ok my $ptr = Affix::sv2ptr( String, '😀🫠☝🏽🫱🏽‍🫲🏼 This works.' ), ['Affix::Pointer'], '😀🫠☝🏽🫱🏽‍🫲🏼 This works.';
            $ptr->dump(16);
            is $ptr->sv, '😀🫠☝🏽🫱🏽‍🫲🏼 This works.', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'korean' => sub {
            isa_ok my $ptr = Affix::sv2ptr( String, '안녕하세요' ), ['Affix::Pointer'], '안녕하세요';
            $ptr->dump(16);
            is $ptr->sv, '안녕하세요', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'japanese' => sub {
            isa_ok my $ptr = Affix::sv2ptr( String, 'こんにちは' ), ['Affix::Pointer'], 'こんにちは';
            $ptr->dump(16);
            is $ptr->sv, 'こんにちは', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'russian' => sub {
            isa_ok my $ptr = Affix::sv2ptr( String, 'Здравствуйте' ), ['Affix::Pointer'], 'Здравствуйте';
            $ptr->dump(16);
            is $ptr->sv, 'Здравствуйте', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'hebrew' => sub {
            isa_ok my $ptr = Affix::sv2ptr( String, 'תקן בבקשה את הטעויות שלי בעברית.' ), ['Affix::Pointer'], 'תקן בבקשה את הטעויות שלי בעברית.';
            $ptr->dump(16);
            is $ptr->sv, 'תקן בבקשה את הטעויות שלי בעברית.', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'arabic' => sub {
            isa_ok my $ptr = Affix::sv2ptr( String, 'انا لا اتكلم العربية' ), ['Affix::Pointer'], 'انا لا اتكلم العربية';
            $ptr->dump(16);
            is $ptr->sv, 'انا لا اتكلم العربية', '$ptr->sv';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest 'compiled lib' => sub {
            my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c

DLLEXPORT int ptr(char * line) {
    return strlen(line);
}
END
            ok Affix::affix( $lib => 'ptr', [ Pointer [Char] ] => Int ), 'int ptr(char *)';
            is ptr('This is a quick test.'), 21, 'C understood we have a line of text containing 21 chars';
        };
    };
};
subtest 'Pointer[Pointer[Char]]' => sub {
    isa_ok my $ptr = Affix::sv2ptr( Pointer [ Pointer [Char] ], [ 'This is a string of text.', 'More', 'And Even More', undef ] ),
        ['Affix::Pointer'], 'load list of 3 strings';
    is $ptr->sv, [ 'This is a string of text.', 'More', 'And Even More', undef ], '$ptr->sv';
    subtest 'compiled lib' => sub {
        my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c

DLLEXPORT int ptrptr(char ** lines) {
    int i = 0;
    while (lines[i] != NULL && i < 30) { // Fallback is 30
        warn("    # [%d] %s", i, lines[i]);
        i++;
    }
    return i;
}

END
        diag '$lib: ' . $lib;
        ok my $_lib = load_library($lib), 'lib is loaded [debugging]';
        diag $_lib;
        ok Affix::affix( $lib => 'ptrptr', [ Pointer [ Pointer [Char] ] ] => Int ), 'int ptrptr(char **)';
        is ptrptr($ptr), 3, 'C understood we have 3 lines of text';

        #~ is Nothing(), 99, 'Nothing()';
    };
};
subtest '...why would you do this?' => sub {
    subtest 'Pointer[SV]' => sub {
        use ExtUtils::Embed;
        my $flags = `$^X -MExtUtils::Embed -e ccopts -e ldopts`;
        $flags =~ s[\R][ ]g;
        my $lib = compile_test_lib( <<'END', $flags );
#line 730 "05_pointer.t"
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "std.h"

// ext: .c
DLLEXPORT SV* inc(SV * arg) {
    dTHX;
    sv_inc(arg);
    return arg;
}
END
        diag '$lib: ' . $lib;
        ok my $_lib = load_library($lib),                                   'lib is loaded [debugging]';
        ok Affix::affix( $lib => 'inc', [ Pointer [SV] ] => Pointer [SV] ), 'SV* inc(SV *)';
        my $name = 'John';
        is inc($name), 'Joho', 'sv passed and returned from symbol';
        is $name,      'Joho', 'sv was modified in place';
    };
};

#define CODEREF_FLAG '&'
#define UNION_FLAG 'u'
#define STRUCT_FLAG 'A'
#define CPPSTRUCT_FLAG 'B'
#
#define WCHAR_FLAG 'w'
#define STDSTRING_FLAG 'Y'
done_testing;
