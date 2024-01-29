package Affix::Platform::Windows 0.5 {
    use v5.38;
    use parent 'Exporter';
    our @EXPORT_OK   = qw[find_library];
    our %EXPORT_TAGS = ( all => \@EXPORT_OK );

    sub _get_build_version {

        # Get the compiler version from sys.version, similar to Python's distutils
        my $prefix = "MSC v.";
        if ( index( $^V, $prefix ) != -1 ) {
            my ( $version_str, $rest ) = split( " ", substr( $^V, index( $^V, $prefix ) + length($prefix) ) );
            my $major_version = int($version_str) - 6;
            if ( $major_version >= 13 ) {
                $major_version++;
            }
            my $minor_version = int( substr( $version_str, 2, 1 ) ) / 10.0;
            if ( $major_version == 6 ) {
                $minor_version = 0;    # Minor version doesn't affect paths in MSVC 6
            }
            return $major_version + $minor_version;
        }
        else {
            return 6;                  # Assume MSVC 6 for older Python versions
        }
    }

    sub find_msvcrt {
        my $version = _get_build_version();
        if ( !$version ) {
            return undef;              # Handle unknown compiler versions safely
        }
        my $clibname;
        if ( $version <= 6 ) {
            $clibname = 'msvcrt';
        }
        elsif ( $version <= 13 ) {
            $clibname = sprintf( 'msvcr%d', $version * 10 );
        }
        else {
            return undef;              # CRT not directly loadable (see issue23606)
        }

        # Check for debug mode
        #~ if ( $Module::Loaded::{"_d.pm"} ) {    # Perl equivalent of Python's '_d.pyd' check
        #~ $clibname .= 'd';
        #~ }
        return $clibname . '.dll';
    }

    sub find_library ($name) {
        if ( $name eq 'c' || $name eq 'm' ) {

            #~ return find_msvcrt();
        }
        my $path_sep    = $^O eq 'MSWin32' ? ';' : ':';     # Handle path separator for Windows/Unix
        my @directories = split( $path_sep, $ENV{PATH} );
        foreach my $directory (@directories) {
            my $fname = File::Spec->catfile( $directory, $name );
            if ( -f $fname ) {
                return $fname;
            }
            elsif ( $fname !~ /\.dll$/i ) {    # Check for ".dll" extension (case-insensitive)
                $fname .= '.dll';
                if ( -f $fname ) {
                    return $fname;
                }
            }
        }
        return undef;
    }
};
1;
