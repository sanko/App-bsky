use Test2::V0;
use v5.38;
#
use lib '../lib';
use App::bsky;
use Path::Tiny;
use Test2::Tools::Warnings qw[warns];
use Text::Wrap;
#
my ( @err, @say );
my $mock = mock 'App::bsky::CLI' => (
    override => [
        err => sub ( $self, $msg, $fatal //= 0 ) {
            $Text::Wrap::columns //= 72;
            $msg = Text::Wrap::wrap( '', '', $msg );
            note $msg;
            push @err, $msg;
            !$fatal;
        },
        say => sub ( $self, $msg, @etc ) {
            $Text::Wrap::columns //= 72;
            $msg = Text::Wrap::wrap( '', '', @etc ? sprintf $msg, @etc : $msg );
            note $msg;
            push @say, $msg;
            1;
        }
    ]
);
{
    no experimental 'signatures';

    sub is_err(&) {
        my $code = shift;
        @err = ();
        $code->();
        wantarray ? @err : join "\n", @err;
    }

    sub is_say(&) {
        my $code = shift;
        @say = ();
        $code->();
        wantarray ? @say : join "\n", @say;
    }
}
my $tmp = Path::Tiny->tempfile('.bsky.XXXXX');
#
sub new_client { App::bsky::CLI->new( config_file => $tmp ) }
isa_ok new_client(), ['App::bsky::CLI'];
#
ok !new_client->run(),                   '(no params)';
ok !new_client->run('fdsaf'),            'fdsaf';
ok new_client->run('-V'),                '-V';
ok new_client->run('--version'),         '--version';
ok new_client->run('-h'),                '-h';
ok new_client->run('config'),            'config';
ok !new_client->run(qw[config fake]),    'config fake';
ok new_client->run(qw[config wrap 100]), 'config wrap 100';
ok new_client->run(qw[config wrap]),     'config wrap';
subtest 'login ... ... (error)' => sub {
    my $client;
    like warning {
        $client = new_client->run(qw[login fake aaaa-aaaa-aaaa-aaaa])
    }, qr[Error creating session], 'warns on bad auth info';
    ok !$client, 'client is undef';
};
ok new_client->run(qw[login atperl.bsky.social ck2f-bqxl-h54l-xm3l]),                            'login ... ...';
ok new_client->run(qw[login atperl.bsky.social ck2f-bqxl-h54l-xm3l --host https://bsky.social]), 'login ... ... --host ...';
note 'the following are using the automatic resume data';
ok new_client->run(qw[tl]), 'timeline';
like is_say { new_client->run(qw[tl --json]) },                                qr[^{],                 'timeline --json';
like is_say { new_client->run(qw[show-profile]) },                             qr[atperl.bsky.social], 'show-profile';
like is_say { new_client->run(qw[show-profile --json]) },                      qr[^{],                 'show-profile --json';
like is_say { new_client->run(qw[show-profile --handle sankor.bsky.social]) }, qr[sankor.bsky.social], 'show-profile --handle sankor.bsky.social';
like is_say { new_client->run(qw[show-profile --json --handle sankor.bsky.social]) }, qr["sankor], 'show-profile --json --handle sankor.bsky.social';
like is_say { new_client->run(qw[show-profile --json -H sankor.bsky.social]) },       qr["sankor], 'show-profile --json -H sankor.bsky.social';
subtest 'follows' => sub {
    like is_say { new_client->run(qw[follows]) },                                    qr[atproto.com], 'follows';
    like is_say { new_client->run(qw[follows --json]) },                             qr[^{],          'follows --json';
    like is_say { new_client->run(qw[follows --handle sankor.bsky.social]) },        qr[atproto.com], 'follows --handle sankor.bsky.social';
    like is_say { new_client->run(qw[follows --json --handle sankor.bsky.social]) }, qr["bsky.app"],  'follows --json --handle sankor.bsky.social';
    like is_say { new_client->run(qw[follows --json -H sankor.bsky.social]) },       qr["bsky.app"],  'follows --json -H sankor.bsky.social';
};
subtest 'followers' => sub {    # These tests might fail! I cannot control who follows the test account
    my $todo = todo 'I cannot control who follows the test account';
    like is_say { new_client->run(qw[followers]) },                                    qr[deal.bsky.social], 'followers';
    like is_say { new_client->run(qw[followers --json]) },                             qr[^{],               'followers --json';
    like is_say { new_client->run(qw[followers --handle sankor.bsky.social]) },        qr[atproto.com],      'followers --handle sankor.bsky.social';
    like is_say { new_client->run(qw[followers --json --handle sankor.bsky.social]) }, qr["bsky.app"], 'followers --json --handle sankor.bsky.social';
    like is_say { new_client->run(qw[followers --json -H sankor.bsky.social]) },       qr["bsky.app"], 'followers --json -H sankor.bsky.social';
};
subtest 'follow/unfollow' => sub {
    like is_say { new_client->run(qw[follow sankor.bsky.social]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'follow sankor.bsky.social';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[unfollow sankor.bsky.social]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'unfollow sankor.bsky.social';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[follow did:plc:2lk3pbakx2erxgotvzyeuyem]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'follow did:plc:2lk3pbakx2erxgotvzyeuyem';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[unfollow did:plc:2lk3pbakx2erxgotvzyeuyem]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'unfollow did:plc:2lk3pbakx2erxgotvzyeuyem';
};
like is_say { new_client->run(qw[show-session]) },        qr[did:plc:pwqewimhd3rxc4hg6ztwrcyj], 'show-session';
like is_say { new_client->run(qw[show-session --json]) }, qr[^{],                               'show-session --json';
#
done_testing;
__END__
=pod

=encoding utf-8

=head1 NAME

App::bsky::t - Test

=cut
