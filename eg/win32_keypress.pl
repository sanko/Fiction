use strict;
use warnings;
use lib '../lib', '../blib/arch', '../blib/lib';
use Affix;
$|++;

# Based on https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-keybd_event
use constant { VK_VOLUME_DOWN => 0xAE, VK_VOLUME_UP => 0xAF, VK_VOLUME_MUTE => 0xAD, KEYEVENTF_KEYUP => 2 };
#
affix 'user32', keybd_event => [ UChar, UChar, Int, Pointer [ULong] ] => Void;

# simulate pressing the mute key on the keyboard
keybd_event( VK_VOLUME_MUTE, 0, 0,                 undef );
keybd_event( VK_VOLUME_MUTE, 0, KEYEVENTF_KEYUP(), undef );
