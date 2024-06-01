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
subtest 'void fn(void)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
void fn(void) { warn("# okay"); }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [], Void ), [qw[Affix]], 'wrap symbol in $fn';
    like capture_stderr {
        $fn->()
    }, qr[# okay], 'make sure function was called';
    is $fn->(), U(), 'return from $fn->() is correct';
};
done_testing;
