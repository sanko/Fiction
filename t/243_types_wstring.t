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
subtest 'const wchar_t * fn(const wchar_t *)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
#include <wchar.h>
// ext: .c
const wchar_t* fn(const wchar_t* i) {
    if(wcscmp(i, L"はい") == 0) return L"예";
    if(wcscmp(i, L"いいえ") == 0) return L"아니요";
    return L"뭐?";
}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [WString], WString ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->('はい'),  q[예],   'return from $fn->("はい") is yes';
    is $fn->('いいえ'), q[아니요], 'return from $fn->("いいえ") is no';
    is $fn->('何でも'), q[뭐?],  'return from $fn->("何でも") is unknown';
};
done_testing;
