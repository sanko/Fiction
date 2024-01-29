package Affix::Platform::BSD 0.5 {
    use v5.38;
    use parent 'Affix::Platform::Unix';
    use parent 'Exporter';
    our @EXPORT_OK   = qw[find_library];
    our %EXPORT_TAGS = ( all => \@EXPORT_OK );

    sub find_library ($name) {
        my $regex = qr[-l$name\.[^\s]+.+\s*=>\s*(.+)$];
        map { -l $_ ? readlink($_) : $_ } map { $_ =~ $regex; defined $1 ? $1 : () } split /\n\s*/,
            `export LC_ALL 'C'; export LANG 'C'; /sbin/ldconfig -r`;
    }
};
1;
