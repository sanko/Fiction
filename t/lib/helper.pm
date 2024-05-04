package t::lib::helper {
    use Test2::V0 '!subtest';
    use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
    use Test2::Plugin::UTF8;
    use Path::Tiny qw[path tempdir tempfile];
    use Exporter 'import';
    our @EXPORT = qw[compile_test_lib compile_cpp_test_lib is_approx leaktest];
    use Config;
    use Affix qw[];
    #
    my $OS  = $^O;
    my $Inc = path(__FILE__)->parent->parent->child('src')->absolute;

    #~ Affix::Platform::OS();
    my @cleanup;
    #
    #~ note $Config{cc};
    #~ note $Config{cccdlflags};
    #~ note $Config{ccdlflags};
    #~ note $Config{ccflags};
    #~ note $Config{ccname};
    #~ note $Config{ccsymbols};
    sub compile_test_lib ($;$$) {
        my ( $name, $aggs, $keep ) = @_;
        $aggs //= '';
        $keep //= 0;
        my ($opt) = grep { -f $_ } "t/src/$name.cxx", "t/src/$name.c";
        if ($opt) {
            $opt = path($opt)->absolute;
        }
        else {
            $opt = tempfile( UNLINK => !$keep, SUFFIX => $name =~ m[^\s*//\s*ext:\s*\.c$]ms ? '.c' : '.cxx' )->absolute;
            push @cleanup, $opt unless $keep;
            my ( $package, $filename, $line ) = caller;
            $line++;
            $opt->spew_utf8( qq[#line $line "$filename"\n] . $name );
        }
        if ( !$opt ) {
            diag 'Failed to locate test source';
            return ();
        }
        my $c_file = $opt->canonpath;
        my $o_file = tempfile( UNLINK => !$keep, SUFFIX => $Config{_o} )->absolute;
        my $l_file = tempfile( UNLINK => !$keep, SUFFIX => $opt->basename(qr/\.cx*/) . '.' . $Config{so} )->absolute;
        push @cleanup, $o_file, $l_file unless $keep;
        note sprintf 'Building %s into %s', $opt, $l_file;
        my $compiler = $Config{cc};
        if ( $opt =~ /\.cxx$/ ) {
            if ( Affix::Platform::Compiler() eq 'Clang' ) {
                $compiler = 'c++';
            }
            elsif ( Affix::Platform::Compiler() eq 'GNU' ) {
                $compiler = 'g++';
            }
        }
        my @cmds = (
            "$compiler -Wall -Wformat=0 --shared -fPIC -I$Inc -DBUILD_LIB -o $l_file $aggs $c_file",

            #~ (
            #~ $OS eq 'MSWin32' ? "cl /LD /EHsc /Fe$l_file $c_file" :
            #~ "clang -stdlib=libc --shared -fPIC -o $l_file $c_file"
            #~ )
        );
        my ( @fails, $succeeded );
        my $ok;
        for my $cmd (@cmds) {
            diag $cmd;
            system $cmd;
            if ( $? == 0 ) {
                $ok++;
                last;
            }
            elsif ( $? == -1 ) {
                diag 'failed to execute: ' . $!;
            }
            elsif ( $? & 127 ) {
                diag sprintf "child died with signal %d, %s coredump\n", ( $? & 127 ), ( $? & 128 ) ? 'with' : 'without';
            }
            else {
                note 'child exited with value ' . ( $? >> 8 );
            }
        }
        if ( !-f $l_file ) {
            diag 'Failed to build test lib';
            return;
        }
        $l_file;
    }
    {
        my $supp;    # defined later
        my ( $test, $generate_suppressions );
        my $valgrind = 0;
        my $file;

        sub init_valgrind {
            return if $valgrind;
            require Path::Tiny;
            $file     = Path::Tiny::path($0)->absolute;
            $valgrind = 1;
            return plan skip_all 'Capture::Tiny is not installed' unless eval 'require Capture::Tiny';
            return plan skip_all 'Path::Tiny is not installed'    unless eval 'require Path::Tiny';
            require Getopt::Long;
            Getopt::Long::GetOptions( 'test=s' => \$test, 'generate' => \$generate_suppressions );

            if ( defined $test ) {

                #~ Affix::set_destruct_level(3);
                #~ die 'I should be running a test named ' . $test;
            }
            elsif ( defined $generate_suppressions ) {
                pass 'exiting...';
                done_testing;
                exit;
            }
            else {
                my ( $stdout, $stderr, $exit_code ) = Capture::Tiny::capture(
                    sub {
                        system('valgrind --version');
                    }
                );
                plan skip_all 'Valgrind is not installed' if $exit_code;
                diag 'Valgrind v', ( $stdout =~ m[valgrind-(.+)$] ), ' found';
                subtest 'generate supressions' => sub {
                    my ( $out, $err ) = Capture::Tiny::capture(
                        sub {
                            system
                                qq[valgrind --leak-check=full --show-reachable=yes --error-limit=no --gen-suppressions=all --log-fd=1 $^X $file --generate];
                        }
                    );
                    is $err, DF(), 'no errors';
                    my ( $known, $dups ) = parse_suppression($out);
                    diag scalar( keys %$known ) . ' suppressions';
                    diag $dups . ' duplicates have been filtered out';
                    $supp = Path::Tiny::tempfile( { realpath => 1 }, 'valgrind_suppression_XXXXXXXXXX' );
                    diag 'spewing to ' . $supp;
                    diag $supp->spew( join "\n\n", values %$known );
                };
            }
        }

        sub leaktest($&) {
            init_valgrind();
            my ( $name, $code ) = @_;
            if ( !defined $test ) {
                my ( $out, $err, $exit );
                subtest $name => sub {
                    my @cmd = (
                        'valgrind',          '-q',                    '--suppressions=' . $supp->realpath,
                        '--leak-check=full', '--show-leak-kinds=all', '--show-reachable=yes', '--demangle=yes', '--error-limit=no', '--xml=yes',
                        '--xml-fd=1',        $^X,                     $file, '--test=' . $name
                    );
                    diag join ' ', @cmd;
                    ( $out, $err, $exit ) = Capture::Tiny::capture( sub { system @cmd } );
                    my $xml = parse_xml($out);

                    #~ ddx $xml->{valgrindoutput}{error};
                    is $xml->{valgrindoutput}{error}, U(), 'no leaks';
                };
                return !$exit;
            }
            return unless $name eq $test;
            Affix::set_destruct_level(3);
            my $exit = $code->();
            ok $exit;
            done_testing;
            exit !$exit;
        }

        sub parse_suppression {
            my $dups  = 0;
            my $known = {};
            require Digest::MD5;
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
    }

    END {
        for my $file ( grep {-f} @cleanup ) {
            note 'Removing ' . $file;
            unlink $file;
        }
    }
};
1;
