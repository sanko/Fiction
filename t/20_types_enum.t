use Test2::V0;
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[Enum typedef];
$|++;
use t::lib::helper;
#
isa_ok my $ab = Enum [ 'alpha', [ 'beta' => 5 ] ], [qw[Affix::Enum]], q[my $ab = Enum [ 'alpha', [ 'beta' => 5 ] ]];
is scalar $ab, 'alpha', 'scalar $ab == alpha';
is int $ab,    0,       'int $ab == 0';
$ab++;
note '$ab++';
is scalar $ab, 'beta', 'scalar $ab == beta';
is int $ab,    5,      'int $ab == 5';
$ab++;
note '$ab++';
is scalar $ab, 'alpha', 'scalar $ab == alpha [wrapped around]';
is int $ab,    0,       'int $ab == 0 [wrapped around]';
$ab--;
note '$ab--';
is scalar $ab, 'beta', 'scalar $ab == beta [wrapped around]';
is int $ab,    5,      'int $ab == 5 [wrapped around]';
subtest typedef => sub {
    ok typedef( 'AB' => $ab ), 'typedef AB => $ab';
    can_ok 'AB', [ 'alpha', 'beta' ], 'subs installed';
    is AB::alpha(),     'alpha', 'AB::alpha() == alpha';
    is int AB::alpha(), 0,       'int AB::alpha() == 0';
    is AB::beta(),      'beta',  'AB::beta() == beta';
    is int AB::beta(),  5,       'int AB::beta() == 1';
    ok my $hey = AB::beta(), '$hey = AB::beta()';
    is $hey,     'beta', '$hey == beta';
    is int $hey, 5,      'int $hey == 5';
    note '$hey++';
    $hey++;
    is $hey,     'alpha', '$hey == alpha';
    is int $hey, 0,       'int $hey == 0';
};
isa_ok my $abc = Enum [ 'alpha', [ 'beta' => 5 ], 'gamma' ], [qw[Affix::Enum]], q[my $abc = Enum [ 'alpha', [ 'beta' => 5 ], 'gamma' ]];
$abc += 2;
note '$abc += 2';
is $abc,     'gamma', '$abc == gamma';
is int $abc, 6,       'int $abc == 6';
#
done_testing;
