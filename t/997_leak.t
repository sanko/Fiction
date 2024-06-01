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














use warnings;
use strict;
use Capture::Tiny 'capture';
use B::Deparse;
use Data::Dump;

# Function to run anonymous sub in a new process with valgrind
sub valgrind(&) {
    my ($code_ref) = @_;

    # Get source code of the anonymous sub (using B::Deparse)
    #~ my $source = deparse($code_ref);
    my $deparse = B::Deparse->new( "-p", "-sC" );
    my $source  = $deparse->coderef2text($code_ref);

    # Prepare valgrind command
    warn $source;
    my @valgrind_cmd = qw[valgrind --error-limit=no ];
    @valgrind_cmd = ( $^X, '-e', $source );    # Suppress output
    ddx \@valgrind_cmd;

    # Capture output using Capture::Tiny
    my ( $output, $error, $exit_code ) = capture { system @valgrind_cmd; };

    # Check if valgrind ran successfully
    my $success = ( $exit_code == 0 );
    return ( $output, $success, $error );
}
{
    # Example usage with anonymous sub
    my ( $output, $success, $error ) = valgrind {
        warn 'hi???????????????????????????????????????????????????';
    };
    if ($success) {
        print "Code ran successfully in valgrind\n";
        warn $output;
    }
    else {
        print "Error running code in valgrind: $error\n";
    }
}
{
    # Example usage with anonymous sub
    my ( $output, $success, $error ) = valgrind {
        warn 'hi!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
        print 'working';
    };
    if ($success) {
        print "Code ran successfully in valgrind\n";
        warn $output;
    }
    else {
        print "Error running code in valgrind: $error\n";
    }
}

