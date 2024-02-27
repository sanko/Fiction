use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
sub build_and_test {
    my ( $name, $c, $arg_types, $ret_type, $arg1, $ret, $ret_check ) = @_;
    subtest $name => sub {
        plan 4;
        ok my $lib    = compile_test_lib($c), 'build test lib';
        isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $fn = ...';
        is $fn->(
            sub {
                is \@_, $arg1, '@_ in $fn is correct';
                return $ret;
            }
            ),
            $ret_check, 'return from $fn->(sub {[...]}) is correct';
    }
}
#
build_and_test
    'typedef void cb(void)' => <<'', [ Callback [ [] => Void ] ], Void, [], U(), U();
#include "std.h"
// ext: .c
typedef void cb(void);
void fn(cb *callback) {
    callback();
}

subtest bool => sub {
    build_and_test
        'typedef bool cb(bool) false' => <<'', [ Callback [ [Bool] => Bool ] ], Bool, [ F() ], !1, F();
#include "std.h"
// ext: .c
typedef bool cb( bool );
bool fn(cb *callback) {
    return callback(false);
}

    build_and_test
        'typedef bool cb(bool) true' => <<'', [ Callback [ [Bool] => Bool ] ], Bool, [ T() ], !0, T();
#include "std.h"
// ext: .c
typedef bool cb( bool );
bool fn(cb *callback) {
    return callback(true);
}

};
subtest char => sub {
    build_and_test
        'typedef char cb(char)' => <<'', [ Callback [ [Char] => Char ] ], Char, ['a'], 'm', 'm';
#include "std.h"
// ext: .c
typedef char cb( char );
char fn(cb *callback) {
    return callback('a');
}

    build_and_test
        'typedef signed char cb(char)' => <<'', [ Callback [ [Char] => Char ] ], Char, [ pack 'C', -ord 'a' ], 'm', 'm';
#include "std.h"
// ext: .c
typedef char cb( char );
char fn(cb *callback) {
    return callback(-'a');
}

    build_and_test
        'typedef char cb(char) with ints' => <<'', [ Callback [ [Char] => Char ] ], Char, ['a'], 109, 'm';
#include "std.h"
// ext: .c
typedef char cb( char );
char fn(cb *callback) {
    return callback(97);
}

};
subtest schar => sub {
    build_and_test
        'typedef signed char cb(char)' => <<'', [ Callback [ [SChar] => SChar ] ], Char, ['a'], 'm', 'm';
#include "std.h"
// ext: .c
typedef signed char cb( signed char );
signed char fn(cb *callback) {
    return callback('a');
}

    build_and_test
        'typedef signed char cb(char)' => <<'', [ Callback [ [SChar] => SChar ] ], SChar, [ pack 'c', -ord 'a' ], 'm', 'm';
#include "std.h"
// ext: .c
typedef signed char cb( signed char );
signed char fn(cb *callback) {
    return callback(-'a');
}

    build_and_test
        'typedef signed char cb(char) with ints' => <<'', [ Callback [ [SChar] => SChar ] ], SChar, ['a'], 109, 'm';
#include "std.h"
// ext: .c
typedef signed char cb( signed char );
signed char fn(cb *callback) {
    return callback(97);
}

};
subtest uchar => sub {
    build_and_test
        'typedef unsigned char cb(unsigned char)' => <<'', [ Callback [ [UChar] => UChar ] ], UChar, ['a'], 'm', 'm';
#include "std.h"
// ext: .c
typedef signed char cb( unsigned char );
unsigned char fn(cb *callback) {
    return callback('a');
}

    build_and_test
        'typedef unsigned char cb(unsigned char) with ints' => <<'', [ Callback [ [UChar] => UChar ] ], UChar, ['a'], 109, 'm';
#include "std.h"
// ext: .c
typedef unsigned char cb( unsigned char );
unsigned char fn(cb *callback) {
    return callback(97);
}

};

#define WCHAR_FLAG 'w'
subtest short => sub {
    build_and_test
        'typedef short cb(short, short)' => <<'', [ Callback [ [ Short, Short ] => Short ] ], Short, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef short cb(short, short);
short fn(cb *callback) {
    return callback(100, 200);
}

};
subtest ushort => sub {
    build_and_test
        'typedef unsigned short cb(unsigned short, unsigned short)' =>
        <<'', [ Callback [ [ UShort, UShort ] => UShort ] ], UShort, [ 100, 200 ], 500, 500;
#include "std.h"
// ext: .c
typedef short cb(unsigned short, unsigned short);
unsigned short fn(cb *callback) {
    return callback(100, 200);
}

};
subtest int => sub {
    build_and_test
        'typedef int cb(int, int)' => <<'', [ Callback [ [ Int, Int ] => Int ] ], Int, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef int cb(int, int);
int fn(cb *callback) {
    return callback(100, 200);
}

};
subtest uint => sub {
    build_and_test
        'typedef unsigned int cb(unsigned int, unsigned int)' => <<'', [ Callback [ [ UInt, UInt ] => UInt ] ], UInt, [ 100, 200 ], 600, 600;
#include "std.h"
// ext: .c
typedef int cb(unsigned int, unsigned int);
unsigned int fn(cb *callback) {
    return callback(100, 200);
}

};

#define UINT_FLAG 'j'
#define LONG_FLAG 'l'
#define ULONG_FLAG 'm'
#define LONGLONG_FLAG 'x'
#define ULONGLONG_FLAG 'y'
#define SSIZE_T_FLAG LONGLONG_FLAG
#define SIZE_T_FLAG ULONGLONG_FLAG
#define FLOAT_FLAG 'f'
subtest double => sub {
    build_and_test
        'typedef double cb(double, double)' =>
        <<'', [ Callback [ [ Double, Double ] => Double ] ], Double, [ float( 1.5, tolerance => 0.01 ), float( 3.98, tolerance => 0.01 ) ], 4.3, float( 4.3, tolerance => 0.01 );
#include "std.h"
// ext: .c
typedef double cb(double, double);
double fn(cb *callback) {
    return callback(1.5, 3.98);
}

};

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
