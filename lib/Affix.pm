package Affix 0.50 {    # 'FFI' is my middle name!

    # ABSTRACT: A Foreign Function Interface eXtension
    use v5.26;
    use experimental 'signatures';
    use Carp qw[];
    use vars qw[@EXPORT_OK @EXPORT %EXPORT_TAGS];
    my $okay = 0;

    BEGIN {
        use XSLoader;
        $okay               = XSLoader::load();
        $DynaLoad::dl_debug = 1;
        my $platform = 'Affix::Platform::' . (
            $^O =~ /MSWin/ ? 'Windows' : $^O =~ /darwin/ ? 'MacOS' : $^O =~ /bsd/i ? 'BSD' :    # XXX: dragonfly, etc.
                'Unix'
        );
        eval qq[require $platform; $platform->import(':all')];
    }
    use lib '../lib';
    use Affix::Type       qw[:all];
    use Affix::Type::Enum qw[:all];
    use Affix::Platform;
    use parent 'Exporter';
    $EXPORT_TAGS{types} = [ @Affix::Type::EXPORT_OK, @Affix::Type::Enum::EXPORT_OK ];

    #~ $EXPORT_TAGS{ctypes} = [
    #~ qw[
    #~ ShortInt
    #~ SShort
    #~ SShortInt
    #~ UShortInt
    #~ Signed
    #~ SInt
    #~ Unsigned
    #~ LongInt
    #~ SLongInt
    #~ LongLongInt
    #~ SLongLong
    #~ SLongLongInt
    #~ ULongLongInt
    #~ Str
    #~ WStr
    #~ i8
    #~ u8
    #~ i16
    #~ u16
    #~ i32
    #~ u32
    #~ i64
    #~ u64
    #~ wchar_t
    #~ ]
    #~ ];
    $EXPORT_TAGS{cc} = [    # calling conventions
        'Reset', 'This', 'Ellipsis', 'Varargs', 'CDecl', 'STDCall', 'MSFastcall', 'GNUFastcall', 'MSThis', 'GNUThis', 'Arm', 'Thumb', 'Syscall'
    ];
    $EXPORT_TAGS{memory} = [
        qw[
            affix wrap pin unpin
            malloc calloc realloc free memchr memcmp memset memcpy sizeof offsetof
            raw hexdump]
    ];
    $EXPORT_TAGS{lib}     = [qw[find_library libm libc]];
    $EXPORT_TAGS{default} = [
        qw[
            typedef
            dlerror
            find_library    load_library    free_library
            find_symbol
        ]
    ];
    {
        my %seen;
        push @{ $EXPORT_TAGS{default} }, grep { !$seen{$_}++ } @{ $EXPORT_TAGS{$_} } for qw[base types cc lib];
    }
    {
        my %seen;
        push @{ $EXPORT_TAGS{all} }, grep { !$seen{$_}++ } @{ $EXPORT_TAGS{$_} } for keys %EXPORT_TAGS;
    }
    @EXPORT    = sort @{ $EXPORT_TAGS{default} };
    @EXPORT_OK = sort @{ $EXPORT_TAGS{all} };
    #
    {    # Type system
        package    # hide
            Affix::Type::Parameterized {
            sub parameterized          {1}
            sub subtype : prototype($) { return shift->[ Affix::SLOT_SUBTYPE() ]; }
        }
        package    # hide
            Affix::Type::CodeRef {
            sub parameterized           {1}
            sub rettype : prototype($)  { return shift->[ Affix::SLOT_SUBTYPE() ]; }
            sub argtypes : prototype($) { return shift->[ Affix::SLOT_CODEREF_ARGS() ]; }
        }
        @Affix::Type::SV::ISA

            # Enumerations (subclasses handled in Affix::Type::Enum)
            = @Affix::Type::Enum::ISA

            # Pointers
            = @Affix::Type::String::ISA = @Affix::Type::WString::ISA = @Affix::Type::StdString::ISA

            # Typedef'd aliases
            = @Affix::Type::Str::ISA

            # Calling conventions
            = @Affix::CC::ISA
            #
            = @Affix::Type::Parameterized::ISA = 'Affix::Type';

        # Pointers
        @Affix::Type::Pointer::Unmanaged::ISA = 'Affix::Pointer';
        @Affix::Type::Pointer::ISA = @Affix::Type::CodeRef::ISA = @Affix::Type::Function::ISA = 'Affix::Type::Parameterized';
        @Affix::CC::Reset::ISA     = @Affix::CC::This::ISA      = @Affix::CC::Ellipsis::ISA   = @Affix::CC::Varargs::ISA = @Affix::CC::CDecl::ISA
            = @Affix::CC::STDcall::ISA = @Affix::CC::MSFastcall::ISA = @Affix::CC::GNUFastcall::ISA = @Affix::CC::MSThis::ISA
            = @Affix::CC::GNUThis::ISA = @Affix::CC::Arm::ISA = @Affix::CC::Thumb::ISA = @Affix::CC::Syscall::ISA = 'Affix::CC';

        sub Reference : prototype(;$) {    # [ text, id, size, align, offset, subtype, sizeof, package ]

            #~ use Data::Dump;
            #~ ddx \@_;
            my $sizeof  = 0;
            my $packed  = 0;
            my $subtype = undef;
            if (@_) {
                ($subtype) = @{ +shift };

                #~ ddx $subtype;
                my $__sizeof = $subtype->sizeof;
                my $__align  = $subtype->align;
                $sizeof += $packed ? 0 : padding_needed_for( $sizeof, $__align > $__sizeof ? $__sizeof : $__align );
                $sizeof += $__sizeof;
            }
            else {
                warn scalar caller;
                Carp::croak 'Reference requires a type' unless scalar caller =~ /^Affix(::.+)?$/;
                $subtype = Void();    # Defaults to Pointer[Void]
            }
            bless( [ 'Reference [ ' . $subtype . ' ]', REFERENCE_FLAG(), $subtype->sizeof(), $subtype->align(), undef, $subtype, $sizeof, undef ],
                'Affix::Flag::Reference' );
        }

        # Calling Conventions
        sub Reset() { bless( [ 'This', RESET_FLAG(), undef, undef, undef ], 'Affix::CC::Reset' ); }
        sub This()  { bless( [ 'This', THIS_FLAG(),  undef, undef, undef ], 'Affix::CC::This' ); }

        sub Ellipsis() {
            bless( [ 'Ellipsis', ELLIPSIS_FLAG(), undef, undef, undef ], 'Affix::CC::Ellipsis' );
        }

        sub Varargs() {
            bless( [ 'Varargs', VARARGS_FLAG(), undef, undef, undef ], 'Affix::CC::Varargs' );
        }
        sub CDecl() { bless( [ 'CDecl', CDECL_FLAG(), undef, undef, undef ], 'Affix::CC::CDecl' ); }

        sub STDcall() {
            bless( [ 'STDcall', STDCALL_FLAG(), undef, undef, undef ], 'Affix::CC::STDcall' );
        }

        sub MSFastcall() {
            bless( [ 'MSFastcall', MSFASTCALL_FLAG(), undef, undef, undef ], 'Affix::CC::MSFastcall' );
        }

        sub GNUFastcall() {
            bless( [ 'GNUFastcall', GNUFASTCALL_FLAG(), undef, undef, undef ], 'Affix::CC::GNUFastcall' );
        }

        sub MSThis() {
            bless( [ 'MSThis', MSTHIS_FLAG(), undef, undef, undef ], 'Affix::CC::MSThis' );
        }

        sub GNUThis() {
            bless( [ 'GNUThis', GNUTHIS_FLAG(), undef, undef, undef ], 'Affix::CC::GNUThis' );
        }
        sub Arm()   { bless( [ 'Arm',   ARM_FLAG(),   undef, undef, undef ], 'Affix::CC::Arm' ); }
        sub Thumb() { bless( [ 'Thumb', THUMB_FLAG(), undef, undef, undef ], 'Affix::CC::Thumb' ); }

        sub Syscall() {
            bless( [ 'Syscall', SYSCALL_FLAG(), undef, undef, undef ], 'Affix::CC::Syscall' );
        }
        #
    }
    #
    sub libm() { CORE::state $m //= find_library('m'); $m }
    sub libc() { CORE::state $c //= find_library('c'); $c }

    #~ # Core
    #~ sub pin   ( $lib, $symbol, $type, $variable ) {...}
    #~ sub unpin ($variable)                         {...}
    #~ # Memory functions
    #~ sub malloc   ($size)                 {...}
    #~ sub calloc   ( $num, $size )         {...}
    #~ sub realloc  ( $ptr, $size )         {...}
    #~ sub free     ($ptr)                  {...}
    #~ sub memchr   ( $ptr, $chr, $count )  {...}
    #~ sub memcmp   ( $lhs, $rhs, $count )  {...}
    #~ sub memset   ( $dest, $src, $count ) {...}
    #~ sub memcpy   ( $dest, $src, $count ) {...}
    #~ sub sizeof   ($type)                 {...}
    #~ sub offsetof ( $type, $field )       {...}
    #~ sub raw      ( $ptr, $size )         {...}
    #~ sub hexdump  ( $ptr, $size )         {...}
};
1;
__END__
Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under
the terms found in the Artistic License 2. Other copyrights, terms, and
conditions may apply to data transmitted through this module.
