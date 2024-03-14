use lib '../../lib', 'lib', '../../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix;
#
affix 'notify', 'notify_init',              [String];
affix 'notify', 'notify_uninit',            [];
affix 'notify', 'notify_notification_new',  [ String, String, String ] => Pointer [Void];
affix 'notify', 'notify_notification_show', [ Pointer [Void], Pointer [Void] ];
#
my $message = "Hello from Affix!\nWelcome to the fun\nworld of Affix";
notify_init('Affix 🏒');
my $n = notify_notification_new( 'Keep your stick on the ice! 🏒', $message, 'dialog-information' );
notify_notification_show( $n, undef );
notify_uninit();
