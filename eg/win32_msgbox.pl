use strict;
use warnings;
use lib '../lib', '../blib/arch', '../blib/lib';
use Affix;
$|++;
#
CORE::say 'MessageBoxA(...) = ' .
    wrap( 'C:\Windows\System32\user32.dll', 'MessageBoxA', [ UInt, String, String, UInt ] => Int )
    ->( 0, 'JAPH!', 'Hello, World', 0 );
