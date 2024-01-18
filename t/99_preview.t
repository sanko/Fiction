use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
my $affix = affix 'm', 'pow', Struct [], Void;
#
pow();
$affix->call();
isa_ok Pointer [Int], [ 'Affix::Type', 'Affix::Type::Pointer' ];
my $lib = compile_test_lib('99_preview');
diag $lib;

#~ Affix::args( Pointer [Int] );
#
done_testing;
