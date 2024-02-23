package Affix 0.50 {    # 'FFI' is my middle name!

    # ABSTRACT: A Foreign Function Interface eXtension
    use v5.26;
    use experimental 'signatures';
    use Carp qw[];
    use vars qw[@EXPORT_OK @EXPORT %EXPORT_TAGS];
    use lib '../lib';
    use Affix::Enum qw[:all];    # Future

    BEGIN {
        $DynaLoad::dl_debug = 1;
        my $platform = 'Affix::Platform::' . (
            $^O =~ /MSWin/ ? 'Windows' : $^O =~ /darwin/ ? 'MacOS' : $^O =~ /bsd/i ? 'BSD' :    # XXX: dragonfly, etc.
                'Unix'
        );
        eval qq[require $platform; $platform->import(':all')];
    }
    use XSLoader;
    my $okay = XSLoader::load();
    use parent 'Exporter';
    $EXPORT_TAGS{types} = [
        qw[
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
            Enum IntEnum UIntEnum CharEnum
        ]
    ];
    $EXPORT_TAGS{ctypes} = [
        qw[
            ShortInt
            SShort
            SShortInt
            UShortInt
            Signed
            SInt
            Unsigned
            LongInt
            SLongInt
            LongLongInt
            SLongLong
            SLongLongInt
            ULongLongInt
            Str
            WStr
            i8
            u8
            i16
            u16
            i32
            u32
            i64
            u64
            wchar_t
        ]
    ];
    $EXPORT_TAGS{cc} = [    # calling conventions
        'Reset', 'This', 'Ellipsis', 'Varargs', 'CDecl', 'STDCall', 'MSFastcall', 'GNUFastcall', 'MSThis', 'GNUThis', 'Arm', 'Thumb', 'Syscall'
    ];
    $EXPORT_TAGS{memory} = [
        qw[
            affix wrap pin unpin
            malloc calloc realloc free memchr memcmp memset memcpy sizeof offsetof
            raw hexdump]
    ];
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
        push @{ $EXPORT_TAGS{default} }, grep { !$seen{$_}++ } @{ $EXPORT_TAGS{$_} } for qw[base types cc];
    }
    {
        my %seen;
        push @{ $EXPORT_TAGS{all} }, grep { !$seen{$_}++ } @{ $EXPORT_TAGS{$_} } for keys %EXPORT_TAGS;
    }
    @EXPORT    = sort @{ $EXPORT_TAGS{default} };
    @EXPORT_OK = sort @{ $EXPORT_TAGS{all} };
    #
    {    # Type system

        #~ #define SLOT_STRINGIFY 0
        #~ #define SLOT_NUMERIC 1
        #~ #define SLOT_SIZEOF 2
        #~ #define SLOT_ALIGNMENT 3
        #~ #define SLOT_OFFSET 4
        #~ #define SLOT_SUBTYPE 5
        #~ #define SLOT_ARRAYLEN 6
        #~ #define SLOT_AGGREGATE 7
        #~ #define SLOT_TYPEDEF 8
        #~ #define SLOT_CAST 9
        #~ #define SLOT_CODEREF_ARGS 10
        #~ #define SLOT_CODEREF_RET 11
        #~ #define SLOT_CODEREF_SIG 12
        {
            # ctypes util
            sub padding_needed_for {
                my ( $offset, $alignment ) = @_;
                return $alignment unless $offset;
                return 0          unless $alignment;
                my $misalignment = $offset % $alignment;
                return $alignment - $misalignment if $misalignment;    # round to the next multiple of $alignment
                return 0;                                              # already a multiple of $alignment
            }
            #
            sub typedef {
                my ( $name, $type ) = @_;
                if ( !$type->isa('Affix::Type') ) {
                    require Carp;
                    Carp::croak( 'Unknown type: ' . $type );
                }
                my $fqn = $name =~ /::/ ? $name : [caller]->[0] . '::' . $name;
                {
                    no strict 'refs';
                    no warnings 'redefine';
                    *{$fqn} = sub { CORE::state $s //= $type };
                    @{ $fqn . '::ISA' } = ref $type;
                }
                bless $type, $fqn;
                $type->[ SLOT_TYPEDEF() ]   = $name;
                $type->[ SLOT_STRINGIFY() ] = sprintf q[typedef %s => %s], $name =~ /::/ ? "'$name'" : $name, $type->[ SLOT_STRINGIFY() ];
                push @{ $EXPORT_TAGS{types} }, $name if $fqn eq 'Affix::' . $name;    # only great when triggered by/before import
                $type->typedef($fqn) if $type->can('typedef');
                $type;
            }
            package                                                                   # hide
                Affix::Type {
                use overload '""' => sub { chr shift->[ Affix::SLOT_NUMERIC() ] };
                sub parameterized {0}
                sub sizeof        { shift->[ Affix::SLOT_SIZEOF() ] }
                sub align         { shift->[ Affix::SLOT_ALIGNMENT() ] }
            }
            package                                                                   # hide
                Affix::Type::Parameterized {
                sub parameterized          {1}
                sub subtype : prototype($) { return shift->[ Affix::SLOT_SUBTYPE() ]; }
            }
            package                                                                   # hide
                Affix::Type::Callback {
                sub parameterized           {1}
                sub rettype : prototype($)  { return shift->[ Affix::SLOT_SUBTYPE() ]; }
                sub argtypes : prototype($) { return shift->[ Affix::SLOT_CODEREF_ARGS() ]; }
            }
            @Affix::Type::Void::ISA = @Affix::Type::SV::ISA

                # Numerics
                = @Affix::Type::Bool::ISA   = @Affix::Type::Char::ISA = @Affix::Type::SChar::ISA = @Affix::Type::UChar::ISA = @Affix::Type::WChar::ISA
                = @Affix::Type::Short::ISA  = @Affix::Type::UShort::ISA   = @Affix::Type::Int::ISA = @Affix::Type::UInt::ISA = @Affix::Type::Long::ISA
                = @Affix::Type::ULong::ISA  = @Affix::Type::LongLong::ISA = @Affix::Type::ULongLong::ISA = @Affix::Type::Float::ISA
                = @Affix::Type::Double::ISA = @Affix::Type::Size_t::ISA
                = @Affix::Type::SSize_t::ISA

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

            # Aggregates
            @Affix::Type::Struct::ISA = @Affix::Type::Array::ISA = @Affix::Type::Union::ISA

                # Qualifiers
                = @Affix::Flag::Const::ISA = @Affix::Flag::Volatile::ISA = @Affix::Flag::Restrict::ISA = @Affix::Flag::Reference::ISA
                #
                = @Affix::Type::Pointer::ISA = @Affix::Type::Callback::ISA = 'Affix::Type::Parameterized';
            @Affix::CC::Reset::ISA = @Affix::CC::This::ISA = @Affix::CC::Ellipsis::ISA = @Affix::CC::Varargs::ISA = @Affix::CC::CDecl::ISA
                = @Affix::CC::STDcall::ISA = @Affix::CC::MSFastcall::ISA = @Affix::CC::GNUFastcall::ISA = @Affix::CC::MSThis::ISA
                = @Affix::CC::GNUThis::ISA = @Affix::CC::Arm::ISA = @Affix::CC::Thumb::ISA = @Affix::CC::Syscall::ISA = 'Affix::CC';

            # Qualifier flags
            sub Const : prototype(;$) {    # [ text, id, size, align, offset, subtype, sizeof, package ]

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
                    Carp::croak 'Const requires a type' unless scalar caller =~ /^Affix(::.+)?$/;
                    $subtype = Void();    # Defaults to Pointer[Void]
                }
                bless( [ 'Const[ ' . $subtype . ' ]', CONST_FLAG(), $subtype->sizeof(), $subtype->align(), undef, $subtype, $sizeof, undef ],
                    'Affix::Flag::Const' );
            }

            sub Volatile : prototype(;$) {    # [ text, id, size, align, offset, subtype, sizeof, package ]

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
                    Carp::croak 'Volatile requires a type' unless scalar caller =~ /^Affix(::.+)?$/;
                    $subtype = Void();    # Defaults to Pointer[Void]
                }
                bless( [ 'Volatile[ ' . $subtype . ' ]', VOLATILE_FLAG(), $subtype->sizeof(), $subtype->align(), undef, $subtype, $sizeof, undef ],
                    'Affix::Flag::Volatile' );
            }

            sub Restrict : prototype(;$) {    # [ text, id, size, align, offset, subtype, sizeof, package ]

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
                    Carp::croak 'Restrict qualifier requires a type' unless scalar caller =~ /^Affix(::.+)?$/;
                    $subtype = Void();    # Defaults to Pointer[Void]
                }
                bless( [ 'Restrict[ ' . $subtype . ' ]', RESTRICT_FLAG(), $subtype->sizeof(), $subtype->align(), undef, $subtype, $sizeof, undef ],
                    'Affix::Flag::Restrict' );
            }

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
                bless( [ 'Reference[ ' . $subtype . ' ]', REFERENCE_FLAG(), $subtype->sizeof(), $subtype->align(), undef, $subtype, $sizeof, undef ],
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

            # Types
            sub Void() {    # could use state var if we didn't use the objects to store offset, etc.
                bless( [ 'Void', VOID_FLAG(), 0, 0, undef ], 'Affix::Type::Void' );
            }

            sub Bool() {
                bless( [ 'Bool', BOOL_FLAG(), Affix::Platform::SIZEOF_BOOL(), Affix::Platform::ALIGNOF_BOOL(), undef ], 'Affix::Type::Bool' );
            }

            sub Char() {
                bless( [ 'Char', CHAR_FLAG(), Affix::Platform::SIZEOF_CHAR(), Affix::Platform::ALIGNOF_CHAR(), undef ], 'Affix::Type::Char' );
            }

            sub SChar() {
                bless( [ 'SChar', SCHAR_FLAG(), Affix::Platform::SIZEOF_SCHAR(), Affix::Platform::ALIGNOF_SCHAR(), undef ], 'Affix::Type::SChar' );
            }

            sub UChar() {
                bless( [ 'UChar', UCHAR_FLAG(), Affix::Platform::SIZEOF_UCHAR(), Affix::Platform::ALIGNOF_UCHAR(), undef ], 'Affix::Type::UChar' );
            }

            sub WChar() {
                bless( [ 'WChar', WCHAR_FLAG(), Affix::Platform::SIZEOF_WCHAR(), Affix::Platform::ALIGNOF_WCHAR(), undef ], 'Affix::Type::WChar' );
            }

            sub Short() {
                bless( [ 'Short', SHORT_FLAG(), Affix::Platform::SIZEOF_SHORT(), Affix::Platform::ALIGNOF_SHORT(), undef ], 'Affix::Type::Short' );
            }

            sub UShort() {
                bless( [ 'UShort', USHORT_FLAG(), Affix::Platform::SIZEOF_USHORT(), Affix::Platform::ALIGNOF_USHORT(), undef ],
                    'Affix::Type::UShort' );
            }

            sub Int () {
                bless( [ 'Int', INT_FLAG(), Affix::Platform::SIZEOF_INT(), Affix::Platform::ALIGNOF_INT(), undef ], 'Affix::Type::Int' );
            }

            sub UInt () {
                bless( [ 'UInt', UINT_FLAG(), Affix::Platform::SIZEOF_UINT(), Affix::Platform::ALIGNOF_UINT(), undef ], 'Affix::Type::UInt' );
            }

            sub Long () {
                bless( [ 'Long', LONG_FLAG(), Affix::Platform::SIZEOF_LONG(), Affix::Platform::ALIGNOF_LONG(), undef ], 'Affix::Type::Long' );
            }

            sub ULong () {
                bless( [ 'ULong', ULONG_FLAG(), Affix::Platform::SIZEOF_ULONG(), Affix::Platform::ALIGNOF_ULONG(), undef ], 'Affix::Type::ULong' );
            }

            sub LongLong () {
                bless( [ 'LongLong', LONGLONG_FLAG(), Affix::Platform::SIZEOF_LONGLONG(), Affix::Platform::ALIGNOF_LONGLONG(), undef ],
                    'Affix::Type::LongLong' );
            }

            sub ULongLong () {
                bless( [ 'ULongLong', ULONGLONG_FLAG(), Affix::Platform::SIZEOF_ULONGLONG(), Affix::Platform::ALIGNOF_ULONGLONG(), undef ],
                    'Affix::Type::ULongLong' );
            }

            sub Float () {
                bless( [ 'Float', FLOAT_FLAG(), Affix::Platform::SIZEOF_FLOAT(), Affix::Platform::ALIGNOF_FLOAT(), undef ], 'Affix::Type::Float' );
            }

            sub Double () {
                bless( [ 'Double', DOUBLE_FLAG(), Affix::Platform::SIZEOF_DOUBLE(), Affix::Platform::ALIGNOF_DOUBLE(), undef ],
                    'Affix::Type::Double' );
            }

            sub Size_t () {
                bless( [ 'Size_t', SSIZE_T_FLAG(), Affix::Platform::SIZEOF_SIZE_T(), Affix::Platform::ALIGNOF_SIZE_T(), undef ],
                    'Affix::Type::Size_t' );
            }

            sub SSize_t () {
                bless( [ 'SSize_t', SSIZE_T_FLAG(), Affix::Platform::SIZEOF_SSIZE_T(), Affix::Platform::ALIGNOF_SSIZE_T(), undef ],
                    'Affix::Type::SSize_t' );
            }

            #~ sub String () {
            #~ bless( [ 'String', STRING_FLAG(), SIZEOF_INTPTR_T(), ALIGNOF_INTPTR_T(), undef ],
            #~ 'Affix::Type::String' );
            #~ }
            sub String() {
                CORE::state $type //= Pointer( [ Const( [ Char() ] ) ] );
                $type;
            }

            sub WString () {
                bless( [ 'String', WSTRING_FLAG(), Affix::Platform::SIZEOF_INTPTR_T(), Affix::Platform::ALIGNOF_INTPTR_T(), undef ],
                    'Affix::Type::WString' );
            }

            sub StdString () {
                bless( [ 'StdString', STD_STRING_FLAG(), Affix::Platform::SIZEOF_INTPTR_T(), Affix::Platform::ALIGNOF_INTPTR_T(), undef ],
                    'Affix::Type::StdString' );
            }

            sub Struct : prototype($) {
                my (@types) = @{ +shift };
                my @fields;
                my $sizeof = 0;
                my $packed = 0;

                #~ for my ( $field, $type )(@types) { # Perl 5.36
                for ( my $i = 0; $i < $#types; $i += 2 ) {
                    my $field = $types[$i];
                    my $type  = $types[ $i + 1 ];
                    push @fields, sprintf '%s => %s', $field, $type;
                    my $__sizeof = $type->sizeof;
                    my $__align  = $type->align;
                    $sizeof += $packed ? 0 : padding_needed_for( $sizeof, $__align > $__sizeof ? $__sizeof : $__align );
                    $type->[4] = $sizeof;    # offset
                    $sizeof += $__sizeof;
                }
                bless(
                    [   sprintf( 'Struct[ %s ]', join ', ', @fields ),
                        STRUCT_FLAG(), $sizeof, $sizeof + padding_needed_for( $sizeof, Affix::Platform::BYTE_ALIGN() ), \@types
                    ],
                    'Affix::Type::Struct'
                );
            }

            # TODO: CPPStruct
            sub Union : prototype($) {
                my (@types) = @{ +shift };
                my @fields;
                my $sizeof    = 0;
                my $alignment = 0;
                my $packed    = 0;

                #~ for my ( $field, $type )(@types) { # Perl 5.36
                for ( my $i = 0; $i < $#types; $i += 2 ) {
                    my $field = $types[$i];
                    my $type  = $types[ $i + 1 ];
                    push @fields, sprintf '%s => %s', $field, $type;
                    my $__sizeof = $type->sizeof;
                    if ( $sizeof < $__sizeof ) {
                        $sizeof    = $__sizeof;
                        $alignment = $type->align;
                    }
                }
                bless( [ sprintf( 'Union[ %s ]', join ', ', @fields ), UNION_FLAG(), $sizeof, $alignment, \@types ], 'Affix::Type::Union' );
            }

            sub Array : prototype($) {    # [ text, id, size, align, offset, subtype, length, aggregate ]
                my ( $type, $size ) = @{ +shift };
                my $sizeof = undef;
                my $packed = 0;
                if ($size) {
                    my $__sizeof = $type->sizeof;
                    my $__align  = $type->align;
                    for ( 0 ... $size ) {
                        $sizeof += $packed ? 0 : padding_needed_for( $sizeof, $__align > $__sizeof ? $__sizeof : $__align );
                        $sizeof += $__sizeof;
                    }
                }
                bless(
                    [   sprintf( 'Array[ %s%s ]', $type, defined($size) ? ', ' . $size : '' ),
                        ARRAY_FLAG(), $sizeof, undef, undef, $type, $size, undef
                    ],
                    'Affix::Type::Array'
                );
            }

            sub Callback : prototype($) {
                my (@elements) = @{ +shift };
                my ( $args, $ret ) = @elements;
                $ret //= Void;
                bless(
                    [   sprintf( 'Callback[ [ %s ] => %s ]', join( ', ', @$args ), $ret ),
                        CODEREF_FLAG(),
                        Affix::Platform::SIZEOF_INTPTR_T(),
                        Affix::Platform::ALIGNOF_INTPTR_T(),
                        undef, $ret, undef, undef, undef, undef, $args
                    ],
                    'Affix::Type::Callback'
                );
            }

            sub Pointer : prototype(;$) {    # [ text, id, size, align, offset, subtype, sizeof, package ]
                my $sizeof  = 0;
                my $packed  = 0;
                my $subtype = undef;
                if (@_) {
                    ($subtype) = @{ +shift };
                    my $__sizeof = $subtype->sizeof;
                    my $__align  = $subtype->align;
                    $sizeof += $packed ? 0 : padding_needed_for( $sizeof, $__align > $__sizeof ? $__sizeof : $__align );
                    $sizeof += $__sizeof;
                }
                else {
                    $subtype = Void();    # Defaults to Pointer[Void]
                }
                bless(
                    [   'Pointer[ ' . $subtype . ' ]',
                        POINTER_FLAG(),
                        Affix::Platform::SIZEOF_INTPTR_T(),
                        Affix::Platform::ALIGNOF_INTPTR_T(),
                        undef, $subtype, $sizeof, undef
                    ],
                    'Affix::Type::Pointer'
                );
            }

            sub SV : prototype() {    # Should only be used inside of a Pointer[]
                bless( [ 'SV', SV_FLAG(), 0, 0, undef ], 'Affix::Type::SV' );
            }
            #
            typedef ShortInt     => Short;
            typedef SShort       => Short;
            typedef SShortInt    => Short;
            typedef UShortInt    => UShort;
            typedef Signed       => Int;
            typedef SInt         => Int;
            typedef Unsigned     => UInt;
            typedef LongInt      => Long;
            typedef SLongInt     => Long;
            typedef LongLongInt  => LongLong;
            typedef SLongLong    => LongLong;
            typedef SLongLongInt => LongLong;
            typedef ULongLongInt => ULongLong;
            typedef Str          => String;
            typedef WStr         => WString;
            #
            typedef i8  => Char;
            typedef u8  => UChar;
            typedef i16 => Short;
            typedef u16 => UShort;
            typedef i32 => Int;
            typedef u32 => UInt;
            typedef i64 => LongLong;
            typedef u64 => ULongLong;
            #
            typedef wchar_t => WChar;
        }
    }

    # Core
    sub pin   ( $lib, $symbol, $type, $variable ) {...}
    sub unpin ($variable)                         {...}

    # Memory functions
    sub malloc   ($size)                 {...}
    sub calloc   ( $num, $size )         {...}
    sub realloc  ( $ptr, $size )         {...}
    sub free     ($ptr)                  {...}
    sub memchr   ( $ptr, $chr, $count )  {...}
    sub memcmp   ( $lhs, $rhs, $count )  {...}
    sub memset   ( $dest, $src, $count ) {...}
    sub memcpy   ( $dest, $src, $count ) {...}
    sub sizeof   ($type)                 {...}
    sub offsetof ( $type, $field )       {...}
    sub raw      ( $ptr, $size )         {...}
    sub hexdump  ( $ptr, $size )         {...}
}
1;
__END__
Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under
the terms found in the Artistic License 2. Other copyrights, terms, and
conditions may apply to data transmitted through this module.
