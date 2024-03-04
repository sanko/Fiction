use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
subtest 'Pointer[Void]' => sub {
    subtest 5 => sub {
        subtest defined => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Void], 5 ), ['Affix::Pointer'], '5';
            use Data::Dump;
            ddx $ptr;
            $ptr->dump(16);
            is $ptr->sv,                                                   5,     '$ptr->sv';
            is unpack( 'C', $ptr->raw( Affix::Platform::SIZEOF_CHAR() ) ), ord 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };

        #~ subtest undef => sub {
        #~ isa_ok my $ptr = Affix::sv2ptr( Pointer [Void], undef ), ['Affix::Pointer'], 'undef';
        #~ $ptr->dump(16);
        #~ is $ptr->sv, U(), '$ptr->sv is undef';
        #~ free $ptr;
        #~ is $ptr, U(), '$ptr is now free';
        #~ };
    };

    #~ subtest list => sub {
    #~ subtest '[ 150 .. 170 ]' => sub {
    #~ isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [ 150 .. 170 ] ), ['Affix::Pointer'], '[150..170]';
    #~ $ptr->dump(88);
    #~ is $ptr->at(0),         150,  '$ptr->at(0) == 150';
    #~ is $ptr->at(8),         158,  '$ptr->at(8) == 158';
    #~ is $ptr->at( 0, 2000 ), 2000, '$ptr->at(0, 2000) == 2000';
    #~ $ptr->dump(40);
    #~ is $ptr->sv, [ 2000, 151 .. 170 ], '$ptr->sv';
    #~ is [ unpack 'i*', $ptr->raw( 21 * Affix::Platform::SIZEOF_INT() ) ], [ 2000, 151 .. 170 ],
    #~ '$ptr->raw( ' . 21 * Affix::Platform::SIZEOF_INT() . ' )';
    #~ free $ptr;
    #~ is $ptr, U(), '$ptr is now free';
    #~ };
    #~ subtest '[]' => sub {
    #~ isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [] ), ['Affix::Pointer'], '[]';
    #~ $ptr->dump(16);
    #~ use Data::Dump;
    #~ ddx $ptr->sv;
    #~ is $ptr->sv, [], '$ptr->sv is []';
    #~ free $ptr;
    #~ is $ptr, U(), '$ptr is now free';
    #~ };
    #~ };
};
subtest 'Pointer[Int]' => sub {
    subtest 5 => sub {
        subtest defined => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], 5 ), ['Affix::Pointer'], '5';
            is $ptr->sv,                                                  5, '$ptr->sv';
            is unpack( 'i', $ptr->raw( Affix::Platform::SIZEOF_INT() ) ), 5, '$ptr->raw( ' . Affix::Platform::SIZEOF_INT() . ' )';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
        subtest undef => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], undef ), ['Affix::Pointer'], 'undef';
            $ptr->dump(16);
            is $ptr->sv, U(), '$ptr->sv is undef';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
    subtest list => sub {
        subtest '[ 150 .. 170 ]' => sub {
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
        subtest '[]' => sub {
            isa_ok my $ptr = Affix::sv2ptr( Pointer [Int], [] ), ['Affix::Pointer'], '[]';
            $ptr->dump(16);
            use Data::Dump;
            ddx $ptr->sv;
            is $ptr->sv, [], '$ptr->sv is []';
            free $ptr;
            is $ptr, U(), '$ptr is now free';
        };
    };
};
done_testing;
