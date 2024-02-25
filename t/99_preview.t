use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
#~ my $affix = affix 'm', 'pow', [ Struct [ a => Int ] ], Void;
#
#~ pow();
#~ $affix->call();
isa_ok Pointer [Int], [ 'Affix::Type', 'Affix::Type::Pointer' ];
ok my $lib = compile_test_lib('99_preview'), 'compile_test_lib("99_preview")';
diag $lib;
diag `nm $lib`;
warn Callback [ [], Int ];
use Data::Dump;
ddx [ Callback [ [ Int, Int ] => Int ] ];
#
my $xxx = affix $lib, [ '_Z11do_callbackPFiiiE', 'do_callback' ], [ Callback [ [ Int, Int ] => Int ] ] => Int;
use Data::Dump;
ddx $xxx;

#~ diag $xxx->( sub { diag 'hi'; ... } );
#~ typedef int cb(int, int);
is do_callback(
    sub {
        is \@_, [ 100, 200 ], 'args passed are correct';
        pass 'inside the callback';
        300;
    }
    ),
    300, 'return int from callback';

#~ Affix::args( Pointer [Int] );
#
done_testing;
