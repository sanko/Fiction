package Affix 0.50 {    # 'FFI' is my middle name!
    use v5.38;
    use feature 'class';
    no warnings 'experimental::class';
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
    my $okay = 0;    # True on load
    use Exporter 'import';
    @EXPORT_OK = qw[
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
        affix wrap pin unpin
        malloc calloc realloc free memchr memcmp memset memcpy sizeof offsetof
        raw hexdump
        find_library
        load_library
        free_library
        find_symbol
    ];
    %EXPORT_TAGS = ( all => \@EXPORT_OK );
    #
    class Affix::Type {
        method check ($value)          {...}
        method cast  ( $from, $value ) {...}
        method sizeof() {...}
        method flag()   { warn ref $self; ... }
    }

    class Affix::Type::Void : isa(Affix::Type) {
        method flag () {'v'}
    }

    class Affix::Type::Bool : isa(Affix::Type) { }

    class Affix::Type::Char : isa(Affix::Type) { }

    class Affix::Type::UChar : isa(Affix::Type) { }

    class Affix::Type::SChar : isa(Affix::Type) { }

    class Affix::Type::WChar : isa(Affix::Type) { }

    class Affix::Type::Short : isa(Affix::Type) { }

    class Affix::Type::UShort : isa(Affix::Type) { }

    class Affix::Type::Int : isa(Affix::Type) { }

    class Affix::Type::UInt : isa(Affix::Type) { }

    class Affix::Type::Long : isa(Affix::Type) { }

    class Affix::Type::ULong : isa(Affix::Type) { }

    class Affix::Type::LongLong : isa(Affix::Type) { }

    class Affix::Type::ULongLong : isa(Affix::Type) { }

    class Affix::Type::Float : isa(Affix::Type) { }

    class Affix::Type::Double : isa(Affix::Type) {
        method flag () {'d'}
    }

    class Affix::Type::Size_t : isa(Affix::Type) { }

    class Affix::Type::SSize_t : isa(Affix::Type) { }

    class Affix::Type::String : isa(Affix::Type) { }

    class Affix::Type::WString : isa(Affix::Type) { }

    class Affix::Type::Struct : isa(Affix::Type) {
        field $fields : param;
        method flag () {'S'}
    }

    class Affix::Type::Array : isa(Affix::Type) {
        field $type : param;
        field $size : param //= ();
    }

    class Affix::Type::Pointer : isa(Affix::Type) {
        field $type : param;
    }

    class Affix::Type::Callback : isa(Affix::Type) {
        field $argtypes : param;
        field $restype : param;
    }

    class Affix::Type::SV : isa(Affix::Type) { }
    #
    class Affix::Wrap 1 {
        field $lib : param;
        field $symbol : param;
        field $argtypes : param //= ();
        field $restype : param  //= Affix::Void();
        field $entry;
        field $signature;
        #
        ADJUST {
            #~ Carp::croak 'args must be Affix::Type objects'      if grep { !$_->isa('Affix::Type') } @$argtypes;
            Carp::croak 'returns must be an Affix::Type object' if !$restype->isa('Affix::Type');
            my $libref = Affix::load_library( $lib ? Affix::find_library($lib) : () );
            $entry     = Affix::find_symbol( $libref, $symbol );
            $signature = join '', map { $_->flag } @$argtypes;

            #~ $signature //='';
        }

        method DESTROY ( $global = 0 ) {
            warn 'destroy ', ref $self;
        }
        #
        method call (@args) { warn 'call' }
    }

    # ABI system
    class Affix::ABI::D {
        method mangle ( $name, $args, $ret ) {...}
    }

    class Affix::ABI::Fortran {
        method mangle ( $name, $args, $ret ) {...}
    }

    class Affix::ABI::Itanium {
        method mangle ( $name, $args, $ret ) {...}
    }

    class Affix::ABI::Microsoft {
        method mangle ( $name, $args, $ret ) {...}
    }

    class Affix::ABI::Rust : isa(Affix::ABI::Itanium) {
        method mangle ( $name, $args, $ret ) {...}
    }

    class Affix::ABI::Swift {
        method mangle ( $name, $args, $ret ) {...}
    }

    # Functions with signatures must follow classes until https://github.com/Perl/perl5/pull/21159
    # Type system
    sub Void()      { Affix::Type::Void->new() }
    sub Bool()      { Affix::Type::Bool->new() }
    sub Char()      { Affix::Type::Char->new() }
    sub UChar()     { Affix::Type::UChar->new() }
    sub SChar()     { Affix::Type::SChar->new() }
    sub WChar()     { Affix::Type::WChar->new() }
    sub Short()     { Affix::Type::Short->new() }
    sub UShort()    { Affix::Type::UShort->new() }
    sub Int()       { Affix::Type::Int->new() }
    sub UInt()      { Affix::Type::UInt->new() }
    sub Long()      { Affix::Type::Long->new() }
    sub ULong()     { Affix::Type::ULong->new() }
    sub LongLong()  { Affix::Type::LongLong->new() }
    sub ULongLong() { Affix::Type::ULongLong->new() }
    sub Float()     { Affix::Type::Float->new() }
    sub Double()    { Affix::Type::Double->new() }
    sub Size_t()    { Affix::Type::Size_t->new() }
    sub SSize_t()   { Affix::Type::SSize_t->new() }
    sub String()    { Affix::Type::String->new() }
    sub WString()   { Affix::Type::WString->new() }
    sub SV()        { Affix::Type::SV->new() }
    {
        no experimental 'signatures';

        # XXX: perl isn't setting prototypes correctly when signatures are enabled?
        # affix(Pointer[Int], Int, Int ) becomes affix( Pointer([Int], Int, Int) ) which is wrong
        sub Struct ($) {
            Carp::croak 'Odd number of elements in struct definition' if scalar( @{ +shift } ) % 2;
            Affix::Type::Struct->new( fields => \@$_[0] );
        }

        sub Array ($) {
            my ( $type, $size ) = @$_[0];
            Affix::Type::Array->new( type => $type, defined $size ? ( size => $size ) : () );
        }

        sub Callback($) {
            my ( $args, $returns ) = @$_[0];
            Affix::Type::Callback->new( argtypes => $args // [], restype => $returns // Void );
        }

        sub Pointer ($) {
            my ($type) = @$_[0];
            Affix::Type::Pointer->new( type => $type // Void );
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

    # Let's go
    #~ sub dl_load_flags ($modulename) {0}
    $okay =    #DynaLoader::bootstrap(__PACKAGE__);
        XSLoader::load( __PACKAGE__, $Affix::VERSION );
}
1;
