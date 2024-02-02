use v5.38;
use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[Double];
BEGIN { chdir '../' if !-d 't'; }
$|++;
#
use Benchmark qw[:all];
my $defined  = Affix::Wrap->new( lib => 'm', symbol => 'pow', argtypes => [ Double, Double ], restype => Double );
my $context  = Affix::Wrap->new( lib => 'm', symbol => 'pow', restype  => Double );
my $fiction1 = Affix::fiction( Affix::find_library('m'), 'pow', [ Double, Double ], Double );
my $fiction2 = Affix::fiction( Affix::find_library('m'), 'pow' );
ok 81 == $fiction1->( 3, 4 ),          'fiction 1';
ok 81 == $fiction2->( 3.0, 4.0 ),      'fiction 2';
ok 22876792454961 == pow( 9.0, 14.0 ), 'pow 1';

sub pow {
    my ( $x, $y ) = @_;
    return $x**$y;
}

# Use Perl code in strings...
cmpthese timethese(
    -10,
    {   'fiction w/ known argtypes' => sub { $fiction1->( 3, 4 ) },
        'fiction using context'     => sub { $fiction2->( 3.0, 4.0 ) },

        #~ 'defined'  => sub { $defined->call( 3,   4 ) },
        #~ 'context'  => sub { $context->call( 3.0, 4.0 ) },
        #~ 'definedX' => sub { Affix::Wrap::call( $defined, 3,   4 ) },
        #~ 'contextX' => sub { Affix::Wrap::call( $context, 3.0, 4.0 ) },
        'pure perl int' => sub {
            pow( 3, 4 );
        },
        'pure perl dec' => sub {
            pow( 3.0, 4.0 );
        }
    }
);
pass 'benchmarks';
#
done_testing;
