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
        dlerror
        find_library    load_library    free_library
        find_symbol
    ];
    %EXPORT_TAGS = ( all => \@EXPORT_OK );
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
        sub flag {'v'}
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
        sub flag {'d'}
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
            Carp::croak 'args must be Fiction::Type objects'      if grep { !$_->isa('Fiction::Type') } @$argtypes;
            Carp::croak 'returns must be an Fiction::Type object' if !$restype->isa('Fiction::Type');
            my $libref = Affix::load_library( $lib ? Affix::find_library($lib) : () );
            $entry     = Affix::find_symbol( $libref, $symbol );
            $signature = join '', map { $_->flag } @$argtypes;

            #~ $signature //='';
        }

        method DESTROY ( $global = 0 ) {
            warn 'destroy ', ref $self;
        }
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

    # Let's go
    #~ sub dl_load_flags ($modulename) {0}
    $okay =    #DynaLoader::bootstrap(__PACKAGE__);
        XSLoader::load( __PACKAGE__, $Affix::VERSION );
}
1;
