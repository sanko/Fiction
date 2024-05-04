use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib './lib', '../lib', '../blib/arch/', 'blib/arch', '../', '.';
use Affix          qw[:all];
use t::lib::helper qw[leaktest compile_test_lib];
$|++;

#

leaktest 'leaky type' => sub {

        my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c

DLLEXPORT void leak() {
     void * ptr = malloc(1024);
    free(ptr);
}

END
        diag '$lib: ' . $lib;
        ok my $_lib = load_library($lib), 'lib is loaded [debugging]';
        diag $_lib;
        ok Affix::affix( $lib => 'leak', [  ] => Void ), 'int ptrptr(char **)';
        #~ is ptrptr($ptr), 3, 'C understood we have 3 lines of text';

leak();

};
done_testing;
exit;
        die;
#
leaktest 'leaky type' => sub {
    Void;
    Bool;
    Char;
    1;
};
leaktest 'nope' => sub {
    1;
};
done_testing;
