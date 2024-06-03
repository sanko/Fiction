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
subtest 'short fn(void)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
short fn(void) {return -32767; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [], Short ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(), -32767, 'return from $fn->() is correct';
};
subtest 'short fn(short)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
short fn(short i) {return i + 1; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [Short], Short ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(-100), -99, 'return from $fn->(-100) is correct';
};
done_testing;
