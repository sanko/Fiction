use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
subtest 'bool fn(wchar_t)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
bool fn(wchar_t chr) {
    fflush(stdout);
    return chr == L'時' ? true : false;
}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [WChar], Bool ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->('時'), T(), 'return from $fn->("時") is correct';
    is $fn->('好'), F(), 'return from $fn->("好") is correct';
};
subtest 'wchar_t fn(wchar_t)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
wchar_t fn(bool i) {
    fflush(stdout);
    return i ? L'時': L'네';
}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [Int], WChar ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(1), '時', 'return from $fn->(!1) is correct';
    is $fn->(0), '네', 'return from $fn->(1) is correct';
};
done_testing;
