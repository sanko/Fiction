use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib './lib', '../lib', '../blib/arch/', 'blib/arch', '../', '.';
use Affix          qw[:all];
use t::lib::helper qw[leaktest compile_test_lib leaks];
$|++;

#~ my $test= 'wow';
use Data::Dump;
ddx leaks {
    ok 1, 'fake';
    warn 'hi???????????????????????????????????????????????????';
};
ok 'oy';
done_testing;
exit;
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
leaktest 'malloc/free pointer' => sub {
    isa_ok my $ptr = malloc(1024), ['Affix::Pointer'];
    diag $ptr;
    is free $ptr, U(), 'free';
};
#
leaktest 'leaky type' => sub {
    ok Void,  'Void';
    ok Bool,  'Bool';
    ok Char,  'Char';
    ok SChar, 'SChar';
    ok UChar, 'UChar';
    ok WChar, 'WChar';
    #
    ok Struct [ i => Int ],                                  'Struct[ i => Int ]';
    ok Union [ i => Int, ptr => Pointer [Int], f => Float ], 'Union [ i => Int, ptr => Pointer [Int], f => Float ]';
};
done_testing;
