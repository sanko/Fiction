use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix;
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
#~ use Devel::LeakTrace;
# does not work on windows:
my $lib = Affix::locate_lib( Affix::Platform::OS() =~ /Win\d\d/ ? 'C:\WINDOWS\SYSTEM32\ntdll.dll' : 'm' );


diag readlink $lib if -l $lib;
diag $lib;


my $dir = '/usr/lib/x86_64-linux-gnu/';
opendir my $dh, $dir or die "Could not open '$dir' for reading '$!'\n";
my @things = grep {$_ ne '.' and $_ ne '..'} readdir $dh;
foreach my $thing (@things) {
    CORE::say $thing;
}
closedir $dh;

my $ref = Affix::load_lib($lib);
diag $_ for @{ Affix::Lib::list_symbols($ref) };
#
pass 'yep';
#
done_testing;
