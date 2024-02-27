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
        isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $cb = ...';
        is $fn->( $arg1 // () ), $ret_check, 'return from $fn->(...) is correct';
    }
}
#
build_and_test 'void fn(void)' => <<'', [], Void, undef, U();
#include "std.h"
// ext: .c
void fn(void) { }

build_and_test 'bool fn(bool) true' => <<'', [Bool], Bool, 1, T();
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? true : false;}

build_and_test 'bool fn(bool) false' => <<'', [Bool], Bool, 0, F();
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? true : false;}

build_and_test 'char fn(char)' => <<'', [Char], Char, 'a', 'b';
#include "std.h"
// ext: .c
char fn(char i) { return i + 1;}

build_and_test 'signed char fn(signed char)' => <<'', [SChar], SChar, -ord 'b', 'b';
#include "std.h"
// ext: .c
signed char fn(signed char i) { return -i;}

build_and_test 'signed char fn(signed char)' => <<'', [SChar], SChar, 'b', pack 'c', -ord 'b';
#include "std.h"
// ext: .c
signed char fn(signed char i) { return -i;}

build_and_test 'unsigned char fn(unsigned char)' => <<'', [UChar], UChar, 'b', 'y';
#include "std.h"
// ext: .c
unsigned char fn(unsigned char i) { return i == 'v' ? 'x' : 'y';}

build_and_test 'unsigned char fn(unsigned char)' => <<'', [UChar], UChar, 'v', 'x';
#include "std.h"
// ext: .c
unsigned char fn(unsigned char i) { return i == 'v' ? 'x' : 'y';}

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

build_and_test 'int fn(int)' => <<'', [Int], Int, 3, 49;
#include "std.h"
// ext: .c
int fn(int i) { return 46 + i;}

done_testing;
