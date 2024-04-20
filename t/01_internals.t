use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:types dlerror find_library load_library find_symbol affix wrap];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
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
SKIP: {
        skip 'Unix tests' unless $^O eq 'linux';
        for my $test (qw[m c]) {
            {
                my $todo = todo 'ld might be missing';
                my ($lib) = Affix::Platform::Unix::_findLib_ld($test);
                ok $lib, qq[Affix::Platform::Unix::_findLib_ld('$test')];
                diag $lib;
            }
            {
                my $todo = todo 'ldconfig might be missing';
                my ($lib) = Affix::Platform::Unix::_findSoname_ldconfig($test);
                ok $lib, qq[Affix::Platform::Unix::_findSoname_ldconfig('$test')];
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
subtest 'affix with renamed symbol' => sub {
    like(
        warning {
            ok wrap( find_library('m'), [ 'pow' => 'power' ], [ Double, Double ], Double ), 'wrap libm::pow as power';
        },
        qr/expecting a name/,
        'renaming a symbol is meaningless inside Affix::wrap(...)'
    );
    ok !__PACKAGE__->can('power'),                                                   'power() is still undefined';
    ok affix( find_library('m'), [ 'pow' => 'power' ], [ Double, Double ], Double ), 'affix libm::pow as power';
    can_ok __PACKAGE__, 'power';
    diag Double;
    is power( 3, 4 ), 81, 'power( 3, 4 )';
};
subtest 'affix with known argtypes' => sub {
    isa_ok my $affix = wrap( find_library('m'), 'pow', [ Double, Double ], Double ), ['Affix'];
    is $affix->( 3, 4 ), 81, '$affix->( 3, 4 )';
};
subtest 'affix with unknown argtypes' => sub {
    isa_ok my $affix = wrap( find_library('m'), 'pow', undef, Double ), ['Affix'];
    is $affix->( 3.0, 4.0 ), 81, '$affix->( 3.0, 4.0 )';
};
subtest 'affix with known argtypes and bad param lists' => sub {
    isa_ok my $affix = wrap( find_library('m'), 'pow', [ Double, Double ], Double ), ['Affix'];
    like( dies { $affix->( 3, 4, 5 ) }, qr/Too many/,   '$affix->( 3, 4, 5 ): too many parameters' );
    like( dies { $affix->(3) },         qr/Not enough/, 'pow( 3 ): not enough parameters' );
};
subtest 'types' => sub {
    subtest 'Void' => sub {
        isa_ok my $double = Void, ['Affix::Type'];
        is $double,     'Void', 'stringify';
        is chr $double, 'v',    'numify';
    };
    subtest 'Double' => sub {
        isa_ok my $double = Double, ['Affix::Type'];
        is $double,     'Double', 'stringify';
        is chr $double, 'd',      'numify';
    };
    subtest 'String' => sub {
        isa_ok my $string = String, ['Affix::Type'];
        is $string,     'Pointer[ Const[ Char ] ]', 'stringify';
        is chr $string, 'P',                        'numify';
    };
};
subtest 'compiled lib' => sub {
    my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c

DLLEXPORT double Nothing() {
    return 99;
}

DLLEXPORT int Nothing_I(int i) {
    return 100 + i;
}
END
    diag '$lib: ' . $lib;
    ok my $_lib = load_library($lib), 'lib is loaded [debugging]';
    diag $_lib;
    ok Affix::affix( $lib, 'Nothing', [], Double ), 'double Nothing()';
    diag 'here';
    is Nothing(), 99, 'Nothing()';

    #~ #
    ok affix( $_lib, 'Nothing_I', [Int] => Int ), 'int Nothing_I(int i)';
    is Nothing_I(3), 103, 'Nothing_I(3)';
};
#
done_testing;
