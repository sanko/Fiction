use lib '../lib', '../blib/arch', '../blib/lib';
use Affix;
my $libfile = Affix::find_library( $^O eq 'MSWin32' ? 'msvcrt.dll' : 'm' );
#
CORE::say 'sqrtf(36.f) = ' . Affix::wrap( $libfile, 'sqrtf', [Float] => Float )->(36.0);
CORE::say 'pow(2.0, 10.0) = ' . Affix::wrap( $libfile, 'pow', [ Double, Double ] => Double )->( 2.0, 10.0 );
