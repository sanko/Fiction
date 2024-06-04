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
subtest 'size_t fn(void)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
size_t fn(void) {return 99; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [], Size_t ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(), 99, 'return from $fn->() is correct';
};
subtest 'size_t fn(size_t)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
size_t fn(size_t i) {return i + 1; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [Size_t], Size_t ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->(500938282), 500938283, 'return from $fn->(500938282) is correct';
};
subtest 'size_t fn(size_t)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
size_t fn(size_t a, size_t b) {return a * b; }

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [ Size_t, Size_t ], Size_t ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->( 1.5, 2.3 ), 2, 'return from $fn->(1.5, 2.3) is correct';
};
done_testing;
