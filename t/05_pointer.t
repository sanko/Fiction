use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use utf8;
$|++;
#
subtest 'Pointer[Int]' => sub {
    subtest int => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], 5 ), ['Affix::Pointer'], '5';
        is $ptr->sv,                                                  5, '$ptr->sv';
        is unpack( 'i', $ptr->raw( Affix::Platform::SIZEOF_INT() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_INT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest array => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
        $ptr->dump(88);
        is $ptr->at(0),         150,  '$ptr->at(0) == 150';
        is $ptr->at(8),         158,  '$ptr->at(8) == 158';
        is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
        $ptr->dump(40);
        is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
        is [ unpack 'i*', $ptr->raw( 21 * Affix::Platform::SIZEOF_INT() ) ], [ 2000, 151 .. 170 ],
            '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_INT() . ' )';
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
};
done_testing;
