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
subtest 'unsigned short fn(void)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
unsigned short fn(void) {return 65535; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [], UShort ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(), 65535, 'return from $fn->() is correct';
};
subtest 'unsigned short fn(short)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
unsigned short fn(unsigned short i) {return i + 1; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [UShort], UShort ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(100), 101, 'return from $fn->(100) is correct';
};
done_testing;
