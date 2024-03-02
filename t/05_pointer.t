use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use utf8;
$|++;
#
use Data::Dump;
#
subtest 'Pointer[Int]' => sub {
    subtest int => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], 5 ), ['Affix::Pointer'], '5';
        ddx $ptr;
        warn;
        $ptr->dump(4);
        warn;

        #~ ddx Affix::ptr2sv(Pointer[Int], $ptr);
        warn $ptr;
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
    subtest array => sub {
        isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
        $ptr->dump(40);
        is $ptr->at(0),         150,  '$ptr->at(0) == 150';
        is $ptr->at(8),         158,  '$ptr->at(8) == 158';
        is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';

        #~ ddx Affix::ptr2sv(Pointer[Int], $ptr);
        #~ $ptr->plus( 1, 1 )->dump(10);
        $ptr->dump(40);
        free $ptr;
        is $ptr, U(), '$ptr is now free';
    };
};
done_testing;
