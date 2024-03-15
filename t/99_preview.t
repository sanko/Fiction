use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
#~ my $affix = affix 'm', 'pow', [ Struct [ a => Int ] ], Void;
#
#~ pow();
#~ $affix->call();
isa_ok Pointer [Int], [ 'Affix::Type', 'Affix::Type::Pointer' ];
ok my $lib = compile_test_lib('99_preview'), 'compile_test_lib("99_preview")';
diag $lib;
diag `nm $lib`;
warn CodeRef [ [], Int ];
use Data::Dump;
ddx [ CodeRef [ [ Int, Int ] => Int ] ];
#
sub Method($) { }
ddx Struct [ name => String, age => Affix::Type::Function( [ [] => Int ] ) ];
CodeRef [ [] => Int ];
#
{

    package Temp;
    use overload
        '""'     => sub { shift->[0] },
        '+='     => sub { warn '+='; my ( $s, $inc, $dir ) = @_; use Data::Dump; ddx \@_; $s->[0]++; \$s },
        fallback => 1
}
my $ptr = bless [5], 'Temp';
ddx $ptr;
warn $ptr--;
warn $ptr++;
warn join ', ', map { $ptr++ } 1 .. 5;
ddx $$ptr .. ( $$ptr + 10 );
ddx $ptr;
die;

if (0) {
    affix 'fakelib', 'blah', [], Pointer [ Pointer [Int] ];
    my $ptr = blah();
    warn $ptr->[$_] for 0 .. 10;
}
#
{

    sub iterator {
        my ( $value, $max, $step ) = @_;
        return sub {
            return if $value > $max;    # Return undef when we overflow max.
            my $current = $value;
            $value += $step;            # Increment value for next call.
            return $current;            # Return current iterator value.
        };
    }

    # All the even numbers between 0 -  100.
    my $evens = iterator( 0, 100, 2 );
    while ( defined( my $x = $evens->() ) ) {
        print "$x\n";
    }
}
{

    package Affix::Pointer {
        use overload

            #~ '${}' => sub { warn 'scalar'; \'scalar' },
            #~ '@{}' => sub { warn 'array';  use Data::Dump; ['array'] },
            #~ '%{}' => sub { warn 'hash';   \{ 'hash' => 0 } },
            '&{}' => sub { warn 'code'; my ( $s, @etc ) = @_; use Data::Dump; ddx \@_; \undef }
    };
    my $type = Pointer [ Int, 10 ];
    my $ptr  = Affix::sv2ptr( $type, [ 1, 2, 3, 4, 5 ] );
    ddx $ptr;
    ddx $ptr->sv();
}
#
#~ diag find_library 'm';
#~ diag find_library 'c';
#~ diag find_library 'bz2';
#~ my $getpid = wrap libc, 'getpid', [], Int;
#~ diag $getpid->();
#
#~ diag $xxx->( sub { diag 'hi'; ... } );
#~ typedef int cb(int, int);
#~ Affix::args( Pointer [Int] );
#
done_testing;
