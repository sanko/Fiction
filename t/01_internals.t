use v5.38;
use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[Double find_library load_library find_symbol];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
my ( $libm, $libref, $symbol );
subtest find_library => sub {
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
is Affix::pow_example( $symbol, 3.0, 4.0 ), 81, 'pow_example';
#
my $affix = Affix::Wrap->new( lib => 'm', symbol => 'pow', argtypes => [ Double, Double ], restype => Double );
isa_ok $affix, ['Affix::Wrap'];
is Affix::object_test( $affix, 3.0, 4.0 ), 81, 'object_test';
#
done_testing;
