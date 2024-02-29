use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use utf8;
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
                diag $ret;
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
        'typedef signed char cb(char)' => <<'', [ Callback [ [Char] => Char ] ], Char, [ pack 'c', -ord 'a' ], 'm', 'm';
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
subtest wchar_t => sub {
    my $todo = todo 'wchar_t is a mess on *BSD and macOS. See https://www.gnu.org/software/libunistring/manual/html_node/The-wchar_005ft-mess.html'
        if Affix::Platform::macOS() ||
        Affix::Platform::FreeBSD()  ||
        Affix::Platform::OpenBSD()  ||
        Affix::Platform::NetBSD()   ||
        Affix::Platform::DragonFlyBSD() ||
        Affix::Platform::ARM();
    build_and_test
        'typedef wchar_t cb(wchar_t)' => <<'', [ Callback [ [WChar] => WChar ] ], WChar, ['愛'], '絆', '絆';
#include "std.h"
// ext: .c
typedef wchar_t cb( wchar_t );
unsigned char fn(cb *callback) {
    fflush(stdout);
    return callback(L'愛');
}

};
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
subtest long => sub {
    build_and_test
        'typedef long cb(long, long)' => <<'', [ Callback [ [ Long, Long ] => Long ] ], Long, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef long cb(long, long);
long fn(cb *callback) {
    return callback(100, 200);
}

};
subtest ulong => sub {
    build_and_test
        'typedef unsigned long cb(unsigned long, unsigned long)' => <<'', [ Callback [ [ ULong, ULong ] => ULong ] ], ULong, [ 100, 200 ], 600, 600;
#include "std.h"
// ext: .c
typedef long cb(unsigned long, unsigned long);
unsigned long fn(cb *callback) {
    return callback(100, 200);
}

};
subtest longlong => sub {
    build_and_test
        'typedef long long cb(long long, long long)' => <<'', [ Callback [ [ LongLong, LongLong ] => LongLong ] ], LongLong, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef long cb(long long, long long);
long long fn(cb *callback) {
    return callback(100, 200);
}

};
subtest ulonglong => sub {
    build_and_test
        'typedef unsigned long cb(unsigned long long, unsigned long long)' =>
        <<'', [ Callback [ [ ULongLong, ULongLong ] => ULongLong ] ], ULongLong, [ 100, 200 ], 600, 600;
#include "std.h"
// ext: .c
typedef long long cb(unsigned long long, unsigned long long);
unsigned long long fn(cb *callback) {
    return callback(100, 200);
}

};
subtest size_t => sub {
    build_and_test
        'typedef size_t cb(size_t, size_t)' => <<'', [ Callback [ [ Size_t, Size_t ] => Size_t ] ], Size_t, [ 100, 200 ], 300, 300;
#include "std.h"
// ext: .c
typedef size_t cb(size_t, size_t);
size_t fn(cb *callback) {
    return callback(100, 200);
}

};
subtest float => sub {
    build_and_test
        'typedef float cb(float, float)' =>
        <<'', [ Callback [ [ Float, Float ] => Float ] ], Float, [ float( 1.5, tolerance => 0.01 ), float( 3.98, tolerance => 0.01 ) ], 4.3, float( 4.3, tolerance => 0.01 );
#include "std.h"
// ext: .c
typedef float cb(float, float);
float fn(cb *callback) {
    return callback(1.5, 3.98);
}

};
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
subtest enum => sub {
    typedef TV => Enum [ [ FOX => 11 ], [ CNN => 25 ], [ ESPN => 15 ], [ HBO => 22 ], [ NBC => 32 ] ];
    build_and_test
        'typedef enum TV cb(enum TV)' => <<'', [ Callback [ [ TV() ] => TV() ] ], TV(), [ int TV::ESPN() ], TV::HBO(), int TV::HBO();
#include "std.h"
// ext: .c
enum TV { FOX = 11, CNN = 25, ESPN = 15, HBO = 22, MAX = 30, NBC = 32 };
typedef enum TV cb(enum TV);
enum TV fn(cb *callback) {
    return callback(ESPN);
}

};
done_testing;
