use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
sub build_and_test {
    my ( $name, $c, $arg_types, $ret_type, $arg1, $ret_check ) = @_;
    subtest $name => sub {
        plan 3;
        ok my $lib    = compile_test_lib($c), 'build test lib';
        isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $fn = ...';
        is $fn->( defined $arg1 ? ref $arg1 eq 'ARRAY' ? @$arg1 : $arg1 : () ), $ret_check, 'return from $fn->(...) is correct';
    }
}
#
build_and_test 'void fn(void)' => <<'', [], Void, undef, U();
#include "std.h"
// ext: .c
void fn(void) { }

subtest short => sub {
    build_and_test 'short fn()' => <<'', [], Short, undef, -32767;
#include "std.h"
// ext: .c
short fn() {
    return -32767;
}

    build_and_test 'short fn(short)' => <<'', [Short], Short, -32767, -32766;
#include "std.h"
// ext: .c
short fn(short i) {
    return i + 1;
}

};
subtest ushort => sub {
    build_and_test 'unsigned short fn()' => <<'', [], UShort, undef, 65535;
#include "std.h"
// ext: .c
unsigned short fn() {
    return 65535;
}

    build_and_test 'unsigned short fn(unsigned short)' => <<'', [Short], UShort, 65535, 65534;
#include "std.h"
// ext: .c
unsigned short fn(unsigned short i) {
    return i - 1;
}

};
subtest int => sub {
    build_and_test 'int fn(int) positive' => <<'', [Int], Int, 3, 49;
#include "std.h"
// ext: .c
int fn(int i) { return 46 + i;}

    build_and_test 'int fn(int) negative' => <<'', [Int], Int, -200, -100;
#include "std.h"
// ext: .c
int fn(int i) { return 100 + i;}

};
subtest uint => sub {
    build_and_test 'unsigned int fn(unsigned int)' => <<'', [UInt], UInt, 3, 49;
#include "std.h"
// ext: .c
unsigned int fn(unsigned int i) { return 46 + i;}

};
subtest long => sub {
    build_and_test 'long fn(long) positive' => <<'', [Long], Long, 47, 2147483647;
#include "std.h"
// ext: .c
long fn(long i) { return 2147483600 + i;}

    build_and_test 'long fn(long) negative' => <<'', [Long], Long, -2147483647, -2147483642;
#include "std.h"
// ext: .c
long fn(long i) { return 5 + i;}

};
subtest ulong => sub {
    build_and_test 'unsigned long fn(unsigned long)' => <<'', [ULong], ULong, 3, 49;
#include "std.h"
// ext: .c
unsigned long fn(unsigned long i) { return 46 + i;}

};
subtest longlong => sub {
    build_and_test 'long long fn(long long) positive' => <<'', [LongLong], LongLong, 47, 2147483647;
#include "std.h"
// ext: .c
long long fn(long long i) { return 2147483600 + i;}

    build_and_test
        'long fn(long long) negative' => <<'', [LongLong], LongLong, -2147483647, -2147483642;
#include "std.h"
// ext: .c
long long fn(long long i) { return 5 + i;}

};
subtest ulonglong => sub {
    build_and_test 'unsigned long fn(unsigned long long)' => <<'', [ULongLong], ULongLong, 3, 49;
#include "std.h"
// ext: .c
unsigned long long fn(unsigned long long i) { return 46 + i;}

};
subtest size_t => sub {
    build_and_test
        'size_t fn(size_t)' => <<'', [Size_t], Size_t, 3, 46;
#include "std.h"
// ext: .c
size_t fn(size_t i) { return 46 + (i * .01);}

    build_and_test
        'size_t fn(size_t, size_t)' => <<'', [ Size_t, Size_t ], Size_t, [ 1.5, 2.3 ], 2;
#include "std.h"
// ext: .c
size_t fn(size_t i, size_t j) { return i * j;}

};
subtest float => sub {
    build_and_test
        'float fn(float)' => <<'', [Float], Float, 3, float( 46, tolerance => 0.03 );
#include "std.h"
// ext: .c
float fn(float i) { return 46 + (i * .01);}

    build_and_test
        'float fn(float, float)' => <<'', [ Float, Float ], Float, [ 1.5, 2.3 ], float( ( 1.5 * 2.3 ), tolerance => 0.03 );
#include "std.h"
// ext: .c
float fn(float i, float j) { return i * j;}

};
subtest double => sub {
    build_and_test
        'double fn(float)' => <<'', [Double], Double, 3, float( 46, tolerance => 0.031 );
#include "std.h"
// ext: .c
double fn(double i) { return 46 + (i * .01);}

    build_and_test
        'double fn(double, double)' => <<'', [ Double, Double ], Double, [ 1.5, 2.3 ], float( ( 1.5 * 2.3 ), tolerance => 0.03 );
#include "std.h"
// ext: .c
double fn(double i, double j) { return i * j;}

};
subtest string => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
const char * fn(const char * i) {
    return "Wow, this shouldn't crash.";
}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [String], String ), [qw[Affix]], 'my $fn = ...';
    is $fn->('Hey'), q[Wow, this shouldn't crash.], '$str';
};
subtest wstring => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
#include <wchar.h>
// ext: .c
const wchar_t* fn(const wchar_t* i) {
    if(wcscmp(i, L"はい") == 0) return L"예";
    if(wcscmp(i, L"いいえ") == 0) return L"아니요";
    return L"뭐?";
}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [WString], WString ), [qw[Affix]], 'my $fn = ...';
    is $fn->('はい'),  q[예],   '$str is yes';
    is $fn->('いいえ'), q[아니요], '$str is no';
    is $fn->('何でも'), q[뭐?],  '$str is unknown';
};

#define WSTRING_FLAG '<'
#define STDSTRING_FLAG 'Y'
#define STRUCT_FLAG 'A'
#define CPPSTRUCT_FLAG 'B'
#define UNION_FLAG 'u'
#define CODEREF_FLAG '&'
subtest pointer => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
int* fn(int* nums, int count) {
    int* a;
    a = (int *) malloc(sizeof(int) * count); // leak
    if (a != NULL) for( int i = 0; i < count; i++) a[i] = nums[count - i - 1];
    return a;
}

    isa_ok my $fn   = Affix::wrap( $lib, 'fn', [ Pointer [Int], Int ], Array [ Int, 7 ] ), [qw[Affix]],        'my $fn = ...';
    isa_ok my $ints = $fn->( [ 1 .. 7 ], 7 ),                                              ['Affix::Pointer'], '$ints';
    is $ints->sv, [ reverse 1 .. 7 ], '$ints->sv';
};

#define SV_FLAG '?'
subtest enum => sub {
    typedef TV => Enum [ [ FOX => 11 ], [ CNN => 25 ], [ ESPN => 15 ], [ HBO => 22 ], [ NBC => 32 ] ];
    build_and_test
        'enum TV fn(enum TV)' => <<'', [ TV() ], Int, TV::FOX(), int TV::NBC();
#include "std.h"
// ext: .c
enum TV { FOX = 11, CNN = 25, ESPN = 15, HBO = 22, MAX = 30, NBC = 32 };
enum TV fn(enum TV chan) { return chan == FOX ? NBC : HBO; }

};
done_testing;
