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
subtest 'const char * fn(const char *)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
const char * fn(const char * i) {
    return strcmp("Hey", i) ? "Wow, I hope this doesn't crash." : "Oh, well, this shouldn't either.";
}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [String], String ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->('Help'), q[Wow, I hope this doesn't crash.],  'return from $fn->("Help") is correct';
    is $fn->('Hey'),  q[Oh, well, this shouldn't either.], 'return from $fn->("Hey") is correct';
};
done_testing;
