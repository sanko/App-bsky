use Test2::V0;
#
use lib '../lib';
use App::bsky;
#
isa_ok my $cli = App::bsky::CLI->new, ['App::bsky::CLI'];
subtest 'commands' => sub {
    can_ok $cli, $_ for sort qw[
        cmd_showprofile cmd_updateprofile
        cmd_post        cmd_delete
        cmd_timeline    cmd_tl
        cmd_thread
        cmd_vote        cmd_votes
        cmd_repost      cmd_reposts
        cmd_follow      cmd_follows         cmd_followers
        cmd_login
        cmd_help
        cmd_VERSION     cmd_version
    ];
};
subtest 'internals' => sub {
    my $cli = App::bsky::CLI->new;
    can_ok $cli, $_ for sort qw[err say run config get_config put_config DESTROY];
};
#
done_testing;
