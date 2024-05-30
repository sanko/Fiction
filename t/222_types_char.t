use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
subtest 'char fn(char)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
char fn(char i) { return i + 1;}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [Char], Char ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->('a'),       'b', 'return from $fn->("a") is correct';
    is $fn->( ord 'q' ), 'r', 'return from $fn->(ord "q") is correct';
};
subtest 'signed char fn(signed char)' => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
signed char fn(signed char i) { return -i;}

    isa_ok my $fn = Affix::wrap( $lib, 'fn', [SChar], SChar ), [qw[Affix]], 'wrap symbol in $fn';
    is $fn->('b'),        pack( 'c', -ord 'b' ), 'return from $fn->("b") is correct';
    is $fn->( -ord 'b' ), pack( 'c', ord 'b' ),  'return from $fn->(- ord "b") is correct';
};
done_testing;
