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
warn $test if defined $test;

sub leaktest($&) {
    my ( $name, $code ) = @_;
    $test // return;
    return unless $name eq $test;
    Affix::set_destruct_level(3);
    warn 'hifdsafdsafdsafdasfdsafdsafsdafsd';
    exit $code->() if $name eq 'here';
}
#
if ($generate_suppressions) {
    pass 'generating suppressions';
    warn
        `valgrind --leak-check=full --show-reachable=yes --error-limit=no --gen-suppressions=all --log-file=minimalraw.log $^X t/97_leak.t --generate`;
    require Digest::MD5;
    my %known;
    my $dups = 0;

    sub parse {
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
            $dups++ if ( exists $known{$sum} );
            $known{$sum} = $block;
        }
    }
    if ( @ARGV >= 2 && $ARGV[0] eq '-f' ) {
        if ( open( my $db, '<', $ARGV[1] ) ) {
            parse($db);
            close($db);
        }
        else {
            print STDERR ("Open failed for $ARGV[1]: $!\n");
            exit 1;
        }
        print STDERR ( "Read " . keys(%known) . " suppressions from $ARGV[1]\n" );
    }
    open my $FH, 'minimalraw.log';
    parse($FH);
    close $FH;
    unlink 'minimalraw.log';
    note $known{$_} for sort keys %known;
    diag qq[Squashed $dups duplicate suppressions];
    exit;

#~ my ( $out, $err ) = capture {
#~ system 'valgrind --tool=callgrind perl t/' . $0 . ' -child';
#~ system 'valgrind -q --xml=yes --xml-fd=1 perl t/' . $0 . ' -child';
#~ warn `callgrind_control -e -b`;
#~ system 'valgrind --tool=callgrind perl t/' . $0 . ' -child';
#~ system 'valgrind -q --xml=yes --xml-fd=1 --leak-check=yes --suppressions=t/src/valgrind.supp --show-reachable=yes --error-limit=no perl t/' .
#~ $0 . ' -child';
# Generate suppressions
#~ system 'valgrind --suppressions=t/src/valgrind.supp --leak-check=full ' .
#~ ' --show-leak-kinds=all --gen-suppressions=all --show-reachable=yes ' .
#~ ' --error-limit=no perl t/' . $0;
#~ system 'valgrind -q --leak-check=full --error-limit=no --show-leak-kinds=all --gen-suppressions=all --show-reachable=yes perl t/' . $0 . ' -child';
#~ };
#~ use XML::Tiny qw(parsefile);
#~ warn "\nCaptured STDOUT was:\n" . ( defined $out ? $out : 'undef' );
#~ warn "\nCaptured STDERR was:\n" . ( defined $err ? $err : 'undef' );
#~ my $document = parsefile( '_TINY_XML_STRING_' . $out );
#~ ddx $document;
}
if ( !defined $test ) {
    my ( $out, $err ) = capture {
        system 'valgrind -q --suppressions=t/src/valgrind.supp --leak-check=full ' .
            ' --show-leak-kinds=all --show-reachable=yes --demangle=yes' .
            ' --error-limit=no --xml=yes --xml-fd=1 ' .
            $^X . ' t/' .
            $0 .
            ' --test here';
    };
    warn $out;
    #~ warn $err;
    exit;
}
leaktest here => sub {
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

    #~ $ttt = undef;
    done_testing;
    exit;
};
__END__
# Path to the callgrind executable (replace with your actual path)
my $callgrind_path = "valgrind";

# Script to run under callgrind
my $script_path = __FILE__;

# Code block to profile (place your code here)
my $code_block = sub {
    sub do_something {
        # Your code to be profiled
        print "Doing something...\n";
        sleep(1);  # Simulate some work
    }
};

# Capture standard output and error streams
open my $STDOUT_BACKUP, '>&', STDOUT or die "Failed to redirect STDOUT: $!";
open my $STDERR_BACKUP, '>&', STDERR or die "Failed to redirect STDERR: $!";

# Open temporary files to capture callgrind output
open my $STDOUT, '>', "callgrind.out" or die "Failed to open callgrind.out: $!";
open my $STDERR, '>', "callgrind.err" or die "Failed to open callgrind.err: $!";

# Redirect standard streams
#~ select STDOUT;    *STDOUT = $STDOUT;
#~ select STDERR;    *STDERR = $STDERR;

# Build callgrind command with --tool=callgrind for callgrind tool
my $command = "$callgrind_path --tool=callgrind perl $script_path";

# Execute the script under callgrind
system($command);
warn $command;

# Restore standard streams
select STDOUT;    *STDOUT = $STDOUT_BACKUP;
select STDERR;    *STDERR = $STDERR_BACKUP;

# Close temporary files
close $STDOUT or die "Failed to close callgrind.out: $!";
close $STDERR or die "Failed to close callgrind.err: $!";

# Call the code block you want to profile
print "Running profiled code...\n";
#~ $code_block->do_something();

# Analyze callgrind output using callgrind_annotate or kcachegrind tool
print "Callgrind output saved to callgrind.out and callgrind.err\n";
print "Use callgrind_annotate or kcachegrind to analyze the results.\n";
