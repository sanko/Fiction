use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
subtest 'bool fn(bool)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
bool fn(bool i) { return i ? false : true; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [Bool], Bool ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(1),    F(), 'return from $fn->(1) is correct';
    is $fn->( !1 ), T(), 'return from $fn->(!1) is correct';
};
done_testing;
