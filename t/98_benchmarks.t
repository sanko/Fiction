use v5.38;
use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[Double];
BEGIN { chdir '../' if !-d 't'; }
$|++;
#
use Benchmark qw[:all];
my $defined = Affix::Wrap->new( lib => 'm', symbol => 'pow', argtypes => [ Double, Double ], restype => Double );
my $context = Affix::Wrap->new( lib => 'm', symbol => 'pow', restype  => Double );
my $fiction = Affix::fiction( Affix::find_library('m'), 'pow', [ Double, Double ], Double );
ok  81 == $fiction->( 3.0, 4.0 ), 'fiction 1';
ok 22876792454961 == $fiction->( 9.0, 14.0 ), 'fiction 2';
ok 22876792454961 == pow( 9.0, 14.0 ), 'pow 2';

sub pow {
    my ( $x, $y ) = @_;
    return $x**$y;
}

# Use Perl code in strings...
cmpthese timethese(
    -10,
    {   'fiction' => sub { $fiction->( 3.0, 4.0 ) },

        #~ 'defined'  => sub { $defined->call( 3,   4 ) },
        #~ 'context'  => sub { $context->call( 3.0, 4.0 ) },
        #~ 'definedX' => sub { Affix::Wrap::call( $defined, 3,   4 ) },
        #~ 'contextX' => sub { Affix::Wrap::call( $context, 3.0, 4.0 ) },
        'pureint' => sub {
            pow( 3, 4 );
        },
        'puredec' => sub {
            pow( 3.0, 4.0 );
        }
    }
);
pass 'benchmarks';
#
done_testing;
