use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use Test2::Plugin::UTF8;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
sub build_and_test {
    my ( $name, $c, $arg_types, $ret_type, $arg1, $ret, $ret_check, $flags ) = @_;
    subtest $name => sub {
    SKIP: {
            ok my $lib = compile_test_lib( $c, $flags // () ), 'build test lib';
            skip 'Failed to build library' unless $lib;
            isa_ok my $fn = Affix::wrap( $lib, 'fn', $arg_types, $ret_type ), [qw[Affix]], 'my $fn = ...';
            is $fn->(
                sub {
                    is \@_, $arg1, '@_ in $fn is correct';
                    diag $ret;
                    return $ret;
                }
                ),
                $ret_check, 'return from $fn->(sub {[...]}) is correct';
        }
    }
}
#
build_and_test
    'typedef void cb(void)' => <<'', [ CodeRef [ [] => Void ] ], Void, [], U(), U();
#include "std.h"
// ext: .c
typedef void cb(void);
void fn(cb *CodeRef) {
    CodeRef();
}

subtest bool => sub {
    build_and_test
        'typedef bool cb(bool) false' => <<'', [ CodeRef [ [Bool] => Bool ] ], Bool, [ F() ], !1, F();
#include "std.h"
// ext: .c
typedef bool cb( bool );
bool fn(cb *CodeRef) {
    return CodeRef(false);
}

    build_and_test
        'typedef bool cb(bool) true' => <<'', [ CodeRef [ [Bool] => Bool ] ], Bool, [ T() ], !0, T();
#include "std.h"
// ext: .c
typedef bool cb( bool );
bool fn(cb *CodeRef) {
    return CodeRef(true);
}

};
subtest char => sub {
    build_and_test
        'typedef char cb(char)' => <<'', [ CodeRef [ [Char] => Char ] ], Char, ['a'], 'm', 'm';
#include "std.h"
// ext: .c
typedef char cb( char );
char fn(cb *CodeRef) {
    return CodeRef('a');
}

    build_and_test
        'typedef signed char cb(char)' => <<'', [ CodeRef [ [Char] => Char ] ], Char, [ pack 'c', -ord 'a' ], 'm', 'm';
#include "std.h"
// ext: .c
typedef char cb( char );
char fn(cb *CodeRef) {
    return CodeRef(-'a');
}

    build_and_test
        'typedef char cb(char) with ints' => <<'', [ CodeRef [ [Char] => Char ] ], Char, ['a'], 109, 'm';
#include "std.h"
// ext: .c
typedef char cb( char );
char fn(cb *CodeRef) {
    return CodeRef(97);
}

};
subtest schar => sub {
    build_and_test
        'typedef signed char cb(char)' => <<'', [ CodeRef [ [SChar] => SChar ] ], Char, ['a'], 'm', 'm';
#include "std.h"
// ext: .c
typedef signed char cb( signed char );
signed char fn(cb *CodeRef) {
    return CodeRef('a');
}

    build_and_test
        'typedef signed char cb(char)' => <<'', [ CodeRef [ [SChar] => SChar ] ], SChar, [ pack 'c', -ord 'a' ], 'm', 'm';
#include "std.h"
// ext: .c
typedef signed char cb( signed char );
signed char fn(cb *CodeRef) {
    return CodeRef(-'a');
}

    build_and_test
        'typedef signed char cb(char) with ints' => <<'', [ CodeRef [ [SChar] => SChar ] ], SChar, ['a'], 109, 'm';
#include "std.h"
// ext: .c
typedef signed char cb( signed char );
signed char fn(cb *CodeRef) {
    return CodeRef(97);
}

};
subtest uchar => sub {
    build_and_test
        'typedef unsigned char cb(unsigned char)' => <<'', [ CodeRef [ [UChar] => UChar ] ], UChar, ['a'], 'm', 'm';
#include "std.h"
// ext: .c
typedef signed char cb( unsigned char );
unsigned char fn(cb *CodeRef) {
    return CodeRef('a');
}

    build_and_test
        'typedef unsigned char cb(unsigned char) with ints' => <<'', [ CodeRef [ [UChar] => UChar ] ], UChar, ['a'], 109, 'm';
#include "std.h"
// ext: .c
typedef unsigned char cb( unsigned char );
unsigned char fn(cb *CodeRef) {
    return CodeRef(97);
}

};
subtest wchar_t => sub {
    build_and_test
        'typedef wchar_t cb(wchar_t)' => <<'', [ CodeRef [ [WChar] => WChar ] ], WChar, ['愛'], '絆', '絆';
#include "std.h"
// ext: .c
typedef wchar_t cb( wchar_t );
wchar_t fn(cb *CodeRef) {
    fflush(stdout);
    return CodeRef(L'愛');
}

};
subtest short => sub {
    build_and_test
        'typedef short cb(short, short)' => <<'', [ CodeRef [ [ Short, Short ] => Short ] ], Short, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef short cb(short, short);
short fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest ushort => sub {
    build_and_test
        'typedef unsigned short cb(unsigned short, unsigned short)' =>
        <<'', [ CodeRef [ [ UShort, UShort ] => UShort ] ], UShort, [ 100, 200 ], 500, 500;
#include "std.h"
// ext: .c
typedef short cb(unsigned short, unsigned short);
unsigned short fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest int => sub {
    build_and_test
        'typedef int cb(int, int)' => <<'', [ CodeRef [ [ Int, Int ] => Int ] ], Int, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef int cb(int, int);
int fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest uint => sub {
    build_and_test
        'typedef unsigned int cb(unsigned int, unsigned int)' => <<'', [ CodeRef [ [ UInt, UInt ] => UInt ] ], UInt, [ 100, 200 ], 600, 600;
#include "std.h"
// ext: .c
typedef int cb(unsigned int, unsigned int);
unsigned int fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest long => sub {
    build_and_test
        'typedef long cb(long, long)' => <<'', [ CodeRef [ [ Long, Long ] => Long ] ], Long, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef long cb(long, long);
long fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest ulong => sub {
    build_and_test
        'typedef unsigned long cb(unsigned long, unsigned long)' => <<'', [ CodeRef [ [ ULong, ULong ] => ULong ] ], ULong, [ 100, 200 ], 600, 600;
#include "std.h"
// ext: .c
typedef long cb(unsigned long, unsigned long);
unsigned long fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest longlong => sub {
    build_and_test
        'typedef long long cb(long long, long long)' => <<'', [ CodeRef [ [ LongLong, LongLong ] => LongLong ] ], LongLong, [ 100, 200 ], -600, -600;
#include "std.h"
// ext: .c
typedef long cb(long long, long long);
long long fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest ulonglong => sub {
    build_and_test
        'typedef unsigned long cb(unsigned long long, unsigned long long)' =>
        <<'', [ CodeRef [ [ ULongLong, ULongLong ] => ULongLong ] ], ULongLong, [ 100, 200 ], 600, 600;
#include "std.h"
// ext: .c
typedef long long cb(unsigned long long, unsigned long long);
unsigned long long fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest size_t => sub {
    build_and_test
        'typedef size_t cb(size_t, size_t)' => <<'', [ CodeRef [ [ Size_t, Size_t ] => Size_t ] ], Size_t, [ 100, 200 ], 300, 300;
#include "std.h"
// ext: .c
typedef size_t cb(size_t, size_t);
size_t fn(cb *CodeRef) {
    return CodeRef(100, 200);
}

};
subtest float => sub {
    build_and_test
        'typedef float cb(float, float)' =>
        <<'', [ CodeRef [ [ Float, Float ] => Float ] ], Float, [ float( 1.5, tolerance => 0.01 ), float( 3.98, tolerance => 0.01 ) ], 4.3, float( 4.3, tolerance => 0.01 );
#include "std.h"
// ext: .c
typedef float cb(float, float);
float fn(cb *CodeRef) {
    return CodeRef(1.5, 3.98);
}

};
subtest double => sub {
    build_and_test
        'typedef double cb(double, double)' =>
        <<'', [ CodeRef [ [ Double, Double ] => Double ] ], Double, [ float( 1.5, tolerance => 0.01 ), float( 3.98, tolerance => 0.01 ) ], 4.3, float( 4.3, tolerance => 0.01 );
#include "std.h"
// ext: .c
typedef double cb(double, double);
double fn(cb *CodeRef) {
    return CodeRef(1.5, 3.98);
}

};
subtest string => sub {
    build_and_test
        'typedef const char * cb(const char *, const char *)' =>
        <<'', [ CodeRef [ [ String, String ] => String ] ], String, [ 'Hey this is not working but it also is not broken yet', 'Hello' ], 'Return a long line of text that should wrap around and test the length is correct.', 'Return a long line of text that should wrap around and test the length is correct.';
#include "std.h"
// ext: .c
typedef const char * cb(const char *, const char *);
const char * fn(cb *CodeRef) {
    return CodeRef("Hey this is not working but it also is not broken yet", "Hello");
}

};
subtest wstring => sub {
    build_and_test
        'typedef const wchar_t * cb(const wchar_t *, const wchar_t *)' =>
        <<'', [ CodeRef [ [ WString, WString ] => WString ] ], WString, [ '1兆ドル', '100億ドル' ], 'ポケットチェンジ（冗談）', 'ポケットチェンジ（冗談）';
#include "std.h"
#include <wchar.h>
// ext: .c
typedef const wchar_t * cb(const wchar_t *, const wchar_t *);
const wchar_t * fn(cb *CodeRef) {
    return CodeRef(L"1兆ドル", L"100億ドル");
}

};
subtest sv => sub {
          my $todo = todo 'Might fail';
    use ExtUtils::Embed;
    my $flags = `$^X -MExtUtils::Embed -e ccopts -e ldopts`;
    $flags =~ s[\R][ ]g;
    build_and_test
        'typedef const SV* * cb(SV*, SV*)' =>
        <<'', [ CodeRef [ [ Pointer [SV], Pointer [SV] ] => Pointer [SV] ] ], Pointer [SV], [ {}, [] ], [100], [100], $flags;
#define PERL_NO_GET_CONTEXT 1
#include <EXTERN.h>
#include <perl.h>
#include <perliol.h>
#define NO_XSLOCKS /* XSUB.h will otherwise override various things we need */
#include <XSUB.h>
#define NEED_sv_2pv_flags
#include "patchlevel.h" /* for local_patches */
#include "std.h"
// ext: .c
typedef SV * cb(SV *, SV *);
SV * fn(cb *CodeRef) {
    dTHX;
    SV *hv, *av;
    {
        HV * h = newHV();
	    hv = newRV_inc(MUTABLE_SV(h));
    }
    {
        AV * a = newAV();
	    av = newRV_inc(MUTABLE_SV(a));
    }
    //hv = (newSV(0));
    //av = (newSV(0));
    return CodeRef(hv, av);
}

};

#define STDSTRING_FLAG 'Y'
#define STRUCT_FLAG 'A'
#define CPPSTRUCT_FLAG 'B'
#define UNION_FLAG 'u'
#define CODEREF_FLAG '&'
#define POINTER_FLAG 'P'
#define SV_FLAG '?'
subtest enum => sub {
    typedef TV => Enum [ [ FOX => 11 ], [ CNN => 25 ], [ ESPN => 15 ], [ HBO => 22 ], [ NBC => 32 ] ];
    build_and_test
        'typedef enum TV cb(enum TV)' => <<'', [ CodeRef [ [ TV() ] => TV() ] ], TV(), [ int TV::ESPN() ], TV::HBO(), int TV::HBO();
#include "std.h"
// ext: .c
enum TV { FOX = 11, CNN = 25, ESPN = 15, HBO = 22, MAX = 30, NBC = 32 };
typedef enum TV cb(enum TV);
enum TV fn(cb *CodeRef) {
    return CodeRef(ESPN);
}

};
done_testing;
