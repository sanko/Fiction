package Affix 0.50 {    # 'FFI' is my middle name!

    # ABSTRACT: A Foreign Function Interface eXtension
    use strict;
    use warnings;
    use experimental 'signatures';
    use Carp qw[];
    use vars qw[@EXPORT_OK @EXPORT %EXPORT_TAGS];

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
            SV]
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
    package Fiction::Type {
        use overload '""' => 'flag';
        sub new   ($class)       { bless \{}, $class }
        sub check ($value)       {...}
        sub cast  ( $vaue, $to ) {...}
        sub sizeof() {...}
        sub flag     {...}
    }

    package Fiction::Type::Void {
        our @ISA = qw[Fiction::Type];
        sub flag { chr Affix::VOID_FLAG() }
    }

    package Fiction::Type::Bool {
        our @ISA = qw[Fiction::Type];
        sub flag {'b'}
    }

    package Fiction::Type::Char {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::UChar {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::SChar {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::WChar {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::Short {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::UShort {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::Int {
        our @ISA = qw[Fiction::Type];
        sub flag {'v'}
    }

    package Fiction::Type::UInt {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::Long {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::ULong {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::LongLong {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::ULongLong {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::Float {
        our @ISA = qw[Fiction::Type];
        sub flag {'f'}
    }

    package Fiction::Type::Double {
        our @ISA = qw[Fiction::Type];
        sub flag { chr Affix::DOUBLE_FLAG() }
    }

    package Fiction::Type::Size_t {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::SSize_t {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::String {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::WString {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }

    package Fiction::Type::Struct {
        our @ISA = qw[Fiction::Type];
        sub new ( $class, $fields ) { bless \{ fields => $fields }, $class }

        #~ sub flag{'v'}
    }

    package Fiction::Type::Array {
        our @ISA = qw[Fiction::Type];

        sub new ( $class, $type, $size //= () ) {
            bless \{ type => $type, defined $size ? ( size => $size ) : () }, $class;
        }

        #~ sub flag{'v'}
    }

    package Fiction::Type::Pointer {
        our @ISA = qw[Fiction::Type];
        sub new ( $class, $type ) { bless \{ type => $type }, $class }

        #~ sub flag{'v'}
    }

    package Fiction::Type::Callback {
        our @ISA = qw[Fiction::Type];
        sub new ( $class, $argtypes, $restype ) { bless \{ argtypes => $argtypes, restype => $restype }, $class }

        #~ sub flag{'v'}
    }

    package Fiction::Type::SV {
        our @ISA = qw[Fiction::Type];

        #~ sub flag{'v'}
    }
    {
        no experimental 'signatures';

        # Functions with signatures must follow classes until https://github.com/Perl/perl5/pull/21159
        # Type system
        sub Void()      { Fiction::Type::Void->new() }
        sub Bool()      { Fiction::Type::Bool->new() }
        sub Char()      { Fiction::Type::Char->new() }
        sub UChar()     { Fiction::Type::UChar->new() }
        sub SChar()     { Fiction::Type::SChar->new() }
        sub WChar()     { Fiction::Type::WChar->new() }
        sub Short()     { Fiction::Type::Short->new() }
        sub UShort()    { Fiction::Type::UShort->new() }
        sub Int()       { Fiction::Type::Int->new() }
        sub UInt()      { Fiction::Type::UInt->new() }
        sub Long()      { Fiction::Type::Long->new() }
        sub ULong()     { Fiction::Type::ULong->new() }
        sub LongLong()  { Fiction::Type::LongLong->new() }
        sub ULongLong() { Fiction::Type::ULongLong->new() }
        sub Float()     { Fiction::Type::Float->new() }
        sub Double(;$)  { Fiction::Type::Double->new() }
        sub Size_t()    { Fiction::Type::Size_t->new() }
        sub SSize_t()   { Fiction::Type::SSize_t->new() }
        sub String()    { Fiction::Type::String->new() }
        sub WString()   { Fiction::Type::WString->new() }
        sub SV()        { Fiction::Type::SV->new() }

        # XXX: perl isn't setting prototypes correctly when signatures are enabled?
        # affix(Pointer[Int], Int, Int ) becomes affix( Pointer([Int], Int, Int) ) which is wrong
        sub Struct ($) {
            Carp::croak 'Odd number of elements in struct definition' if scalar( @{ +shift } ) % 2;
            Fiction::Type::Struct->new( \@$_[0] );
        }

        sub Array ($) {
            my ( $type, $size ) = @$_[0];
            Fiction::Type::Array->new( $type, defined $size ? ( size => $size ) : () );
        }

        sub Callback($) {
            my ( $args, $returns ) = @$_[0];
            Fiction::Type::Callback->new( $args // [], $returns // Void );
        }

        sub Pointer ($) {
            my ($type) = @$_[0];
            Fiction::Type::Pointer->new( $type // Void );
        }
    }

    # Core
    sub affix ( $lib, $symbol, $args //= [], $returns //= Void ) {
        my $affix = Affix::Wrap->new( lib => $lib, symbol => $symbol, argtypes => $args, restype => $returns );
        my ($pkg) = caller(0);
        {
            no strict 'refs';
            *{ $pkg . '::' . $symbol } = sub { $affix->call(@_) };
        }
        $affix;
    }

    sub wrap ( $lib, $symbol, $args //= [], $returns //= Void ) {
        Affix::Wrap->new( lib => $lib, symbol => $symbol, args => $args, returns => $returns );
    }
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
