use Test2::V0 '!subtest';
use Test2::Util::Importer 'Test2::Tools::Subtest' => ( subtest_streamed => { -as => 'subtest' } );
use lib './lib', '../lib', '../blib/arch/', 'blib/arch', '../', '.';
use Affix          qw[:all];
use t::lib::helper qw[leaktest];
$|++;
#
leaktest 'leaky type' => sub {
    @Affix::Type::IINNTT::ISA = qw[Affix::Typex];
    my $ttt = Affix::Type::IINNTT->new(
        'Int',                             # stringify
        Affix::INT_FLAG(),                 # flag
        Affix::Platform::SIZEOF_INT(),     # sizeof
        Affix::Platform::ALIGNOF_INT(),    # alignment
        0                                  # offset
    );
    ddx $ttt;
    ok $ttt;
    $ttt = undef;
    1;
};
leaktest 'nope' => sub {
    1;
};
done_testing;
