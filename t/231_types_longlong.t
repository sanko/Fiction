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
subtest 'long long fn(void)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
long long fn(void) {return 99; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [], LongLong ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(), 99, 'return from $fn->() is correct';
};
subtest 'long long fn(long long)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
long long fn(long long i) { return 2147483600 + i;}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [LongLong], LongLong ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(47),          2147483647, 'return from $fn->(47) is correct';
    is $fn->(-2147483601), -1,         'return from $fn->(-2147483601) is correct';
};
done_testing;
