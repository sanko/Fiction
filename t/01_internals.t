use v5.38;
use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:types dlerror find_library load_library find_symbol];
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
            ok Affix::wrap( find_library('m'), [ 'pow' => 'power' ], [ Double, Double ], Double ), 'wrap libm::pow as power';
        },
        qr/a name/,
        'renaming a symbol is meaningless inside Affix::wrap(...)'
    );
    ok !__PACKAGE__->can('power'),                                                          'power() is still undefined';
    ok Affix::affix( find_library('m'), [ 'pow' => 'power' ], [ Double, Double ], Double ), 'affix libm::pow as power';
    can_ok __PACKAGE__, 'power';
    is power( 3, 4 ), 81, 'power( 3, 4 )';
};
subtest 'affix with known argtypes' => sub {
    my $affix = Affix::affix( find_library('m'), 'pow', [ Double, Double ], Double );
    isa_ok $affix, ['Affix'];
    is $affix->( 3, 4 ), 81, 'object_test';
};
subtest 'affix with unknown argtypes' => sub {
    my $affix = Affix::affix( find_library('m'), 'pow' );
    isa_ok $affix, ['Affix'];
    is $affix->( 3.0, 4.0 ), 81, 'object_test';
};
subtest 'types' => sub {
    subtest 'Void' => sub {
        isa_ok my $double = Void, ['Fiction::Type'];
        is $double, 'v', 'stringify';
    };
    subtest 'Double' => sub {
        isa_ok my $double = Double, ['Fiction::Type'];
        is $double, 'd', 'stringify';
    }
};
#
done_testing;
