package App::bsky 0.01 {
    use v5.38;
    use utf8;
    use At::Bluesky;
    use experimental 'class';
    no warnings 'experimental';
    use open qw[:std :encoding(UTF-8)];
    $|++;

    class App::bsky::CLI {
        use JSON::Tiny qw[/code_json/];
        use Path::Tiny;
        use File::HomeDir;
        use Getopt::Long qw[GetOptionsFromArray];
        use Term::ANSIColor;
        #
        field $bsky;
        field $config;
        field $config_file : param //= path( File::HomeDir->my_data )->absolute->child('.bsky');
        #
        ADJUST {
            $config_file = path($config_file) unless builtin::blessed $config_file;
            $self->config;
            if ($config) {    # Check if the tokens are expired...

                sub _decode_token ($token) {
                    use MIME::Base64 qw[decode_base64];
                    my ( $header, $payload, $sig ) = split /\./, $token;
                    $payload =~ tr[-_][+/];    # Replace Base64-URL characters with standard Base64
                    decode_json decode_base64 $payload;
                }
                my $access = _decode_token $config->{session}{accessJwt};
                if ( $access->{exp} < time ) {
                    $config->{session}{accessJwt} = $config->{session}{refreshJwt};
                    $bsky                         = At::Bluesky->resume( %{ $config->{session} } );
                    $config->{session}            = $bsky->server_refreshSession( $config->{session}{refreshJwt} );
                    my $refresh = _decode_token $config->{session}{refreshJwt};
                    if ( $refresh->{exp} > time ) {
                        $bsky->resume( %{ $bsky->server_refreshSession( $config->{session}{refreshJwt} ) } );
                    }
                    else {
                        $self->err('Please log in');
                    }
                }
                else {
                    $bsky = At::Bluesky->resume( %{ $config->{session} } );
                }
            }
            else {
                $bsky = At::Bluesky->new();
            }
        }

        method config() {
            $self->get_config if !$config && $config_file->is_file && $config_file->size;
            $config;
        }

        method DESTROY ( $global //= 0 ) {
            return unless $config;
            $self->put_config;
        }
        #
        method get_config() { $config = decode_json $config_file->slurp_utf8 }
        method put_config() { $config_file->spew_utf8( encode_json $config ); }

        method err ( $msg, $fatal //= 0 ) {
            die "$msg\n" if $fatal;
            warn "$msg\n";
            !$fatal;
        }

        method say ( $msg, @etc ) {
            CORE::say @etc ? sprintf $msg, @etc : $msg;
            1;
        }

        method run (@args) {

            #~ use Data::Dump;
            #~ ddx \@args;
            return $self->err( 'No subcommand found. Try bsky --help', 1 ) unless scalar @args;
            my $cmd = shift @args;
            $cmd =~ m[^-(h|-help)$] ? $cmd = 'help' : $cmd =~ m[^-V$] ? $cmd = 'VERSION' : $cmd =~ m[^-(v|-version)$] ? $cmd = 'version' : ();
            {
                my $cmd = $cmd;
                $cmd =~ s[[^a-z]][]gi;
                if ( my $method = $self->can( 'cmd_' . $cmd ) ) {
                    return $method->( $self, @args );
                }
            }
            $self->err( 'Unknown subcommand found: ' . $cmd . '. Try bsky --help', 1 ) unless @args;
        }

        method cmd_showprofile() {
            ...;
        }

        method cmd_updateprofile() {
            ...;
        }

        method cmd_timeline (@args) {
            GetOptionsFromArray( \@args, 'json!' => \my $json );
            #~ use Data::Dump;
            my $tl = $bsky->feed_getTimeline();

            #$algorithm //= (), $limit //= (), $cursor //= ()
            if ($json) {
                $self->say( JSON::Tiny::to_json( $_->_raw ) ) for @{ $tl->{feed} };
            }
            else {    # TODO: filter where $type ne 'app.bsky.feed.post'

                sub _dump_post ( $self, $depth, $post ) {

                    # TODO: Support image embeds as raw links
                    $self->say(
                        '%s%s%s%s%s (%s)',
                        ( ' ' x ( $depth * 4 ) ),
                        color('red'), $post->author->handle->_raw,
                        color('reset'),
                        defined $post->author->displayName ? ' [' . $post->author->displayName . ']' : '',
                        $post->record->createdAt->_raw
                    );
                    $self->say( '%s%s', ( ' ' x ( $depth * 4 ) ), $post->record->text );
                    $self->say( '%s 👍(%d) ⚡(%d) 🔄(%d)', ( ' ' x ( $depth * 4 ) ), $post->likeCount, $post->replyCount, $post->repostCount );
                    $self->say('');
                }
                for my $post ( reverse @{ $tl->{feed} } ) {

                    #~ ddx $post->_raw;
                    my $depth = 0;
                    if ( $post->reply ) {
                        _dump_post( $self, $depth, $post->reply->parent );
                        $depth = 1;
                    }
                    _dump_post( $self, $depth, $post->post );
                }
            }
            scalar @{ $tl->{feed} };
        }
        method cmd_tl (@args) { $self->cmd_timeline(@args); }

        method cmd_thread () {
            ...;
        }

        method cmd_post () {
            ...;
        }

        method cmd_vote ( $uri, $bool //= !!1 ) {
            ...;
        }

        method cmd_votes ($uri) {
            ...;
        }

        method cmd_repost ($uri) {
            ...;
        }

        method cmd_reposts ($uri) {
            ...;
        }

        method cmd_follow ($handle) {
            ...;
        }

        method cmd_follows ($handle) {
            ...;
        }

        method cmd_followers ( $user //= () ) {
            ...;
        }

        method cmd_delete ($cid) {
            ...;
        }

        method cmd_login ( $ident, $password, $host //= () ) {
            $bsky = At::Bluesky->new( identifier => $ident, password => $password, defined $host ? ( _host => $host ) : () );
            return $self->err( '', 1 ) unless $bsky->session;
            $config->{session} = $bsky->session;
            $self->say( $config ? 'Logged in as ' . color('red') . $ident . color('reset') . ' [' . $config->{session}{did} . ']' :
                    'Failed to log in as ' . $ident );
        }

        method cmd_help ( $command //= () ) {    # cribbed from App::cpm::CLI
            open my $fh, '>', \my $out;
            if ( !defined $command ) {
                use Pod::Text::Color;
                Pod::Text::Color->new->parse_from_file( $0, $fh );
            }
            else {
                BEGIN { $Pod::Usage::Formatter = 'Pod::Text::Color'; }
                use Pod::Usage;
                pod2usage( -output => $fh, -verbose => 99, -sections => [ 'Usage', 'Commands/' . $command ], -exitval => 'noexit' );
            }
            $out =~ s[^[ ]{6}][    ]mg;
            $out =~ s[\s+$][]gs;
            return $self->say($out);
        }

        method cmd_VERSION() {
            $self->cmd_version;
            use Config qw[%Config];
            $self->say($_)
                for '  %Config:',
                ( map {"    $_=$Config{$_}"}
                grep { defined $Config{$_} }
                    sort
                    qw[archname installsitelib installsitebin installman1dir installman3dir sitearchexp sitelibexp vendorarch vendorlibexp archlibexp privlibexp]
                ), '  %ENV:', ( map {"    $_=$ENV{$_}"} sort grep {/^PERL/} keys %ENV ), '  @INC:',
                ( map {"    $_"} grep { ref $_ ne 'CODE' } @INC );
            1;
        }

        method cmd_version() {
            $self->say($_) for 'bsky  v' . $App::bsky::VERSION, 'At.pm v' . $At::VERSION, 'perl  ' . $^V;
            1;
        }
    }
}
1;
__END__

=encoding utf-8

=head1 NAME

App::bsky - A Command-line Bluesky Client

=head1 SYNOPSIS

    bsky [global options] command [command options] [arguments...]

    $ bsky ...

    $ bsky help

    $ bsky help login

    $ bsky login ... ...

=head1 DESCRIPTION

App::bsky is a command line client for the At protocol backed Bluesky social network.

=head1 See Also

L<At>.pm

L<https://github.com/mattn/bsky> - Original Golang client

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=begin stopwords


=end stopwords

=cut
