use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
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
if ( Affix::Platform::ARCH_ARM() ) {
    diag '                    Thumb: ' . ( Affix::Platform::ARM_Thumb() ? 'yes' : 'no' );
    diag '               Hard Float: ' . ( Affix::Platform::HardFloat() ? 'yes' : 'no' );
    diag '                     EABI: ' . ( Affix::Platform::ARM_EABI()  ? 'yes' : 'no' );
    diag '                     OABI: ' . ( Affix::Platform::ARM_OABI()  ? 'yes' : 'no' );
}
elsif ( Affix::Platform::ARCH_MIPS() ) {
    diag '                   o32 CC: ' . ( Affix::Platform::MIPS_O32()  ? 'yes' : 'no' );
    diag '               Hard Float: ' . ( Affix::Platform::HardFloat() ? 'yes' : 'no' );
    diag '                     EABI: ' . ( Affix::Platform::MIPS_EABI() ? 'yes' : 'no' );
}
subtest 'API' => sub {
    subtest 'type system' => sub {
        imported_ok qw[
            Void
            Bool
            Char UChar SChar WChar
            Short UShort
            Int UInt
            Long ULong
            LongLong ULongLong
            Float Double
            Size_t
            String WString
            Struct
            Pointer
            Callback
            SV
            Enum
            IntEnum
            UIntEnum
            CharEnum];
        isa_ok $_, ['Affix::Type']
            for Void, Bool, Char, UChar, SChar, WChar, Short, UShort, Int, UInt, Long, ULong, LongLong, ULongLong, Float, Double, Size_t, String,
            WString, Struct [], Struct [ a => Int, b => Double ], SV, Pointer [Void], Callback [ [ Int, Float, Int ] => Void ];
        Affix::Type::Enum::Enum( [qw[a b c]] );
    };
    subtest 'core' => sub {
        imported_ok qw[affix wrap pin unpin];
    };
    subtest 'memory' => sub {
        imported_ok qw[malloc calloc realloc free memchr memcmp memset memcpy sizeof offsetof raw hexdump];
    };
    subtest 'internals' => sub {
        imported_ok qw[find_library load_library free_library find_symbol];
    }
};
#
done_testing;
