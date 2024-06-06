use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:types];
$|++;
use t::lib::helper;
plan skip_all 'dyncall does not support passing aggregates by value on this platform' unless Affix::Platform::AggrByValue();
#
ok my $lib = compile_test_lib('236_types_struct'), 'build test lib';
typedef Example => Struct [
    bool      => Bool,
    char      => Char,
    uchar     => UChar,
    short     => Short,
    ushort    => UShort,
    int       => Int,
    uint      => UInt,
    long      => Long,
    ulong     => ULong,
    longlong  => LongLong,
    ulonglong => ULongLong,
    float     => Float,
    double    => Double,
    ptr       => Pointer [Void],
    str       => String

    #~ TODO:
    #~ Union
    #~ Struct
    #~ WChar
    #~ WString
    #~ CodeRef
    #~ Pointer[SV]
];
use Data::Dump;
ddx Example();
subtest 'affix functions' => sub {
    isa_ok Affix::affix( $lib, 'SIZEOF',        [],            Size_t ),    [qw[Affix]], 'SIZEOF';
    isa_ok Affix::affix( $lib, 'get_bool',      [ Example() ], Bool ),      [qw[Affix]], 'get_bool';
    isa_ok Affix::affix( $lib, 'get_char',      [ Example() ], Char ),      [qw[Affix]], 'get_char';
    isa_ok Affix::affix( $lib, 'get_uchar',     [ Example() ], UChar ),     [qw[Affix]], 'get_uchar';
    isa_ok Affix::affix( $lib, 'get_short',     [ Example() ], Short ),     [qw[Affix]], 'get_short';
    isa_ok Affix::affix( $lib, 'get_ushort',    [ Example() ], UShort ),    [qw[Affix]], 'get_ushort';
    isa_ok Affix::affix( $lib, 'get_int',       [ Example() ], Int ),       [qw[Affix]], 'get_int';
    isa_ok Affix::affix( $lib, 'get_uint',      [ Example() ], UInt ),      [qw[Affix]], 'get_uint';
    isa_ok Affix::affix( $lib, 'get_long',      [ Example() ], Long ),      [qw[Affix]], 'get_long';
    isa_ok Affix::affix( $lib, 'get_ulong',     [ Example() ], ULong ),     [qw[Affix]], 'get_ulong';
    isa_ok Affix::affix( $lib, 'get_longlong',  [ Example() ], LongLong ),  [qw[Affix]], 'get_longlong';
    isa_ok Affix::affix( $lib, 'get_ulonglong', [ Example() ], ULongLong ), [qw[Affix]], 'get_ulonglong';
    isa_ok Affix::affix( $lib, 'get_float',     [ Example() ], Float ),     [qw[Affix]], 'get_float';
    isa_ok Affix::affix( $lib, 'get_double',    [ Example() ], Double ),    [qw[Affix]], 'get_double';

    # TODO
    isa_ok Affix::affix( $lib, 'get_ptr', [ Example() ], Pointer [Void] ), [qw[Affix]], 'get_ptr';
    isa_ok Affix::affix( $lib, 'get_str', [ Example() ], String ),         [qw[Affix]], 'get_str';
};
my $struct = {
    bool      => !0,
    char      => 'q',
    uchar     => 'Q',
    short     => 1000,
    ushort    => 100,
    int       => 12345,
    uint      => 999,
    long      => 987654321,
    ulong     => 789,
    longlong  => 2345,
    ulonglong => 11111111,
    float     => 3.14,
    double    => 1.2345,
    ptr       => 'Anything can go here',
    str       => 'Anything can go here too'
};
is Affix::Type::sizeof( Example() ), SIZEOF(),                               'our size calculation vs platform';
is get_bool($struct),                T(),                                    'get_bool( $struct )';
is get_char($struct),                'q',                                    'get_char( $struct )';
is get_uchar($struct),               'Q',                                    'get_uchar( $struct )';
is get_short($struct),               1000,                                   'get_short( $struct )';
is get_ushort($struct),              100,                                    'get_ushort( $struct )';
is get_int($struct),                 12345,                                  'get_int( $struct )';
is get_uint($struct),                999,                                    'get_uint( $struct )';
is get_long($struct),                987654321,                              'get_long( $struct )';
is get_ulong($struct),               789,                                    'get_ulong( $struct )';
is get_longlong($struct),            2345,                                   'get_longlong( $struct )';
is get_ulonglong($struct),           11111111,                               'get_ulonglong( $struct )';
is get_float($struct),               float( 3.14, tolerance => 0.000001 ),   'get_float( $struct )';
is get_double($struct),              float( 1.2345, tolerance => 0.000001 ), 'get_double( $struct )';

#~ TODO:
#~ is get_ptr($struct),                'Anything can go here',      'get_ptr( $struct )';
#~ is get_str($struct),                'Anything can go here',      'get_str( $struct )';
done_testing;
