use Test2::V0;
use v5.38;
#
use lib '../lib';
use App::bsky;
use Path::Tiny;
use Test2::Tools::Warnings qw[warns];
use Text::Wrap;
use Capture::Tiny;
#
my ( @err, @say );
my $mock = mock 'App::bsky::CLI' => (
    override => [
        err => sub ( $self, $msg, $fatal //= 0 ) {
            note $msg;
            push @err, $msg;
            !$fatal;
        },
        say => sub ( $self, $msg, @etc ) {
            $msg = @etc ? sprintf $msg, @etc : $msg;
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
is is_say { new_client->run(qw[config wrap]) }, 100, 'config wrap == 100';
ok new_client->run(qw[config wrap 0]), 'config wrap 0';
is is_say { new_client->run(qw[config wrap]) }, 0, 'config wrap == 0';
subtest 'login ... ... (error)' => sub {
    my $client;
    like warning {
        $client = new_client->run(qw[login fake aaaa-aaaa-aaaa-aaaa])
    }, qr[Error creating session], 'warns on bad auth info';
    ok !$client, 'client is undef';
};
ok new_client->run(qw[login atperl.bsky.social qbhd-opac-arvg-j7ol]),                            'login ... ...';
ok new_client->run(qw[login atperl.bsky.social qbhd-opac-arvg-j7ol --host https://bsky.social]), 'login ... ... --host ...';
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
    skip_all 'sankor.bsky.social is already followed; might be a race condition with another smoker'
        if is_say { new_client->run(qw[follows]) } =~ qr[sankor.bsky.social];
    skip_all 'sankor.bsky.social is blocked and cannot be followed; might be a race condition with another smoker'
        if is_say { new_client->run(qw[blocks]) } =~ qr[sankor.bsky.social];
    like is_say { new_client->run(qw[follow sankor.bsky.social]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'follow sankor.bsky.social';
    like is_say { new_client->run(qw[follows]) }, qr[sankor.bsky.social], 'follows';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[unfollow sankor.bsky.social]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'unfollow sankor.bsky.social';
    unlike is_say { new_client->run(qw[follows]) }, qr[sankor.bsky.social], 'follows';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[follow did:plc:2lk3pbakx2erxgotvzyeuyem]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'follow did:plc:2lk3pbakx2erxgotvzyeuyem';
    like is_say { new_client->run(qw[follows]) }, qr[sankor.bsky.social], 'follows';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[unfollow did:plc:2lk3pbakx2erxgotvzyeuyem]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.follow],
        'unfollow did:plc:2lk3pbakx2erxgotvzyeuyem';
};
todo 'using random images pulled from the web... things may go wrong' => sub {
    like is_say {
        new_client->run(qw[update-profile --avatar https://cataas.com/cat?width=100 --banner https://cataas.com/cat?width=1000])
    }, qr[did:plc:pwqewimhd3rxc4hg6ztwrcyj], 'update-profile --avatar ... --banner ...';
};
subtest 'block/unblock' => sub {
    skip_all 'sankor.bsky.social is already blocked; might be a race condition with another smoker'
        if is_say { new_client->run(qw[blocks]) } =~ qr[sankor.bsky.social];

    #~ skip_all 'testing!';
    like is_say { new_client->run(qw[block sankor.bsky.social]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.block],
        'block sankor.bsky.social';
    sleep 1;    # sometimes the service has to catch up
    like is_say { new_client->run(qw[blocks]) }, qr[sankor.bsky.social], 'blocks';
    like is_say { new_client->run(qw[unblock sankor.bsky.social]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.graph.block],
        'unblock sankor.bsky.social';
};
subtest 'post/delete' => sub {
    like my $uri = is_say { new_client->run(qw[post Demo]) }, qr[at://did:plc:pwqewimhd3rxc4hg6ztwrcyj/app.bsky.feed.post], 'post Demo';
    sleep 1;    # sometimes the service has to catch up
    ok new_client->run( 'delete', $uri ), 'delete at://...';
};
like is_say { new_client->run(qw[notifications]) },        qr[did:plc:pwqewimhd3rxc4hg6ztwrcyj], 'notifications';
like is_say { new_client->run(qw[notifications --json]) }, qr[^{],                               'notifications --json';
like is_say { new_client->run(qw[show-session]) },         qr[did:plc:pwqewimhd3rxc4hg6ztwrcyj], 'show-session';
like is_say { new_client->run(qw[show-session --json]) },  qr[^{],                               'show-session --json';
#
{
    no experimental 'signatures';

    sub capture(&) {
        my $code = shift;
        my ( $err, $out ) = ( "", "" );

        #~ my $handles = test2_stack->top->format->handles;
        my ( $ok, $e );
        {
            my ( $out_fh, $err_fh );
            open( $out_fh, '>', \$out ) or die "Failed to open a temporary STDOUT: $!";
            open( $err_fh, '>', \$err ) or die "Failed to open a temporary STDERR: $!";

            #~ test2_stack->top->format->set_handles([$out_fh, $err_fh, $out_fh]);
            ( $ok, $e ) = $code->();
        }

        #~ test2_stack->top->format->set_handles($handles);
        die $e unless $ok;
        $err =~ s/ $/_/mg;
        $out =~ s/ $/_/mg;
        return { STDOUT => $out, STDERR => $err, };
    }
}
subtest 'internal say/err' => sub {
    $mock = undef;
    my $client = new_client;
    my ( $stdout, $stderr, $count ) = Capture::Tiny::capture(
        sub {
            $client->run(qw[config wrap 10]);
            $client->say( 'X' x 50 );
            $client->run(qw[config wrap 0]);
            $client->err( 'Y' x 50 );
        }
    );
    like $stdout, qr[^X{9}$]m,  'say wraps';
    like $stderr, qr[^Y{50}$]m, 'err wraps';
};
#
done_testing;
__END__
=pod

=encoding utf-8

=head1 NAME

App::bsky::t - Test

=cut
