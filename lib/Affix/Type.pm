package Affix::Type 0.5 {
    use strict;
    use warnings;
    use Carp qw[];
    $Carp::Internal{ (__PACKAGE__) }++;
    use parent 'Exporter';
    our ( @EXPORT_OK, %EXPORT_TAGS );
    $EXPORT_TAGS{all} = [
        @EXPORT_OK = qw[
            Void Bool Char UChar SChar WChar Short UShort Int UInt Long ULong LongLong ULongLong Float Double
            Size_t
            String WString StdString
            Struct Union
            CodeRef Function
            Pointer Array
            SV
            typedef
        ]
    ];

    # Types: // [ text, id, size, align, offset, subtype, length, aggregate, typedef, cast ]
    #~ use overload
    #~ '""' => sub { shift->[ Affix::SLOT_STRINGIFY() ] },
    #~ '0+' => sub { shift->[ Affix::SLOT_NUMERIC() ] };
    #~ sub sizeof { shift->[ Affix::SLOT_SIZEOF() ] }
    #~ sub align  { shift->[ Affix::SLOT_ALIGNMENT() ] }
    #~ sub offset { shift->[ Affix::SLOT_OFFSET() ] }
    #~ sub cast {
    #~ $_[0]->[ Affix::SLOT_CAST() ]    = $_[1];
    #~ $_[0]->[ Affix::SLOT_NUMERIC() ] = -1;
    #~ $_[0];
    #~ }
    use overload '""' => sub { shift->[ Affix::SLOT_STRINGIFY() ] }, '0+' => sub { shift->[ Affix::SLOT_NUMERIC() ] };
    sub parameterized {0}
    sub sizeof        { shift->[ Affix::SLOT_SIZEOF() ] }
    sub align         { shift->[ Affix::SLOT_ALIGNMENT() ] }

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
        $type->[ Affix::SLOT_TYPEDEF() ]   = $name;
        $type->[ Affix::SLOT_STRINGIFY() ] = sprintf q[typedef %s => %s], $name =~ /::/ ? "'$name'" : $name, $type->[ Affix::SLOT_STRINGIFY() ];
        push @{ $EXPORT_TAGS{types} }, $name if $fqn eq 'Affix::' . $name;    # only great when triggered by/before import
        $type->typedef($fqn) if $type->can('typedef');
        $type;
    }

    # Types
    sub Void() {                                                              # could use state var if we didn't use the objects to store offset, etc.
        bless( [ 'Void', Affix::VOID_FLAG(), 0, 0, undef ], 'Affix::Type::Void' );
    }

    sub Bool() {
        bless( [ 'Bool', Affix::BOOL_FLAG(), Affix::Platform::SIZEOF_BOOL(), Affix::Platform::ALIGNOF_BOOL(), undef ], 'Affix::Type::Bool' );
    }

    sub Char() {
        bless( [ 'Char', Affix::CHAR_FLAG(), Affix::Platform::SIZEOF_CHAR(), Affix::Platform::ALIGNOF_CHAR(), undef ], 'Affix::Type::Char' );
    }

    sub SChar() {
        bless( [ 'SChar', Affix::SCHAR_FLAG(), Affix::Platform::SIZEOF_SCHAR(), Affix::Platform::ALIGNOF_SCHAR(), undef ], 'Affix::Type::SChar' );
    }

    sub UChar() {
        bless( [ 'UChar', Affix::UCHAR_FLAG(), Affix::Platform::SIZEOF_UCHAR(), Affix::Platform::ALIGNOF_UCHAR(), undef ], 'Affix::Type::UChar' );
    }

    sub WChar() {
        bless( [ 'WChar', Affix::WCHAR_FLAG(), Affix::Platform::SIZEOF_WCHAR(), Affix::Platform::ALIGNOF_WCHAR(), undef ], 'Affix::Type::WChar' );
    }

    sub Short() {
        bless( [ 'Short', Affix::SHORT_FLAG(), Affix::Platform::SIZEOF_SHORT(), Affix::Platform::ALIGNOF_SHORT(), undef ], 'Affix::Type::Short' );
    }

    sub UShort() {
        bless( [ 'UShort', Affix::USHORT_FLAG(), Affix::Platform::SIZEOF_USHORT(), Affix::Platform::ALIGNOF_USHORT(), undef ],
            'Affix::Type::UShort' );
    }

    sub Int () {
        bless( [ 'Int', Affix::INT_FLAG(), Affix::Platform::SIZEOF_INT(), Affix::Platform::ALIGNOF_INT(), undef ], 'Affix::Type::Int' );
    }

    sub UInt () {
        bless( [ 'UInt', Affix::UINT_FLAG(), Affix::Platform::SIZEOF_UINT(), Affix::Platform::ALIGNOF_UINT(), undef ], 'Affix::Type::UInt' );
    }

    sub Long () {
        bless( [ 'Long', Affix::LONG_FLAG(), Affix::Platform::SIZEOF_LONG(), Affix::Platform::ALIGNOF_LONG(), undef ], 'Affix::Type::Long' );
    }

    sub ULong () {
        bless( [ 'ULong', Affix::ULONG_FLAG(), Affix::Platform::SIZEOF_ULONG(), Affix::Platform::ALIGNOF_ULONG(), undef ], 'Affix::Type::ULong' );
    }

    sub LongLong () {
        bless( [ 'LongLong', Affix::LONGLONG_FLAG(), Affix::Platform::SIZEOF_LONGLONG(), Affix::Platform::ALIGNOF_LONGLONG(), undef ],
            'Affix::Type::LongLong' );
    }

    sub ULongLong () {
        bless( [ 'ULongLong', Affix::ULONGLONG_FLAG(), Affix::Platform::SIZEOF_ULONGLONG(), Affix::Platform::ALIGNOF_ULONGLONG(), undef ],
            'Affix::Type::ULongLong' );
    }

    sub Float () {
        bless( [ 'Float', Affix::FLOAT_FLAG(), Affix::Platform::SIZEOF_FLOAT(), Affix::Platform::ALIGNOF_FLOAT(), undef ], 'Affix::Type::Float' );
    }

    sub Double () {
        bless( [ 'Double', Affix::DOUBLE_FLAG(), Affix::Platform::SIZEOF_DOUBLE(), Affix::Platform::ALIGNOF_DOUBLE(), undef ],
            'Affix::Type::Double' );
    }

    sub Size_t () {
        bless( [ 'Size_t', Affix::SIZE_T_FLAG(), Affix::Platform::SIZEOF_SIZE_T(), Affix::Platform::ALIGNOF_SIZE_T(), undef ],
            'Affix::Type::Size_t' );
    }

    sub String() {
        CORE::state $type //= Pointer( [ Affix::Const( [ Char() ] ) ] );
        $type;
    }

    sub WString () {
        bless( [ 'String', Affix::WSTRING_FLAG(), Affix::Platform::SIZEOF_INTPTR_T(), Affix::Platform::ALIGNOF_INTPTR_T(), undef ],
            'Affix::Type::WString' );
    }

    sub StdString () {
        bless( [ 'StdString', Affix::STD_STRING_FLAG(), Affix::Platform::SIZEOF_INTPTR_T(), Affix::Platform::ALIGNOF_INTPTR_T(), undef ],
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
            $sizeof += $packed ? 0 : Affix::Platform::padding_needed_for( $sizeof, $__align > $__sizeof ? $__sizeof : $__align );
            $type->[4] = $sizeof;    # offset
            $sizeof += $__sizeof;
        }
        bless(
            [   sprintf( 'Struct[ %s ]', join ', ', @fields ),
                Affix::STRUCT_FLAG(), $sizeof, $sizeof + Affix::Platform::padding_needed_for( $sizeof, Affix::Platform::BYTE_ALIGN() ), \@types
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
        bless( [ sprintf( 'Union[ %s ]', join ', ', @fields ), Affix::UNION_FLAG(), $sizeof, $alignment, \@types ], 'Affix::Type::Union' );
    }

    sub CodeRef : prototype($) {
        my (@elements) = @{ +shift };
        my ( $args, $ret ) = @elements;
        $ret //= Void;
        bless(
            [   sprintf( 'CodeRef[ [ %s ] => %s ]', join( ', ', @$args ), $ret ), Affix::CODEREF_FLAG(), Affix::Platform::SIZEOF_INTPTR_T(),
                Affix::Platform::ALIGNOF_INTPTR_T(), undef,    # offset
                $ret,                                $args, join '', map { chr $_ } @$args
            ],
            'Affix::Type::CodeRef'
        );
    }

    sub Function : prototype($) {
        my (@elements) = @{ +shift };
        my ( $args, $ret ) = @elements;
        $ret //= Void;
        bless(
            [   sprintf( 'Function[ [ %s ] => %s ]', join( ', ', @$args ), $ret ),    # SLOT_STRINGIFY
                Affix::AFFIX_FLAG(),                                                  # SLOT_NUMERIC
                Affix::Platform::SIZEOF_INTPTR_T(),                                   # SLOT_SIZEOF
                Affix::Platform::ALIGNOF_INTPTR_T(),                                  # SLOT_ALIGNMENT
                undef,                                                                # SLOT_OFFSET
                $ret,                                                                 # SLOT_CODEREF_RET (result type)
                $args,                                                                # SLOT_CODEREF_ARGS
                join '', map { chr $_ } @$args                                        # SLOT_CODEREF_SIG
            ],
            'Affix::Type::Function'
        );
    }

    #~ // [ text, id, size, align, offset, subtype, length, aggregate, typedef ]
    #define SLOT_STRINGIFY 0
    #define SLOT_NUMERIC 1
    #define SLOT_SIZEOF 2
    #define SLOT_ALIGNMENT 3
    #define SLOT_OFFSET 4
    #define SLOT_SUBTYPE 5
    #define SLOT_ARRAYLEN 6
    #define SLOT_AGGREGATE 7
    #define SLOT_TYPEDEF 8
    #define SLOT_CAST 9
    #define SLOT_CODEREF_RET 5
    #define SLOT_CODEREF_ARGS 6
    #define SLOT_CODEREF_SIG 7
    #define SLOT_POINTER_SUBTYPE SLOT_SUBTYPE
    #define SLOT_POINTER_COUNT SLOT_ARRAYLEN
    #define SLOT_POINTER_ADDR 7
    sub Pointer : prototype(;$) {
        my ( $subtype, @etc ) = @_ ? @{ +shift } : Void();    # Defaults to Pointer[Void]
        Carp::croak sprintf( 'Too may arguments in Pointer[ %s, %s ]', $subtype, join ', ', @etc ) if @etc;
        bless(
            [   'Pointer[ ' . $subtype . ' ]',          # SLOT_STRINGIFY
                Affix::POINTER_FLAG(),                  # SLOT_NUMERIC
                Affix::Platform::SIZEOF_INTPTR_T(),     # SLOT_SIZEOF
                Affix::Platform::ALIGNOF_INTPTR_T(),    # SLOT_ALIGNMENT
                undef,                                  # SLOT_OFFSET
                $subtype,                               # SLOT_SUBTYPE
                1                                       # SLOT_ARRAYLEN
            ],
            'Affix::Type::Pointer'
        );
    }

    sub Array : prototype(;$) {
        my ( $subtype, $length ) = @{ +shift };    # No defaults
        bless(
            [   'Array[ ' . $subtype . ', ' . $length . ' ]',    # SLOT_STRINGIFY
                Affix::POINTER_FLAG(),                           # SLOT_NUMERIC
                Affix::Platform::SIZEOF_INTPTR_T(),              # SLOT_SIZEOF
                Affix::Platform::ALIGNOF_INTPTR_T(),             # SLOT_ALIGNMENT
                undef,                                           # SLOT_OFFSET
                $subtype,                                        # SLOT_SUBTYPE
                $length                                          # SLOT_ARRAYLEN
            ],
            'Affix::Type::Pointer'
        );
    }

    sub SV : prototype() {    # Should only be used inside of a Pointer[]
        bless( [ 'SV', Affix::SV_FLAG(), 0, 0, undef ], 'Affix::Type::SV' );
    }

    #~ typedef ShortInt     => Short;
    #~ typedef SShort       => Short;
    #~ typedef SShortInt    => Short;
    #~ typedef UShortInt    => UShort;
    #~ typedef Signed       => Int;
    #~ typedef SInt         => Int;
    #~ typedef Unsigned     => UInt;
    #~ typedef LongInt      => Long;
    #~ typedef SLongInt     => Long;
    #~ typedef LongLongInt  => LongLong;
    #~ typedef SLongLong    => LongLong;
    #~ typedef SLongLongInt => LongLong;
    #~ typedef ULongLongInt => ULongLong;
    #~ typedef Str          => String;
    #~ typedef WStr         => WString;
    #~ typedef wchar_t => WChar;
}
1;
