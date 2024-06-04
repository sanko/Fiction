use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use Capture::Tiny qw[capture_stderr];
$|++;
#
subtest 'double fn(void)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
double fn(void) {return 1.525; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [], Double ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(), float( 1.525, tolerance => 0.000001 ), 'return from $fn->() is correct';
};
subtest 'double fn(double)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
double fn(double i) { return 46 + (i * .01); }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [Double], Double ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(3), float( 46, tolerance => 0.031 ), 'return from $fn->(3) is correct';
};
subtest 'double fn(double, double)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
double fn(double i, double j) { return i * j;}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [ Double, Double ], Double ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->( 1.5, 2.3 ), float( ( 1.5 * 2.3 ), tolerance => 0.03 ), 'return from $fn->( 1.5, 2.3 ) is correct';
};
done_testing;
