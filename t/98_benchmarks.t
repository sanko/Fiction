use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[wrap affix find_library Double];
BEGIN { chdir '../' if !-d 't'; }
use Benchmark qw[:all];

#~ plan skip_all 'No benchmarking!' unless $ENV{AUTOMATED_TESTING} || $ENV{AUTHOR_TESTING};
$|++;
#
my $wrap_w_params  = wrap( find_library('m'), 'pow', [ Double, Double ], Double );
my $wrap_w_context = wrap( find_library('m'), 'pow' );
affix( find_library('m'), [ 'pow' => 'affix_w_params' ], [ Double, Double ], Double );
affix( find_library('m'), [ 'pow' => 'affix_w_context' ] );
#
ok 81 == $wrap_w_params->( 3, 4 ),      'wrap w/ params';
ok 81 == $wrap_w_context->( 3.0, 4.0 ), 'wrap q/ context';
ok 81 == affix_w_params( 3, 4 ),        'affix w/ params';
ok 81 == affix_w_context( 3.0, 4.0 ),   'affix q/ context';
ok 22876792454961 == pow( 9, 14 ),      'pure perl [Int, Int]';
ok 22876792454961 == pow( 9.0, 14.0 ),  'pure perl [Double, Double]';

sub pow {
    my ( $x, $y ) = @_;
    return $x**$y;
}
{
    diag 'running benchmarks...';
    my $old_fh = select(STDOUT);                 # Temporarily save original STDOUT
    open( my $capture_fh, '>', \my $stdout );    # Open a filehandle to capture output
    select($capture_fh);                         # Redirect STDOUT to the capture filehandle
    cmpthese timethese(
        -10,
        {   'Affix::wrap w/ known argtypes' => sub { $wrap_w_params->( 3, 4 ) },
            'Affix::wrap using context'     => sub { $wrap_w_context->( 3.0, 4.0 ) },
            'affix w/ known argtypes'       => sub { affix_w_params( 3, 4 ) },
            'affix using context'           => sub { affix_w_context( 3.0, 4.0 ) },
            'pure perl [Int, Int]'          => sub { pow( 3,   4 ) },
            'pure perl [Double, Double]'    => sub { pow( 3.0, 4.0 ) }
        }
    );
    select($old_fh);                             # Restore original STDOUT
    close($capture_fh);                          # Close the capture filehandle
    diag $stdout;
}
#
done_testing;
