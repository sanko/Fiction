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

# Use Perl code in strings...
cmpthese timethese(
    -10,
    {   'defined'  => sub { $defined->call( 3,   4 ) },
        'context'  => sub { $context->call( 3.0, 4.0 ) },
        'definedX' => sub { Affix::Wrap::call( $defined, 3,   4 ) },
        'contextX' => sub { Affix::Wrap::call( $context, 3.0, 4.0 ) },
        'pureint'  => sub {
            sub { $_[0]**$_[1] }
                ->( 3, 4 );
        },
        'puredec' => sub {
            sub { $_[0]**$_[1] }
                ->( 3.0, 4.0 );
        }
    }
);
pass 'benchmarks';
#
done_testing;
