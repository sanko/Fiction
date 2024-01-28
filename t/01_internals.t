use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix;
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
use v5.38;
#
#~ use Devel::LeakTrace;
package MacOS {
    use Config;
    use DynaLoader;

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
}
package BSD{
use Test2::V0;

sub find_library{
            my ($name) = @_;


        my $regex = qr[-l$name\.[^\s]+.+\s*=>\s*(.+)$];


        map { -l $_ ? readlink($_) : $_ } map {diag $_; $_ =~ $regex; defined $1 ? $1 : () } split /\n\s*/,
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

}
package Windows {

    sub _get_build_version {

        # Get the compiler version from sys.version, similar to Python's distutils
        my $prefix = "MSC v.";
        if ( index( $^V, $prefix ) != -1 ) {
            my ( $version_str, $rest )
                = split( " ", substr( $^V, index( $^V, $prefix ) + length($prefix) ) );
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

    sub find_library {
        my ($name) = @_;
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

sub is_elf {
    my ($filename) = @_;
    diag $filename;
    diag -s $filename;
    my $elf_header = "\x7fELF";                        # ELF header in binary format
    open( my $fh, '<:raw', $filename ) or return 0;    # Open in binary mode
    sysread( $fh, my $header, 4 ) || return;
    close($fh);
    diag $header;
    return $header eq $elf_header;
}

sub _findSoname_ldconfig ($name) {
    my $machine = {
        'x86_64-64'  => 'libc6,x86-64',
        'PPC64-64'   => 'libc6,64bit',
        'SPARC64-64' => 'libc6,64bit',
        'Itanium-64' => 'libc6,IA-64',
        'ARM64-64'   => 'libc6,AArch64'
        }->{ Affix::Platform::Architecture() .
            ( Affix::Platform::LONG_SIZE() == 4 ? '-32' : '-64' ) };

    # libm.so.6 (libc6,x86-64, OS ABI: Linux 3.2.0) => /lib/x86_64-linux-gnu/libm.so.6
    # XXX assuming GLIBC's ldconfig (with option -p)
    my $regex = qr[^lib$name\.[^\s]+\s+\($machine.*?\)\s*=>\s*(.+)$];
    diag $regex;
    grep { is_elf($_) }
        map { -l $_ ? readlink($_) : $_ } map { $_ =~ $regex; defined $1 ? $1 : () } split /\n\s*/,
        `export LC_ALL 'C'; export LANG 'C'; /sbin/ldconfig -p`;
}

sub _findLib_ld ($name) {
    use Data::Dump;
    my @paths = split ':', $ENV{LD_LIBRARY_PATH};
    ddx \@paths;

    #ddx \%ENV;
    diag `ld -t -o /dev/null -lm`;

    #~ expr = r'[^\(\)\s]*lib%s\.[^\(\)\s]*' % re.escape(name)
    #~ cmd = ['ld', '-t']
    #~ libpath = os.environ.get('LD_LIBRARY_PATH')
    #~ if libpath:
    #~ for d in libpath.split(':'):
    #~ cmd.extend(['-L', d])
    #~ cmd.extend(['-o', os.devnull, '-l%s' % name])
    #~ print('===>',cmd)
}

#~ _findLib_ld('m');
#~ die;
my @libs
    = $^O =~ /MSWin/  ? Windows::find_library('ntdll') :
    $^O   =~ /darwin/ ? MacOS::find_library('m') :
    $^O   =~ /bsd/i   ? BSD::find_library('m'):
    _findSoname_ldconfig('m');
diag $_ for @libs;
diag $libs[0];
my $refx = Affix::load_lib( $libs[0] );
diag $$refx;
#~ diag $_ for @{ Affix::Lib::list_symbols( $refx ) };
diag Affix::Lib::find_symbol($refx, 'pow');
pass '';
done_testing;
exit;

=cut
def _findSoname_ldconfig(name):
            import struct
            if struct.calcsize('l') == 4:
                machine = os.uname().machine + '-32'
            else:
                machine = os.uname().machine + '-64'
            mach_map = {
                'x86_64-64': 'libc6,x86-64',
                'ppc64-64': 'libc6,64bit',
                'sparc64-64': 'libc6,64bit',
                's390x-64': 'libc6,64bit',
                'ia64-64': 'libc6,IA-64',
                }
            abi_type = mach_map.get(machine, 'libc6')

            # XXX assuming GLIBC's ldconfig (with option -p)
            regex = r'\s+(lib%s\.[^\s]+)\s+\(%s'
            regex = os.fsencode(regex % (re.escape(name), abi_type))
            try:
                with subprocess.Popen(['/sbin/ldconfig', '-p'],
                                      stdin=subprocess.DEVNULL,
                                      stderr=subprocess.DEVNULL,
                                      stdout=subprocess.PIPE,
                                      env={'LC_ALL': 'C', 'LANG': 'C'}) as p:
                    res = re.search(regex, p.stdout.read())
                    if res:
                        return os.fsdecode(res.group(1))
            except OSError:
                pass
=cut

# does not work on windows:
my $lib = Affix::locate_lib( Affix::Platform::OS() =~ /Win\d\d/ ? 'ntdll' : 'm' );
use Path::Tiny;
diag $lib;
$lib = readlink $lib if -l $lib;
diag $lib;
$lib = path $lib;
diag $lib;

#~ use Data::Dump;
#~ ddx $lib;
my $ref = Affix::load_lib( $lib->absolute );
diag $_ for @{ Affix::Lib::list_symbols($ref) };
#
pass 'yep';
#
done_testing;
