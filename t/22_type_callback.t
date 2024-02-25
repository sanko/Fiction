use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
my %tests = (
    'typedef void cb(void)' => [ <<'', [ Callback [ [] => Void ] ], Void, [], (), () ],
#include "std.h"
// ext: .c
typedef void cb(void);
void c(cb *callback) {
    callback();
}

    'typedef bool cb(bool)' => [ <<'', [ Callback [ [Bool] => Bool ] ], Bool, [ F() ], !0, T() ],
#include "std.h"
// ext: .c
typedef bool cb( bool );
bool c(cb *callback) {
    return callback(false);
}

    'typedef char cb(char)' => [ <<'', [ Callback [ [Char] => Char ] ], Char, ['a'], 'm', 'm' ],
#include "std.h"
// ext: .c
typedef char cb( char );
char c(cb *callback) {
    return callback('a');
}

    'typedef int cb(int, int)' => [ <<'', [ Callback [ [ Int, Int ] => Int ] ], Int, [ 100, 200 ], 600, 600 ],
#include "std.h"
// ext: .c
typedef int cb(int, int);
int c(cb *callback) {
    return callback(100, 200);
}

    'typedef double cb(double, double)' => [
        <<'', [ Callback [ [ Double, Double ] => Double ] ], Double, [ float( 1.5, tolerance => 0.01 ), float( 3.98, tolerance => 0.01 ) ], 4.3, float( 4.3, tolerance => 0.01 ) ],
#include "std.h"
// ext: .c
typedef double cb(double, double);
double c(cb *callback) {
    return callback(1.5, 3.98);
}

);
subtest $_ => sub {
    plan 4;
    ok my $lib    = compile_test_lib( $tests{$_}[0] ), 'build test lib';
    isa_ok my $cb = Affix::wrap( $lib, 'c', $tests{$_}[1], $tests{$_}[2] ), [qw[Affix]], 'my $cb = ...';
    is $cb->(
        sub {
            is \@_, $tests{$_}[3], '@_ in $cb is correct';
            return $tests{$_}[4];
        }
        ),
        $tests{$_}[5], 'return from $cb->(sub {[...]}) is correct';
    }
    for sort keys %tests;
done_testing;
