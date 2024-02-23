use Test2::V0;
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[/Enum/ typedef];
$|++;
use t::lib::helper;
#
isa_ok my $ab = Enum [ 'alpha', [ 'beta' => 5 ] ], [qw[Affix::Type::Enum Affix::Type]], q[my $ab = Enum [ 'alpha', [ 'beta' => 5 ] ]];
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
isa_ok my $abc = Enum [ 'alpha', [ 'beta' => 5 ], 'gamma' ], [qw[Affix::Type::Enum]], q[my $abc = Enum [ 'alpha', [ 'beta' => 5 ], 'gamma' ]];
$abc += 2;
note '$abc += 2';
is $abc,     'gamma', '$abc == gamma';
is int $abc, 6,       'int $abc == 6';
subtest subtypes => sub {
    isa_ok IntEnum [qw[al be ga]],  [qw[Affix::Type::IntEnum Affix::Type::Enum Affix::Type]],  q[IntEnum[qw[al be ga]]];
    isa_ok UIntEnum [qw[al be ga]], [qw[Affix::Type::UIntEnum Affix::Type::Enum Affix::Type]], q[UIntEnum[qw[al be ga]]];
    subtest 'CharEnum' => sub {
        isa_ok my $c = CharEnum [qw[al be ga]], [qw[Affix::Type::CharEnum Affix::Type::Enum Affix::Type]], q[CharEnum[qw[al be ga]]];
        is $c,     'al', '$c eq al';
        is int $c, 0,    'int $c == 0';
        diag '$c++';
        $c++;
        is $c,     'be', '$c eq be';
        is int $c, 1,    'int $c == 1';
    };
};
#
done_testing;
