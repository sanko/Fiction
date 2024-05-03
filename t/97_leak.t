use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
my $file;
BEGIN { $file = Path::Tiny::path($0)->absolute; chdir '../' if !-d 't'; }
use t::lib::helper;
use Capture::Tiny ':all';
use Path::Tiny qw[path tempfile];
use Getopt::Long;
$|++;
my ( $test, $generate_suppressions );
GetOptions( 'test=s' => \$test, 'generate' => \$generate_suppressions );
diag $test if defined $test;
my $supp;    # defined later

sub leaktest($&) {
    my ( $name, $code ) = @_;
    diag "defined test: $test" if defined $test;
    if ( !defined $test ) {
        diag 'No defined test';
        my $cmd
            = 'valgrind -q --suppressions=' .
            $supp->realpath .
            ' --leak-check=full ' .
            ' --show-leak-kinds=all --show-reachable=yes --demangle=yes' .
            ' --error-limit=no ' .
            '  --xml=yes --xml-fd=1  ' .
            $^X . ' ' .
            $file .
            ' --test ' .
            $name;
        diag $cmd;
        my ( $out, $err ) = capture {
            system $cmd
        };
        diag $out;
        diag $err;
        use Data::Dump;
        ddx parse_xml($out);
        pass 'wow ' . $name;
        return;
    }
    diag sprintf '---> %s vs %s', $name, $test;
    return unless $name eq $test;

    #~ subtest $test => sub {
    #~ Affix::set_destruct_level(3);
    my $exit = $code->();
    ok $exit;
    exit $exit;

    #~ };
}

sub parse_suppression {
    my $dups  = 0;
    my $known = {};
    require Digest::MD5;
    warn "PARSE SUPPRESSION!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
    my @in = split /\R/, shift;
    my $l  = 0;
    while ( $_ = shift @in ) {
        $l++;
        next unless (/^\{/);
        my $block = $_ . "\n";
        while ( $_ = shift @in ) {
            $l++;
            $block .= $_ . "\n";
            last if /^\}/;
        }
        $block // last;
        if ( $block !~ /\}\n/ ) {
            diag "Unterminated suppression at line $l";
            last;
        }
        my $key = $block;
        $key =~ s/(\A\{[^\n]*\n)\s*[^\n]*\n/$1/;
        my $sum = Digest::MD5::md5_hex($key);
        $dups++ if exists $known->{$sum};
        $known->{$sum} = $block;
    }
    return ( $known, $dups );
}

sub parse_xml {
    my ($xml) = @_;
    my $hash  = {};
    my $re    = qr{<([^>]+)>\s*(.*?)\s*</\1>}sm;
    while ( $xml =~ m/$re/g ) {
        my ( $tag, $content ) = ( $1, $2 );
        $content = parse_xml($content) if $content =~ /$re/;
        $hash->{$tag}
            = defined $content ? (
            defined $hash->{$tag} ?
                ref $hash->{$tag} eq 'HASH' ? [ $hash->{$tag}, $content ] :
                    ref $hash->{$tag} eq 'ARRAY' ? [ @{ $hash->{$tag} }, $content ] :
                    [$content] :
                $content ) :
            undef;
    }
    $hash;
}
#
if ( defined $test ) {
    #~ Affix::set_destruct_level(3);

    #~ die 'I should be running a test named ' . $test;
}
elsif ( defined $generate_suppressions ) {
    pass 'exiting...';
    done_testing;
    Affix::set_destruct_level(3);
    exit;
}
else {
    subtest 'generate supressions' => sub {
        my ( $out, $err ) = capture {
            system qq[valgrind --leak-check=full --show-reachable=yes --error-limit=no --gen-suppressions=all --log-fd=1 $^X $file --generate];
        };
        is $err, DF(), 'no errors';
        my ( $known, $dups ) = parse_suppression($out);
        diag scalar( keys %$known ) . ' suppressions';
        diag 'filtered out ' . $dups . ' duplicates';
        $supp = tempfile( { realpath => 1 }, 'valgrind_suppression_XXXXXXXXXX' );
        diag 'spewing to ' . $supp;
        diag $supp->spew( join "\n\n", values %$known );

        #~ ddx $known;
        #~ diag $out;
        leaktest here => sub { warn 'here we go!' };
    };
}
done_testing;
exit;
if ( !defined $test ) {
    diag 'generating suppressions';
    my ( $out, $err ) = capture {
        system qq[valgrind --leak-check=full --show-reachable=yes --error-limit=no --gen-suppressions=all --log-fd=1 $^X $file --generate];
    };
    my ( $known, $dups ) = parse_suppression($out);
    diag "Read " . keys(%$known) . " suppressions";

    #~ ddx $known;
    #~ note $known->{$_} for %$known;
    diag qq[Squashed $dups duplicate suppressions];
    path($0)->parent->child( 't', 'src', 'valgrind.supp' )->spew( join "\n\n", values %$known );
}
leaktest here => sub {
    use Data::Dump;
    warn 'in function';
    @Affix::Type::IINNTT::ISA = qw[Affix::Typex];
    my $ttt = Affix::Type::IINNTT->new(
        'Int',                             # stringify
        Affix::INT_FLAG(),                 # flag
        Affix::Platform::SIZEOF_INT(),     # sizeof
        Affix::Platform::ALIGNOF_INT(),    # alignment
        0                                  # offset
    );
    ddx $ttt;
    ok $ttt;
    $ttt = undef;
    done_testing;
    exit;
};
done_testing;
