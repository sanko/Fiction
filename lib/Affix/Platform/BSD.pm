package Affix::Platform::BSD 0.5 {
    use v5.38;    use parent 'Affix::Platform::Unix';

    use parent 'Exporter';
    our @EXPORT_OK   = qw[find_library];
    our %EXPORT_TAGS = ( all => \@EXPORT_OK );
    sub find_library ($name) {
        my $regex = qr[-l$name\.[^\s]+.+\s*=>\s*(.+)$];
        map { -l $_ ? readlink($_) : $_ } map { $_ =~ $regex; defined $1 ? $1 : () } split /\n\s*/,
            `export LC_ALL 'C'; export LANG 'C'; /sbin/ldconfig -r`;

=cut
        def find_library(name):
            ename = re.escape(name)
            expr = r':-l%s\.\S+ => \S*/(lib%s\.\S+)' % (ename, ename)
            expr = os.fsencode(expr)

            try:
                proc = subprocess.Popen(('/sbin/ldconfig', '-r'),
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.DEVNULL)
            except OSError:  # E.g. command not found
                data = b''
            else:
                with proc:
                    data = proc.stdout.read()

            res = re.findall(expr, data)
            if not res:
                return _get_soname(_findLib_gcc(name))
            res.sort(key=_num_version)
            return os.fsdecode(res[-1])
=cut

    }

};
1;
