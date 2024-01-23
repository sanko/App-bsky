use Test2::V0;
use v5.38;
#
use lib '../lib';
use App::bsky;
use Path::Tiny;
use Test2::Tools::Warnings qw[warns];
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
            note @etc ? sprintf $msg, @etc : $msg;
            push @say, @etc ? sprintf $msg, @etc : $msg;
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
ok !new_client->run(),           '(no params)';
ok !new_client->run('fdsaf'),    'fdsaf';
ok new_client->run('-V'),        '-V';
ok new_client->run('--version'), '--version';
ok new_client->run('-h'),        '-h';
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
like is_say { new_client->run(qw[tl --json]) }, qr[^{], 'timeline --json';
#
done_testing;
__END__
=pod

=encoding utf-8

=head1 NAME

App::bsky::t - Test

=cut
