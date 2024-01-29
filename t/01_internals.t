use v5.38;
use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix;
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
my ( $libm, $libref );
subtest find_library => sub {
    for my $test (qw[c m]) {
        my ($lib) = Affix::find_library($test);
        ok $lib, qq[find_library('$test')];
        diag $lib;
        $libm = $lib if $test eq 'm';
    }
SKIP: {
        skip 'Windows tests' unless $^O =~ /MSWin/;
        for my $test (qw[ntdll OpenGL32 Glu32]) {
            my ($lib) = Affix::find_library($test);
            ok $lib, qq[find_library('$test')];
            diag $lib;
        }
    }
};
subtest load_lib => sub {
SKIP: {
        skip 'Failed to load libm' unless $libm;
        $libref = Affix::load_lib($libm);
        ok $libref, q[load_lib(...)];
    }
};
#
if ($libref) {
    note $_ for @{ Affix::Lib::list_symbols($libref) };
}
#
done_testing;
