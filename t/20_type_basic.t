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

subtest bool => sub {
    build_and_test 'bool fn(bool) true' => <<'', [Bool], Bool, 1, T();
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? true : false;}

    build_and_test 'bool fn(bool) false' => <<'', [Bool], Bool, 0, F();
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? true : false;}

};
subtest char => sub {
    build_and_test 'char fn(char)' => <<'', [Char], Char, 'a', 'b';
#include "std.h"
// ext: .c
char fn(char i) { return i + 1;}

};
subtest schar => sub {
    build_and_test 'signed char fn(signed char)' => <<'', [SChar], SChar, -ord 'b', 'b';
#include "std.h"
// ext: .c
signed char fn(signed char i) { return -i;}

    build_and_test 'signed char fn(signed char)' => <<'', [SChar], SChar, 'b', pack 'c', -ord 'b';
#include "std.h"
// ext: .c
signed char fn(signed char i) { return -i;}

};
subtest uchar => sub {
    build_and_test 'unsigned char fn(unsigned char)' => <<'', [UChar], UChar, 'b', 'y';
#include "std.h"
// ext: .c
unsigned char fn(unsigned char i) { return i == 'v' ? 'x' : 'y';}

    build_and_test 'unsigned char fn(unsigned char)' => <<'', [UChar], UChar, 'v', 'x';
#include "std.h"
// ext: .c
unsigned char fn(unsigned char i) { return i == 'v' ? 'x' : 'y';}

};
subtest wchar_t => sub {
    build_and_test 'bool fn(wchar_t) 時 == 時' => <<'', [WChar], Bool, '時', T();
#include "std.h"
// ext: .c
bool fn(wchar_t chr) {
    fflush(stdout);
    return chr == L'時' ? true : false;
}

    build_and_test 'bool fn(wchar_t) 時 != 好' => <<'', [WChar], Bool, '好', F();
#include "std.h"
// ext: .c
bool fn(wchar_t chr) {
    fflush(stdout);
    return chr == L'時' ? true : false;
}

    build_and_test 'wchar_t fn() 時' => <<'', [], WChar, undef, '時';
#include "std.h"
// ext: .c
wchar_t fn() {
    return L'時';
}

    build_and_test 'wchar_t fn() 네' => <<'', [], WChar, undef, '네';
#include "std.h"
// ext: .c
wchar_t fn() {
    return L'네';
}

};
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

    build_and_test 'long fn(long long) negative' => <<'', [LongLong], LongLong, -2147483647, -2147483642;
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
        'enum TV fn(enum TV)' => <<'', [ TV() ], Int, TV::FOX(), int TV::NBC();
#include "std.h"
// ext: .c
enum TV { FOX = 11, CNN = 25, ESPN = 15, HBO = 22, MAX = 30, NBC = 32 };
enum TV fn(enum TV chan) { return chan == FOX ? NBC : HBO; }

};
done_testing;
