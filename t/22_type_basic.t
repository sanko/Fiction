use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use utf8;
$|++;
#
sub build_and_test {
    my ( $name, $c, $arg_types, $ret_type, $arg1, $ret_check ) = @_;
    subtest $name => sub {
        plan 3;
        ok my $lib    = compile_test_lib($c), 'build test lib';
        isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $fn = ...';
        is $fn->( $arg1 // () ), $ret_check, 'return from $fn->(...) is correct';
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

#define SSIZE_T_FLAG LONGLONG_FLAG
#define SIZE_T_FLAG ULONGLONG_FLAG
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
