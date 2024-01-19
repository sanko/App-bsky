use Test2::V0;
use v5.38;
#
use lib '../lib';
use App::bsky;
#
my $mock = mock 'App::bsky::CLI' => (
    override => [
        err => sub ( $self, $line, $fatal //= 0 ) {

            #~ note $line;
            1;
        },
        say => sub ( $self, $line ) {

            #~ note $line;
            1;
        }
    ]
);
isa_ok my $cli = App::bsky::CLI->new, ['App::bsky::CLI'];
#
ok $cli->run(),            '(no params)';
ok $cli->run('-V'),        '-V';
ok $cli->run('--version'), '--version';
ok $cli->run('-h'),        '-h';
#
done_testing;
__END__
=pod

=encoding utf-8

=head1 NAME

App::bsky::t - Test

=cut
