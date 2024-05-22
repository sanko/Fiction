use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:lib];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
imported_ok qw[load_library find_library find_symbol dlerror libm libc];
subtest Int => sub { ok my $lib = compile_test_lib(<<''), 'build test lib' };
#include "std.h"
// ext: .c
extern int var;
int var = 100;
int verify(){return var;}


#~ ok my $verify = wrap( $lib, 'verify', [] => Int ), 'wrap( ..., "verify", ... )';
#~ ok pin( my $var, $lib, 'var', Int ),                      'pin( my $var, ... )';
#~ is $var, 100, '$var == 100';
#~ subtest 200 => sub {
#~ is $var = 200,  200, '$var = 200';
#~ is $var,        200, '$var == 200';
#~ is $verify->(), 200, '$verify->() == 200';
#~ };
#~ subtest 120 => sub {
#~ is $var = 120,  120, '$var = 120';
#~ is $var,        120, '$var == 120';
#~ is $verify->(), 120, '$verify->() == 120';
#~ };
#~ subtest unpin => sub {
#~ ok unpin($var), 'unpin( ... )';
#~ is $var = 300,  300, '$var = 300';
#~ is $var,        300, '$var == 300';
#~ is $verify->(), 120, '$verify->() == 120 (still)';
#~ }
use DynaLoader;
diag 'Test m: ' . DynaLoader::dl_findfile('-lm');
diag 'Test c: ' . DynaLoader::dl_findfile('-lc');
subtest find_library => sub {
    subtest system => sub {
        my $loc = find_library('m');
        ok $loc, 'find_library("m")';
        diag $loc;
    };
    subtest local => sub {
        ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
int fun(){return 1;}

        my $loc = find_library($lib);
        ok $loc, "find_library('$lib')";
    };
    subtest missing => sub {
        my $lib = 'totallyfakelib_' . int rand time;
        my $loc = find_library($lib);
        ok !$loc, "find_library('$lib') is undef because it does not exist";
    };
SKIP: {
        skip 'Unix tests' unless $^O eq 'linux';
        for my $test (qw[m c]) {
            {    # DynaLoader is CORE but might miss things when not on Unix
                my $todo = todo 'ld might be missing';
                my ($lib) = Affix::Platform::Unix::_findLib_dynaloader($test);
                ok $lib, qq[Affix::Platform::Unix::_findLib_dynaloader('$test')];
                diag $lib;
            }
            {
                my $todo = todo 'ld might be missing';
                my ($lib) = Affix::Platform::Unix::_findLib_ld($test);
                ok $lib, qq[Affix::Platform::Unix::_findLib_ld('$test')];
                diag $lib;
            }
            {
                my $todo = todo 'ldconfig might be missing';
                my ($lib) = Affix::Platform::Unix::_findLib_ldconfig($test);
                ok $lib, qq[Affix::Platform::Unix::_findLib_ldconfig('$test')];
                diag $lib;
            }
            {
                my $todo = todo 'c compiler might be missing';
                my ($lib) = Affix::Platform::Unix::_findLib_gcc($test);
                ok $lib, qq[Affix::Platform::Unix::_findLib_gcc('$test')];
                diag $lib;
            }
        }
    }
};

#~ find_library
#~ =head2 C<load_library( ... )>
SKIP: {
    skip 'Windows tests' if $^O eq 'MSWin32';
    is Affix::dlerror(), undef, 'dlerror() is undef';
}
#
my ( $libm, $libref, $symbol );
subtest find_library => sub {
    ok !load_library('nowaydoesthislibexist'), q[load_library('nowaydoesthislibexist')];
    {
        my $dlerror = dlerror();
        ok $dlerror, 'dlerror() is now defined';
        diag $dlerror;
    }
    for my $test (qw[c m]) {
        my ($lib) = find_library($test);
        ok $lib, qq[find_library('$test')];
        diag $lib;
        $libm = $lib if $test eq 'm';
    }
SKIP: {
        skip 'Windows tests' unless $^O eq 'MSWin32';
        for my $test (qw[ntdll OpenGL32 Glu32]) {
            my ($lib) = find_library($test);
            ok $lib, qq[find_library('$test')];
            diag $lib;
        }
    }
    subtest load_library => sub {
    SKIP: {
            skip 'Failed to locate libm' unless $libm;
            $libref = load_library($libm);
            ok $libref,             qq[load_library('$libm')];
            ok load_library(undef), q[load_library(undef)];
        }
    };
    subtest find_symbol => sub {
    SKIP: {
            skip 'Failed to load libm' unless $libref;
            $symbol = find_symbol( $libref, 'pow' );
            ok $symbol, q[find_symbol(..., 'pow')];
        }
    };
    #
    {
        my $nope    = load_library( 'totallyfakelib_' . int rand time );
        my $dlerror = dlerror();
        ok $dlerror, 'dlerror()';
        diag $dlerror;
    };
    {
        my $libc = libc();
        ok $libc, 'libc()';
        diag $libc if $libc;
    }
    {
        my $libm = libm();
        ok $libm, 'libm()';
        diag $libm if $libm;
    }
};

#~ =head2 C<free_library( ... )>
#~ =head2 C<list_symbols( ... )>
#~ =head2 C<find_symbol( ... )>
#~ =head2 C<free_symbol( ... )>
done_testing;
