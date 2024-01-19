requires 'perl', '5.038000';    # class syntax
requires 'At';
requires 'Getopt::Long';
requires 'Pod::Text';
requires 'Path::Tiny';
requires 'File::HomeDir';
requires 'JSON::Tiny';
on 'test' => sub {
    requires 'Test2::V0';    # core as of 5.39.x
};
on 'develop' => sub {
    requires 'Software::License::Artistic_2_0';
    recommends 'Perl::Tidy';
    recommends 'Pod::Tidy';
    recommends 'Code::TidyAll::Plugin::PodTidy';
    recommends 'Code::TidyAll';
    requires 'Pod::Markdown::Github';
    recommends 'Test::Pod';
    recommends 'Test::PAUSE::Permissions';
    recommends 'Test::MinimumVersion::Fast';
    recommends 'Test::CPAN::Meta';
    recommends 'Test::Spellunker';
    requires 'Minilla';
    recommends 'Data::Dump';
    requires 'Version::Next';
    requires 'CPAN::Uploader';
};
