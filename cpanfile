requires 'perl', '5.026000';      # 2017 is a lifetime ago in software
recommends 'perl', '5.038000';    # Bugs that only crop up before this version will go unfixed
requires 'File::Spec';
requires 'Config';
requires 'XSLoader';
requires 'Sub::Util';
requires 'Attribute::Handlers';
requires 'File::Temp';            # Used in Affix::Platform::Unix::_findLib_gcc(...)
requires 'Scalar::Util';

# TODO: remove this!!!!
requires 'Data::Dump';
#
on 'test' => sub {
    requires 'Test2::V0';
    requires 'File::Temp';    # Used in tests that compile short C/CPP files
    requires 'Unicode::GCString';
};
on 'configure' => sub {
    requires 'Archive::Tar';
    requires 'CPAN::Meta';
    requires 'Devel::CheckBin';
    requires 'ExtUtils::Config'  => 0.003;
    requires 'ExtUtils::Helpers' => 0.020;
    requires 'ExtUtils::Install';
    requires 'ExtUtils::InstallPaths' => 0.002;
    requires 'File::Basename';
    requires 'File::Find';
    requires 'File::Path';
    requires 'File::Spec::Functions';
    requires 'Getopt::Long' => 2.36;

    #requires 'HTTP::Tiny';
    #requires 'IO::Socket::SSL' => 1.42;
    requires 'IO::Uncompress::Unzip';
    requires 'JSON::PP' => 2;
    requires 'Module::Build::Tiny';

    #requires 'Net::SSLeay' => 1.49;
    requires 'Path::Tiny' => 0.144;
};
on 'develop' => sub {
    requires 'CPAN::Uploader';
    requires 'Code::TidyAll';
    requires 'Code::TidyAll::Plugin::ClangFormat';
    requires 'Code::TidyAll::Plugin::PodTidy';
    requires 'Code::TidyAll::Plugin::YAML';
    requires 'Perl::Tidy';
    requires 'Pod::Tidy';
    requires 'Test::CPAN::Meta';
    requires 'Test::MinimumVersion::Fast';
    requires 'Test::PAUSE::Permissions';
    requires 'Test::Pod' => 1.41;
    requires 'Test::Spellunker';
    requires 'Version::Next';
    requires 'Pod::Markdown::Github';
    requires 'Software::License::Artistic_2_0';
    requires 'Minilla';
    recommends 'Benchmark';
};
