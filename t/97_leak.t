use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix qw[:all];
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
use Data::Dump;

use Capture::Tiny ':all';


ddx \@ARGV;

$|++;

sub leaktest($&) {
my ($name, $code) = @_;
#~ return unless ARGV
#~ main->can('here')->();
exit $code->() if $name eq 'here'

}

unless (@ARGV){
    my ($out, $err) = capture {
        #~ system 'valgrind --tool=callgrind perl t/' . $0 . ' -child';
        system 'valgrind -q --xml=yes --xml-fd=1 perl t/' . $0 . ' -child';
        #~ warn `callgrind_control -e -b`;
    };


use XML::Tiny qw(parsefile);
     warn "\nCaptured STDOUT was:\n" . ( defined $out ? $out : 'undef' );
    warn "\nCaptured STDERR was:\n" . ( defined $err ? $err : 'undef' );
       my $document = parsefile('_TINY_XML_STRING_'.$out);
    ddx $document;

    exit;
};

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
$ttt = undef;
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
