use v5.38;
use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[Double];
BEGIN { chdir '../' if !-d 't'; }
$|++;
#
use Benchmark qw[:all];
my $fiction1 = Affix::fiction( Affix::find_library('m'), 'pow', [ Double, Double ], Double );
my $fiction2 = Affix::fiction( Affix::find_library('m'), 'pow' );
ok 81 == $fiction1->( 3, 4 ),          'fiction 1';
ok 81 == $fiction2->( 3.0, 4.0 ),      'fiction 2';
ok 22876792454961 == pow( 9.0, 14.0 ), 'pow 1';

sub pow {
    my ( $x, $y ) = @_;
    return $x**$y;
}
if ( $ENV{AUTOMATED_TESTING} or $ENV{AUTHOR_TESTING} ) {
    diag 'running benchmarks...';

    my $old_fh = select(STDOUT);                 # Temporarily save original STDOUT
    open( my $capture_fh, '>', \my $stdout );    # Open a filehandle to capture output
    select($capture_fh);                         # Redirect STDOUT to the capture filehandle
    cmpthese timethese(
        -10,
        {   'fiction w/ known argtypes' => sub { $fiction1->( 3, 4 ) },
            'fiction using context'     => sub { $fiction2->( 3.0, 4.0 ) },
            'pure perl int'             => sub { pow( 3,   4 ) },
            'pure perl dec'             => sub { pow( 3.0, 4.0 ) }
        }
    );
    select($old_fh);                             # Restore original STDOUT
    close($capture_fh);                          # Close the capture filehandle
    diag $stdout;
}
#
done_testing;
