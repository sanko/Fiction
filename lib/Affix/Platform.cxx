#include "../Affix.h"

void boot_Affix_Platform(pTHX_ CV *cv) {
    PERL_UNUSED_VAR(cv);

    // dyncall/dyncall_version.h
    register_constant("Affix::Platform", "DC_Version",
                      Perl_newSVpvf(aTHX_ "%d.%d-%7s", (DYNCALL_VERSION >> 12),
                                    (DYNCALL_VERSION >> 8) & 0xf,
                                    (((DYNCALL_VERSION & 0xf) == 0xf) ? "release" : "current")));
    register_constant("Affix::Platform", "DC_Major", newSViv(DYNCALL_VERSION >> 12));
    register_constant("Affix::Platform", "DC_Minor", newSViv((DYNCALL_VERSION >> 8) & 0xf));
    register_constant("Affix::Platform", "DC_Patch", newSViv((DYNCALL_VERSION >> 4) & 0xf));
    register_constant("Affix::Platform", "DC_Stage",
                      newSVpv((((DYNCALL_VERSION & 0xf) == 0xf) ? "release" : "current"), 7));
    register_constant("Affix::Platform", "DC_RawVersion", newSViv(DYNCALL_VERSION));

    // https://dyncall.org/pub/dyncall/dyncall/file/tip/dyncall/dyncall_macros.h
    const char *os =
#ifdef DC__OS_Win64
        "Win64"
#elif defined DC__OS_Win32
        "Win32"
#elif defined DC__OS_MacOSX
        "macOS"
#elif defined DC__OS_IPhone
        "iOS"
#elif defined DC__OS_Linux
        "Linux"
#elif defined DC__OS_FreeBSD
        "FreeBSD"
#elif defined DC__OS_OpenBSD
        "OpenBSD"
#elif defined DC__OS_NetBSD
        "NetBSD"
#elif defined DC__OS_DragonFlyBSD
        "DragonFly BSD"
#elif defined DC__OS_NDS
        "Nintendo DS"
#elif defined DC__OS_PSP
        "PlayStation Portable"
#elif defined DC__OS_BeOS
        "Haiku"
#elif defined DC__OS_Plan9
        "Plan9"
#elif defined DC__OS_VMS
        "VMS"
#elif defined DC__OS_Minix
        "Minix"
#else
        "Unknown"
#endif
        ;
    bool cygwin =
#ifdef DC__OS_Cygwin
        1
#else
        0
#endif
        ;
    bool mingw =
#ifdef DC__OS_MinGW
        1
#else
        0
#endif
        ;
    bool msvcrt =
#ifdef DC__RT_MSVCRT
        1
#else
        0
#endif
        ;
    const char *compiler =
#ifdef DC__C_Intel
        "Intel"
#elif defined DC__C_MSVC
        "MSVC"
#elif defined DC__C_CLANG
        "Clang"
#elif defined DC__C_GNU
        "GNU"
#elif defined DC__C_WATCOM
        "Watcom"
#elif defined DC__C_PCC
        "ppc"
#elif defined DC__C_SUNPRO
        "Oracle"
#else
        "Unknown"
#endif
        ;
    const char *architecture =

#ifdef DC__Arch_AMD64
        "x86_64"
#elif defined DC__Arch_Intel_x86
        "Intelx86"
#elif defined DC__Arch_Itanium
        "Itanium"
#elif defined DC__Arch_PPC64
        "PPC64"
#elif defined DC__Arch_PPC64
        "PPC32"
#elif defined DC__Arch_MIPS64
        "MIPS64"
#elif defined DC__Arch_MIPS
        "MIPS"
#elif defined DC__Arch_ARM
        "ARM"
#elif defined DC__Arch_ARM64
        "ARM64"
#elif defined DC__Arch_SuperH
        "SuperH" // https://en.wikipedia.org/wiki/SuperH
#elif defined DC__Arch_Sparc64
        "SPARC64"
#elif defined DC__Arch_Sparc
        "SPARC"
#else
        "Unknown"
#endif
        ;
    bool arm_thumb =
#ifdef DC__Arch_ARM_THUMB
        1
#else
        0
#endif
        ;

    bool arm_eabi =
#ifdef DC__ABI_ARM_EABI
        1
#else
        0
#endif
        ;
    bool arm_oabi =
#ifdef DC__ABI_ARM_OABI
        1
#else
        0
#endif
        ;

    bool mips_o32 =
#ifdef DC__ABI_MIPS_O32
        1
#else
        0
#endif
        ;
    bool mips_n64 =
#ifdef DC__ABI_MIPS_N64
        1
#else
        0
#endif
        ;
    bool mips_n32 =
#ifdef DC__ABI_MIPS_N32
        1
#else
        0
#endif
        ;

    bool mips_eabi =
#ifdef DC__ABI_MIPS_EABI
        1
#else
        0
#endif
        ;
    bool hardfloat =
#if defined(DC__ABI_ARM_HF) || defined(DC__ABI_HARDFLOAT)
        1
#else
        0
#endif
        ;
    bool big_endian =
#ifdef DC__Endian_BIG
        1
#else
        0
#endif
        ;
    bool aggr_by_value =
#ifdef DC__Feature_AggrByVal
        1
#else
        0
#endif
        ;
    bool syscall =
#ifdef DC__Feature_Syscall
        1
#else
        0
#endif
        ;

    bool obj_pe =
#ifdef DC__Obj_PE
        1
#else
        0
#endif
        ;

    bool obj_mach =
#ifdef DC__Obj_Mach
        1
#else
        0
#endif
        ;

    bool obj_elf =
#ifdef DC__Obj_ELF
        1
#else
        0
#endif
        ;

    bool obj_elf64 =
#ifdef DC__Obj_ELF64
        1
#else
        0
#endif
        ;

    bool obj_elf32 =
#ifdef DC__Obj_ELF32
        1
#else
        0
#endif
        ;

    const char *obj =
#ifdef DC__Obj_PE
        "PE"
#elif defined DC__Obj_Mach
        "Mach-O"
#elif defined DC__Obj_ELF64
        "64-bit ELF"
#elif defined DC__Obj_ELF32
        "32-bit ELF"
#elif defined DC__Obj_ELF
        "ELF"
#else
        "Unknown"
#endif
        ;

    // Basics
    register_constant("Affix::Platform", "OS", newSVpv(os, 0));
    register_constant("Affix::Platform", "Cygwin", boolSV(cygwin));
    register_constant("Affix::Platform", "MinGW", boolSV(mingw));
    register_constant("Affix::Platform", "Compiler", newSVpv(compiler, 0));
    register_constant("Affix::Platform", "Architecture", newSVpv(architecture, 0));
    register_constant("Affix::Platform", "MSVCRT", boolSV(msvcrt));
    register_constant("Affix::Platform", "ARM_Thumb", boolSV(arm_thumb));
    register_constant("Affix::Platform", "ARM_EABI", boolSV(arm_eabi));
    register_constant("Affix::Platform", "ARM_OABI", boolSV(arm_oabi));
    register_constant("Affix::Platform", "MIPS_O32", boolSV(mips_o32));
    register_constant("Affix::Platform", "MIPS_N64", boolSV(mips_n64));
    register_constant("Affix::Platform", "MIPS_N32", boolSV(mips_n32));
    register_constant("Affix::Platform", "MIPS_EABI", boolSV(mips_eabi));
    register_constant("Affix::Platform", "HardFloat", boolSV(hardfloat));
    register_constant("Affix::Platform", "BigEndian", boolSV(big_endian));
    register_constant("Affix::Platform", "Syscall", boolSV(syscall));
    register_constant("Affix::Platform", "AggrByValue", boolSV(aggr_by_value));

    // OBJ types
    register_constant("Affix::Platform", "OBJ_PE", boolSV(obj_pe));
    register_constant("Affix::Platform", "OBJ_Mach", boolSV(obj_mach));
    register_constant("Affix::Platform", "OBJ_ELF", boolSV(obj_elf));
    register_constant("Affix::Platform", "OBJ_ELF64", boolSV(obj_elf64));
    register_constant("Affix::Platform", "OBJ_ELF32", boolSV(obj_elf32));
    register_constant("Affix::Platform", "OBJ", newSVpv(obj, 0));

    // sizeof
    export_constant("Affix::Platform", "BOOL_SIZE", "all", BOOL_SIZE);
    export_constant("Affix::Platform", "CHAR_SIZE", "all", CHAR_SIZE);
    export_constant("Affix::Platform", "UCHAR_SIZE", "all", UCHAR_SIZE);
    export_constant("Affix::Platform", "WCHAR_SIZE", "all", WCHAR_SIZE);
    export_constant("Affix::Platform", "SHORT_SIZE", "all", SHORT_SIZE);
    export_constant("Affix::Platform", "USHORT_SIZE", "all", USHORT_SIZE);
    export_constant("Affix::Platform", "INT_SIZE", "all", INT_SIZE);
    export_constant("Affix::Platform", "UINT_SIZE", "all", UINT_SIZE);
    export_constant("Affix::Platform", "LONG_SIZE", "all", LONG_SIZE);
    export_constant("Affix::Platform", "ULONG_SIZE", "all", ULONG_SIZE);
    export_constant("Affix::Platform", "LONGLONG_SIZE", "all", LONGLONG_SIZE);
    export_constant("Affix::Platform", "ULONGLONG_SIZE", "all", ULONGLONG_SIZE);
    export_constant("Affix::Platform", "FLOAT_SIZE", "all", FLOAT_SIZE);
    export_constant("Affix::Platform", "DOUBLE_SIZE", "all", DOUBLE_SIZE);
    export_constant("Affix::Platform", "SIZE_T_SIZE", "all", SIZE_T_SIZE);
    export_constant("Affix::Platform", "SSIZE_T_SIZE", "all", SSIZE_T_SIZE);
    export_constant("Affix::Platform", "INTPTR_T_SIZE", "all", INTPTR_T_SIZE);

    // to calculate offsetof and padding inside structs
    export_constant("Affix::Platform", "BYTE_ALIGN", "all", AFFIX_ALIGNBYTES); // platform
    export_constant("Affix::Platform", "BOOL_ALIGN", "all", BOOL_ALIGN);
    export_constant("Affix::Platform", "CHAR_ALIGN", "all", CHAR_ALIGN);
    export_constant("Affix::Platform", "UCHAR_ALIGN", "all", UCHAR_ALIGN);
    export_constant("Affix::Platform", "WCHAR_ALIGN", "all", WCHAR_ALIGN);
    export_constant("Affix::Platform", "SHORT_ALIGN", "all", SHORT_ALIGN);
    export_constant("Affix::Platform", "USHORT_ALIGN", "all", USHORT_ALIGN);
    export_constant("Affix::Platform", "INT_ALIGN", "all", INT_ALIGN);
    export_constant("Affix::Platform", "UINT_ALIGN", "all", UINT_ALIGN);
    export_constant("Affix::Platform", "LONG_ALIGN", "all", LONG_ALIGN);
    export_constant("Affix::Platform", "ULONG_ALIGN", "all", ULONG_ALIGN);
    export_constant("Affix::Platform", "LONGLONG_ALIGN", "all", LONGLONG_ALIGN);
    export_constant("Affix::Platform", "ULONGLONG_ALIGN", "all", ULONGLONG_ALIGN);
    export_constant("Affix::Platform", "FLOAT_ALIGN", "all", FLOAT_ALIGN);
    export_constant("Affix::Platform", "DOUBLE_ALIGN", "all", DOUBLE_ALIGN);
    export_constant("Affix::Platform", "SIZE_T_ALIGN", "all", SIZE_T_ALIGN);
    export_constant("Affix::Platform", "SSIZE_T_ALIGN", "all", SSIZE_T_ALIGN);
    export_constant("Affix::Platform", "INTPTR_T_ALIGN", "all", INTPTR_T_ALIGN);
}
