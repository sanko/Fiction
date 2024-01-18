use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix;
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
if ( Affix::Platform::OS() =~ /Win32/ ) {
    diag Affix::locate_lib('ntdll');
}
else {
    diag Affix::locate_lib('m');
}
#
pass 'yep';
#
done_testing;
