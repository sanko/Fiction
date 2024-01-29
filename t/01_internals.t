use Test2::V0;
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
use Affix;
BEGIN { chdir '../' if !-d 't'; }
use t::lib::helper;
$|++;
use v5.38;
#
my $platform = 'Affix::Platform::' . (
    $^O =~ /MSWin/ ? 'Windows' : $^O =~ /darwin/ ? 'MacOS' : $^O =~ /bsd/i ? 'BSD' :    # XXX: dragonfly, etc.
        'Unix'
);
diag $platform;
eval qq[require $platform; $platform->import(':all')];
my ($lib) = find_library( $^O =~ /MSWin/ ? 'ntdll' : 'm' );
ok $lib, $lib;
diag $lib;
done_testing;
exit;
__END__
die _get_soname(@libs);
diag $_ for @libs;
diag $libs[0];
my $refx = Affix::load_lib( $libs[0] );
diag $$refx;

#~ diag $_ for @{ Affix::Lib::list_symbols( $refx ) };
diag Affix::Lib::find_symbol( $refx, 'pow' );
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
