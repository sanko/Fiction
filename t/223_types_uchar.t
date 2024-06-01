use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
subtest 'uchar fn(uchar)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
unsigned char fn(unsigned char i) { return i == 'v' ? 'x' : 'y';}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [UChar], UChar ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->('b'),       'y', 'return from $fn->("b") is correct';
    is $fn->( ord 'b' ), 'y', 'return from $fn->(ord "b") is correct';
    is $fn->('v'),       'x', 'return from $fn->("v") is correct';
    is $fn->( ord 'v' ), 'x', 'return from $fn->(ord "v") is correct';
};
done_testing;
