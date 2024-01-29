package Affix::Platform::MacOS 0.5 {
    use v5.38;
    use DynaLoader;
    use parent 'Affix::Platform::Unix';
    use parent 'Exporter';
    our @EXPORT_OK   = qw[find_library];
    our %EXPORT_TAGS = ( all => \@EXPORT_OK );

    sub find_library {
        my ($name) = @_;
        my @possible = ( "lib$name.dylib", "$name.dylib", "$name.framework/$name" );
        foreach my $possible_name (@possible) {
            my $path = DynaLoader::dl_findfile($possible_name);
            if ($path) {
                return $path;
            }
        }
        return undef;
    }
};
1;
