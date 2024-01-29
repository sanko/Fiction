package Affix::Platform::Solaris 0.5 {
    use v5.38;
    use parent 'Affix::Platform::Unix';
    use parent 'Exporter';
    our @EXPORT_OK   = qw[find_library];
    our %EXPORT_TAGS = ( all => \@EXPORT_OK );
};
1;
