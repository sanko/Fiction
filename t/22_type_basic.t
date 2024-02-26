use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
my %tests = (
    'void fn(void)' => [ <<'', [], Void, undef, U() ],
#include "std.h"
// ext: .c
void fn(void) { }

    'bool fn(bool) true' => [ <<'', [Bool], Bool, 1, T() ],
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? true : false;}

    'bool fn(bool) false' => [ <<'', [Bool], Bool, 0, F() ],
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? true : false;}

    'int fn(int)' => [ <<'', [Int], Int, 3, 49 ],
#include "std.h"
// ext: .c
int fn(int i) { return 46 + i;}

);
subtest $_ => sub {
    plan 3;
    ok my $lib    = compile_test_lib( $tests{$_}[0] ), 'build test lib';
    isa_ok my $fn = Affix::wrap( $lib, 'fn', $tests{$_}[1], $tests{$_}[2] ), [qw[Affix]], 'my $cb = ...';
    is $fn->( $tests{$_}[3] // () ), $tests{$_}[4], 'return from $fn->(...) is correct';
    }
    for sort keys %tests;
done_testing;
