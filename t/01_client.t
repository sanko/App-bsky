use Test2::V0;
use v5.38;
#
use lib '../lib';
use App::bsky;
use Path::Tiny;
use Test2::Tools::Warnings qw[warns];
#
my $mock = mock 'App::bsky::CLI' => (
    override => [
        err => sub ( $self, $line, $fatal //= 0 ) {

            #~ note $line;
            !$fatal;
        },
        say => sub ( $self, $line ) {
            note $line;
            1;
        }
    ]
);
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
ok new_client->run(qw[login atperl.bsky.social ck2f-bqxl-h54l-xm3l]),                     'login ... ...';
ok new_client->run(qw[login atperl.bsky.social ck2f-bqxl-h54l-xm3l https://bsky.social]), 'login ... ... ...';
note 'the following are using the automatic resume data';
ok new_client->run(qw[tl]), 'timeline';
#
done_testing;
__END__
=pod

=encoding utf-8

=head1 NAME

App::bsky::t - Test

=cut
