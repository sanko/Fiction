use Test2::V0;
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[/Enum/ typedef];
$|++;
use t::lib::helper;
#
subtest expressions => sub {

    # Taken from https://en.cppreference.com/w/c/language/enum
    isa_ok( ( typedef CPPRef => Enum [ 'A', 'B', [ C => 10 ], 'D', [ E => 1 ], 'F', [ G => 'F + C' ] ] ),
        ['Affix::Type::Enum'], 'enum Foo { A, B, C = 10, D, E = 1, F, G = F + C };' );
    is int CPPRef::A(), 0,  'A == 0';
    is int CPPRef::B(), 1,  'B == 1';
    is int CPPRef::C(), 10, 'C == 10';
    is int CPPRef::D(), 11, 'D == 11';
    is int CPPRef::E(), 1,  'E == 1';
    is int CPPRef::F(), 2,  'F == 2';
    is int CPPRef::G(), 12, 'G == 12';
};
#
done_testing;
