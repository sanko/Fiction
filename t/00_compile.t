use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
#
diag 'perl ' . $^V . ' @ ' . $^X;
diag 'Affix v' . $Affix::VERSION;
#
diag 'Platform info:';
diag '  dyncall ver: ' . Affix::Platform::DC_Version();
diag '     features: aggrbyval: ' . ( Affix::Platform::AggrByValue() ? 'yes' : 'no' );
diag '                 syscall: ' . ( Affix::Platform::Syscall()     ? 'yes' : 'no' );
diag '     compiler: ' . Affix::Platform::Compiler();
diag ' architecture: ' . Affix::Platform::Architecture();
diag '  object type: ' . Affix::Platform::OBJ();
diag '           os: ' . Affix::Platform::OS();
diag '          $^O: ' . $^O;

if ( Affix::Platform::OS() =~ /Win32/ ) {
    diag '               Cygwin: ' . ( Affix::Platform::MS_Cygwin() ? 'yes' : 'no' );
    diag '                MinGW: ' . ( Affix::Platform::MS_MinGW()  ? 'yes' : 'no' );
    diag '               MSVCRT: ' . ( Affix::Platform::MS_CRT()    ? 'yes' : 'no' );
}
if ( Affix::Platform::Architecture() =~ /ARM/ ) {
    diag '                    Thumb: ' . ( Affix::Platform::ARM_Thumb() ? 'yes' : 'no' );
    diag '               Hard Float: ' . ( Affix::Platform::HardFloat() ? 'yes' : 'no' );
    diag '                     EABI: ' . ( Affix::Platform::ARM_EABI()  ? 'yes' : 'no' );
    diag '                     OABI: ' . ( Affix::Platform::ARM_OABI()  ? 'yes' : 'no' );
}
elsif ( Affix::Platform::Architecture() =~ /MIPS/ ) {
    diag '                   o32 CC: ' . ( Affix::Platform::MIPS_O32()  ? 'yes' : 'no' );
    diag '               Hard Float: ' . ( Affix::Platform::HardFloat() ? 'yes' : 'no' );
    diag '                     EABI: ' . ( Affix::Platform::MIPS_EABI() ? 'yes' : 'no' );
}
subtest 'API' => sub {
    subtest 'type system' => sub {
        can_ok __PACKAGE__, $_ for qw[
            Void
            Bool
            Char UChar SChar WChar
            Short UShort
            Int UInt
            Long ULong
            LongLong ULongLong
            Float Double
            Size_t SSize_t
            String WString
            Struct Array
            Pointer
            Callback
            SV
            Enum
            IntEnum
            UIntEnum
            CharEnum];
        isa_ok $_, ['Affix::Type']
            for Void, Bool, Char, UChar, SChar, WChar, Short, UShort, Int, UInt, Long, ULong, LongLong, ULongLong, Float, Double, Size_t, SSize_t,
            String, WString, Struct [], Struct [ a => Int, b => Double ], SV, Pointer [Void], Array [Int], Callback [ [ Int, Float, Int ] => Void ];
        Affix::Type::Enum::Enum( [qw[a b c]] );
    };
    subtest 'core' => sub {
        can_ok __PACKAGE__, $_ for qw[affix wrap pin unpin];
    };
    subtest 'memory' => sub {
        can_ok __PACKAGE__, $_ for qw[malloc calloc realloc free memchr memcmp memset memcpy sizeof offsetof raw hexdump];
    };
    subtest 'internals' => sub {
        can_ok 'Affix', $_ for qw[find_library load_library free_library find_symbol];
    }
};
#
diag 'SIZEOF_WCHAR: ' . Affix::Platform::SIZEOF_WCHAR();
#
done_testing;
