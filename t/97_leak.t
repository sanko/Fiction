use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
use Capture::Tiny ':all';
use Getopt::Long;
$|++;
my ( $test, $generate_suppressions );
GetOptions( 'test=s' => \$test, 'generate' => \$generate_suppressions );

sub leaktest($&) {
    my ( $name, $code ) = @_;
    if ( !defined $test ) {
        my ( $out, $err ) = capture {
            system 'valgrind -q --suppressions=t/src/valgrind.supp --leak-check=full ' .
                ' --show-leak-kinds=all --show-reachable=yes --demangle=yes' .
                ' --error-limit=no ' .
                '  --xml=yes --xml-fd=1  ' .
                $^X . ' t/' .
                $0 .
                ' --test ' .
                $name;
        };
        diag $out;
        diag $err;
        use Data::Dump;
        ddx parse_xml($out);
        pass 'wow ' . $name;
        return;
    }
    return unless $name eq $test;
    Affix::set_destruct_level(3);
    exit $code->();
}
my $dups  = 0;
my $known = {};

sub parse_suppression {
    my $in = shift;
    while (<$in>) {
        next unless (/^\{/);
        my $block = $_;
        while (<$in>) {
            if (/^\}/) {
                $block .= "}\n";
                last;
            }
            $block .= $_;
        }
        last unless ( defined $block );
        if ( $block !~ /\}\n/ ) {
            print STDERR ("Unterminated suppression at line $.\n");
            last;
        }
        my $key = $block;
        $key =~ s/(\A\{[^\n]*\n)\s*[^\n]*\n/$1/;
        my $sum = Digest::MD5::md5_hex($key);
        $dups++ if ( exists $known->{$sum} );
        $known->{$sum} = $block;
    }
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
if ($generate_suppressions) {
    diag 'generating suppressions';
    warn
        `valgrind --leak-check=full --show-reachable=yes --error-limit=no --gen-suppressions=all --log-file=minimalraw.log $^X t/97_leak.t --generate`;
    require Digest::MD5;
    if ( @ARGV >= 2 && $ARGV[0] eq '-f' ) {
        if ( open( my $db, '<', $ARGV[1] ) ) {
            parse_suppression($db);
            close($db);
        }
        else {
            diag "Open failed for $ARGV[1]: $!";
            exit 1;
        }
        diag "Read " . keys(%$known) . " suppressions from $ARGV[1]";
    }
    open my $FH, 'minimalraw.log';
    parse($FH);
    close $FH;
    unlink 'minimalraw.log';
    note $known->{$_} for sort keys %$known;
    diag qq[Squashed $dups duplicate suppressions];
    exit;
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
