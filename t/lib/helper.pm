package t::lib::helper {
    use strict;
    use warnings;
    use Test2::V0;
    use Test2::Plugin::UTF8;
    use Path::Tiny qw[path tempdir tempfile];
    use Exporter 'import';
    our @EXPORT = qw[compile_test_lib compile_cpp_test_lib is_approx];
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
        skip 'Failed to build test lib' if !$opt;
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
            if ( $? == -1 ) {
                note 'failed to execute: ' . $!;
            }
            elsif ( $? & 127 ) {
                note sprintf "child died with signal %d, %s coredump\n", ( $? & 127 ), ( $? & 128 ) ? 'with' : 'without';
            }
            else {
                note 'child exited with value ' . ( $? >> 8 );
                $ok++;
                last;
            }
        }
        skip 'Failed to build test lib' if !-f $l_file;
        $l_file;
    }

    END {
        for my $file ( grep {-f} @cleanup ) {
            note 'Removing ' . $file;
            unlink $file;
        }
    }
};
1;
