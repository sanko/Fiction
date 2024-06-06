use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:types];
$|++;
use t::lib::helper;
plan skip_all 'dyncall does not support passing aggregates by value on this platform' unless Affix::Platform::AggrByValue();
#
ok my $lib = compile_test_lib(<<''), 'build test lib';
#include "std.h"
// ext: .c
typedef struct {
    bool is_true;
    char ch;
    unsigned char uch;
    /*short s;
    unsigned short S;
    /*int i;
    /*unsigned int I;
    /*long l;
    /*unsigned long L;
    /*long long ll;
    /*unsigned long long LL;
    /*float f;
    /*double d;
    /*void * ptr;
    /*const char * str;*/
    // TODO:
    // Union
    // Struct
    // WChar
    // WString
    // CodeRef
    // Pointer[SV]
} Example;
bool get_bool(Example ex) { DumpHex(&ex, sizeof(Example));return ex.is_true; }
char get_char(Example ex) { return ex.ch; }
unsigned char get_uchar(Example ex) { return ex.uch; }
//unsigned char get_uchar(Example ex) { return ex.uc; }
size_t SIZEOF(){return sizeof(Example);}

typedef Example => Struct [ bool => Bool, char => Char, uchar => UChar,
#short => Short, ushort => UShort
];
subtest 'affix functions' => sub {
    isa_ok Affix::affix( $lib, 'SIZEOF',   [],            Size_t ), [qw[Affix]], 'SIZEOF';
    isa_ok Affix::affix( $lib, 'get_bool', [ Example() ], Bool ),   [qw[Affix]], 'get_bool';
    isa_ok Affix::affix( $lib, 'get_char', [ Example() ], Char ),   [qw[Affix]], 'get_char';
    isa_ok Affix::affix( $lib, 'get_uchar', [ Example() ], UChar ),   [qw[Affix]], 'get_uchar';

    #~ isa_ok Affix::affix( $lib, 'get_uchar', [ Example() ], UChar ), [qw[Affix]], 'get_uchar';
};
my $struct = { bool => !0, char => 'q', uchar => 'A', short => 1000, ushort => 100, };
is Affix::Type::sizeof( Example() ), SIZEOF(), 'our size calculation vs platform';
is get_bool($struct),                T(),      'get_bool( $struct )';

#~ is $fn->( { b => 1,  padding => 0 } ), T(), 'return from $fn->({ ..., b => 1 }) is true';
done_testing;
