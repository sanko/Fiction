use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
sub build_and_test {
    my ( $name, $c, $arg_types, $ret_type, $arg1, $ret_check ) = @_;
    subtest $name => sub {
        plan 3;
        ok my $lib    = compile_test_lib($c), 'build test lib';
        isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $fn = ...';
        is $fn->( defined $arg1 ? ref $arg1 eq 'ARRAY' ? @$arg1 : $arg1 : () ), $ret_check, 'return from $fn->(...) is correct';
    }
}
#
#define WSTRING_FLAG '<'
#define STDSTRING_FLAG 'Y'
#define STRUCT_FLAG 'A'
#define CPPSTRUCT_FLAG 'B'
#define UNION_FLAG 'u'
#define CODEREF_FLAG '&'
subtest pointer => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
int* fn(int* nums, int count) {
    int* a;
    a = (int *) malloc(sizeof(int) * count); // leak
    if (a != NULL) for( int i = 0; i < count; i++) a[i] = nums[count - i - 1];
    return a;
}

    isa_ok my $fn   = Affix::wrap( $lib, 'fn', [ Pointer [Int], Int ], Array [ Int, 7 ] ), [qw[Affix]],        'my $fn = ...';
    isa_ok my $ints = $fn->( [ 1 .. 7 ], 7 ),                                              ['Affix::Pointer'], '$ints';
    is $ints->sv, [ reverse 1 .. 7 ], '$ints->sv';
};

#define SV_FLAG '?'
subtest enum => sub {
    typedef TV => Enum [ [ FOX => 11 ], [ CNN => 25 ], [ ESPN => 15 ], [ HBO => 22 ], [ NBC => 32 ] ];
    build_and_test
        'enum TV fn(enum TV)' => <<'', [ TV() ], Int, TV::FOX(), int TV::NBC();
#include "std.h"
// ext: .c
enum TV { FOX = 11, CNN = 25, ESPN = 15, HBO = 22, MAX = 30, NBC = 32 };
enum TV fn(enum TV chan) { return chan == FOX ? NBC : HBO; }

};
done_testing;
