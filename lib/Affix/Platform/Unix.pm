package Affix::Platform::Unix 0.5 {
    use v5.38;
    use parent 'Exporter';
    our @EXPORT_OK   = qw[find_library];
    our %EXPORT_TAGS = ( all => \@EXPORT_OK );

    sub is_elf {
        my ($filename) = @_;
        my $elf_header = "\x7fELF";                        # ELF header in binary format
        open( my $fh, '<:raw', $filename ) or return 0;    # Open in binary mode
        sysread( $fh, my $header, 4 ) || return;
        close($fh);
        return $header eq $elf_header;
    }

    sub _findSoname_ldconfig ($name) {
        my $machine = {
            'x86_64-64'  => 'libc6,x86-64',
            'PPC64-64'   => 'libc6,64bit',
            'SPARC64-64' => 'libc6,64bit',
            'Itanium-64' => 'libc6,IA-64',
            'ARM64-64'   => 'libc6,AArch64'
        }->{ Affix::Platform::Architecture() . ( Affix::Platform::LONG_SIZE() == 4 ? '-32' : '-64' ) };

        # XXX assuming GLIBC's ldconfig (with option -p)
        my $regex = qr[^lib$name\.[^\s]+\s+\($machine.*?\)\s*=>\s*(.+)$];
        grep { is_elf($_) } map { -l $_ ? readlink($_) : $_ } map { $_ =~ $regex; defined $1 ? $1 : () } split /\n\s*/,
            `export LC_ALL 'C'; export LANG 'C'; /sbin/ldconfig -p`;
    }

    sub _findLib_ld ($name) {
        use Data::Dump;
        my @paths = split ':', $ENV{LD_LIBRARY_PATH};
        ddx \@paths;

        #ddx \%ENV;
        `ld -t -o /dev/null -lm`;

        #~ expr = r'[^\(\)\s]*lib%s\.[^\(\)\s]*' % re.escape(name)
        #~ cmd = ['ld', '-t']
        #~ libpath = os.environ.get('LD_LIBRARY_PATH')
        #~ if libpath:
        #~ for d in libpath.split(':'):
        #~ cmd.extend(['-L', d])
        #~ cmd.extend(['-o', os.devnull, '-l%s' % name])
        #~ print('===>',cmd)
    }

    sub find_library ($name) {
        _findSoname_ldconfig($name)

        #~ // _get_soname( _findLib_gcc($name) ) // _get_soname( _findLib_ld($name) );
    }

    sub _get_soname ($file) {    # assuming GNU binutils / ELF
        return undef unless $file && -f $file;
        my $objdump = `which objdump`;
        return undef unless $objdump;    # objdump is not available, give up
        chomp $objdump;
        my $dump = `$objdump -p -j .dynamic $file 2>/dev/null`;
        $dump =~ /\sSONAME\s+([^\s]+)/ ? $1 : ();
    }
}
1;
