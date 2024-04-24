use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
use Data::Dump;
isa_ok my $ptr = Affix::sv2ptr( Pointer [Char], 'This is a test' ), ['Affix::Pointer'], 'This is a test';
is $ptr->raw( Affix::Platform::SIZEOF_CHAR() * 14 ), 'This is a test', '$ptr->raw( ' . Affix::Platform::SIZEOF_CHAR() * 14 . ' )';
free $ptr;
{
    my @types = (
        Affix::Void(), Affix::Bool(), Affix::Char(), Affix::SChar(), Affix::UChar(), Affix::Short(), Affix::UShort(), Affix::Int(), Affix::UInt(),

        # ...
        Affix::Pointer [ Affix::Bool() ]
    );
    ddx \@types;
    warn sprintf "%c => %3d [%s]", $_, $_, $_ for @types;
    warn "$_" for @types;
}
{

    sub build_and_test {
        my ( $name, $c, $arg_types, $ret_type, $arg1, $ret_check ) = @_;
        subtest $name => sub {
            plan 3;
            ok my $lib    = compile_test_lib($c), 'build test lib';
            isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $fn = ...';
            is $fn->( defined $arg1 ? ref $arg1 eq 'ARRAY' ? @$arg1 : $arg1 : () ), $ret_check, 'return from $fn->(...) is correct';
        }
    }
    build_and_test 'char fn(char)' => <<'', [Char], Char, 'a', 'b';
#include "std.h"
// ext: .c
char fn(char i) {
    wchar_t hey =L'は';
    DumpHex(&hey, 16);
    return i + 1;
}

}
is Affix::String, 'Pointer[ Const[ Char ] ]', 'stringify const char *';
use Data::Dump;
ddx CodeRef [ [] => Void ];
subtest compiled => sub {
    my $lib = compile_test_lib(<<'END');
#include "std.h"
// ext: .c
DLLEXPORT int ptr(bool * ptr) {
    if(ptr == NULL) return -1;
    int _true = 0;
    for (int i = 0; i < 4; i++)
        _true += !!ptr[i];
    return _true;
}

DLLEXPORT int * ptr_return() {
    int* flags = (int*)malloc(sizeof(int) * 5);
    for (int i = 0; i<=5; i++) flags[i] = i;
    flags[2] = 200;
    return flags;
}

typedef struct {
    int i;
} oy;

typedef struct {
    int i;
    const char * a;
} qqqq;

DLLEXPORT int * ptr_return_struct() {
warn("size; %d, %d", sizeof(oy), sizeof(qqqq));
    oy* flags = (oy*)malloc(sizeof(oy) * 5);
    for (int i = 0; i<=5; i++) flags[i].i = i;
    //flags[2] = 200;
    return flags;
}

DLLEXPORT bool * ptr_return_NULL() {
    return NULL;
}
END
    subtest 'int ptr(bool *)' => sub {
        ok my $ax = Affix::wrap( $lib => 'ptr', [ Pointer [Bool] ] => Int ), 'wrap';
        my $ptr = [ 1, 0, 1, 1 ];
        is $ax->($ptr),  3,  'C understood we sent three true values';
        is $ax->(undef), -1, 'C understood we sent a NULL pointer';
    };
    my $ptr = Affix::wrap( $lib, 'ptr_return', [], Pointer [Int] )->();
    ddx $ptr;
    my $ptr_structs = Affix::wrap( $lib, 'ptr_return_struct', [], Pointer [ Struct [ i => Int ] ] )->();

    package Affix::Pointer {    # [address, type, length = 0, offset = 0]
        use overload
            '++' => sub { $_[0][3]++; $_[0]; },
            '--' => sub { $_[0][3]--; $_[0]; },
            '""' => sub { $_[0][0] + ( $_[0][3] * $_[0][1]->sizeof ); },    # return address (address + (offset * sizeof(type))

            #~ 'int' => sub {...},    # return address (address + (offset * sizeof(type))
            '${}'    => sub { \shift->sv(); },                              # return current element (address + (offset * sizeof(type))
            'bool'   => sub { return 1; ... },                              # return true if ! NULL
            fallback => 2;
        #
        #~ sub cast( $ptr, $new_type ) {        }
        #~ DESTROY { warn '# TODO: call free(...)' }
    };

    package Affix::Pointer::Unmanaged {    # [address, type, length = 0, offset = 0]
        our @ISA = ('Affix::Pointer');

        #~ DESTROY { }
    }

    #~ ddx $ptr;
    is $$ptr, 0;
    ok $ptr++;
    is $$ptr, 1;
    ok $ptr++;
    is $$ptr, 200;
    #
    #~ ddx $ptr_structs;
    diag Int->sizeof;
    diag Struct( [ i => Int, c=>String ] )->sizeof;
    ddx Struct( [ i => Int, c=>String ] );
    ddx $$ptr_structs;
    $ptr_structs++;
    ddx $$ptr_structs;
    $ptr_structs++;
    ddx $$ptr_structs;
};

#~ diag CodeRef [ [] => Void ];
warn 'left';
done_testing;
__END__
subtest pin => sub {
    ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
extern int var;
int var = 100;
int verify(){return var;}

    ok my $verify = Affix::wrap( $lib, 'verify', [] => Int ), 'wrap( ..., "verify", ... )';
    ok pin( my $var, $lib, 'var', Int ),                      'pin( my $var, ... )';
    is $var, 100, '$var == 100';
    subtest 200 => sub {
        is $var = 200,  200, '$var = 200';
        is $var,        200, '$var == 200';
        is $verify->(), 200, '$verify->() == 200';
    };
    subtest 120 => sub {
        is $var = 120,  120, '$var = 120';
        is $var,        120, '$var == 120';
        is $verify->(), 120, '$verify->() == 120';
    };
    subtest unpin => sub {
        ok unpin($var), 'unpin( ... )';
        is $var = 300,  300, '$var = 300';
        is $var,        300, '$var == 300';
        is $verify->(), 120, '$verify->() == 120 (still)';
    }
};
done_testing;
exit;
__END__
use Data::Dump;
isa_ok my $ptr = Affix::sv2ptr( Array [ Bool, 6 ], [ 1, 1, 0, 1, 0, 0 ] ), ['Affix::Pointer'], 'false';
$ptr->dump( Affix::Platform::SIZEOF_BOOL() * 6 );
use Data::Dump;
ddx $ptr;
ddx $ptr->sv;
__END__
die;
ddx Array [ Int,     5 ];
ddx Array [ Pointer, 5 ];
ddx Array [ Array [ Int, 5 ], 10 ];
die;

# int[5];
#~ Array [ Int, 5 ];
#~ Array [ Enum [ 'A', 'B', [ C => 10 ], 'D', [ E => 1 ], 'F', [ G => 'F + C' ] ], 5 ];
ddx Pointer [ Enum [ 'A', 'B', [ C => 10 ], 'D', [ E => 1 ], 'F', [ G => 'F + C' ] ], 5, Int ];
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
