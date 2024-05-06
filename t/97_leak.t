use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib './lib', '../lib', '../blib/arch/', 'blib/arch', '../', '.';
use Affix          qw[:all];
use t::lib::helper qw[leaktest compile_test_lib];
$|++;
#
leaktest 'malloc and free' => sub {
    my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c

DLLEXPORT int no_leak() {
    void * ptr = malloc(1024);
    free(ptr);
    return 100;
}

END
    diag '$lib: ' . $lib;
    ok my $_lib = load_library($lib), 'lib is loaded [debugging]';
    diag $_lib;
    ok Affix::affix( $lib => 'no_leak', [] => Int ), 'int no_leak()';
    is no_leak(), 100, 'no_leak()';
};
#
leaktest 'leaky type' => sub {
    ok Void, 'Void';
    ok Bool, 'Bool';
    ok Char, 'Char';
};
done_testing;
