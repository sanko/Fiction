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
        skip 'Windows tests' unless $^O =~ /MSWin/;
        for my $test (qw[ntdll OpenGL32 Glu32]) {
            my ($lib) = find_library($test);
            ok $lib, qq[find_library('$test')];
            diag $lib;
        }
    }
};
subtest load_library => sub {
SKIP: {
        skip 'Failed to locate libm' unless $libm;
        $libref = load_library($libm);
        ok $libref, q[load_library(...)];
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
is Affix::pow_example( $symbol, 3, 4 ), 81, 'pow_example';
#
my $affix = Affix::Wrap->new( lib => 'm', symbol => 'pow', args => [ Double, Double ], returns => Double );
isa_ok $affix, ['Affix::Wrap'];
#
done_testing;
