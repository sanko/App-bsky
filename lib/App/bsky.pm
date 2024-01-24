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
        use Text::Wrap;
        #
        field $bsky;
        field $config;
        field $config_file : param //= path( File::HomeDir->my_data )->absolute->child('.bsky');
        #
        ADJUST {
            $config_file = path($config_file) unless builtin::blessed $config_file;
            $self->config;
            if ( defined $config->{session}{accessJwt} ) {    # Check if the tokens are expired...

                #~ use Data::Dump;
                #~ ddx $config;
                sub _decode_token ($token) {
                    use MIME::Base64 qw[decode_base64];
                    my ( $header, $payload, $sig ) = split /\./, $token;
                    $payload =~ tr[-_][+/];    # Replace Base64-URL characters with standard Base64
                    decode_json decode_base64 $payload;
                }
                my $access = _decode_token $config->{session}{accessJwt};

                #~ use Data::Dump;
                #~ ddx $access;
                #~ warn time;
                #~ warn $access->{exp} - time;
                if ( time > $access->{exp} ) {

                    #~ warn;
                    $config->{session}{accessJwt} = $config->{session}{refreshJwt};
                    $bsky                         = At::Bluesky->resume( %{ $config->{session} } );
                    $config->{session}            = $bsky->server_refreshSession( $config->{session}{refreshJwt} );
                    $config->{session}{did}       = $config->{session}{did}->_raw;
                    $config->{session}{handle}    = $config->{session}{handle}->_raw;
                    my $refresh = _decode_token $config->{session}{refreshJwt};

                    #~ ddx $refresh;
                    #~ warn time;
                    #~ warn time - $refresh->{exp};
                    if ( $refresh->{exp} > time ) {
                        $bsky->resume( %{ $bsky->server_refreshSession( $config->{session}{refreshJwt} ) } );
                    }
                    else {
                        $self->err('Please log in');
                    }
                }
                else {
                    #~ warn;
                    #~ use Data::Dump;
                    #~ ddx $config;
                    #~ ddx $config->{session};
                    $bsky = At::Bluesky->resume( %{ $config->{session} } );
                }
            }
            else {
                #~ warn;
                $bsky = At::Bluesky->new();
            }
        }

        method config() {
            $self->get_config if !$config && $config_file->is_file && $config_file->size;
            $config->{settings} //= { wrap => 72 };
            $config;
        }

        method DESTROY ( $global //= 0 ) {
            return unless $config;
            $self->put_config;
        }
        #
        method get_config() {
            $config = decode_json $config_file->slurp_utf8;
        }
        method put_config() { $config_file->spew_utf8( encode_json $config ); }

        method err ( $msg, $fatal //= 0 ) {
            $Text::Wrap::columns = $config->{settings}{wrap};
            $msg = Text::Wrap::wrap( '', '', $msg ) if length $msg && $config->{settings}{wrap};
            die "$msg\n" if $fatal;
            warn "$msg\n";
            !$fatal;
        }

        method say ( $msg, @etc ) {
            $Text::Wrap::columns = $config->{settings}{wrap};
            $msg = @etc ? sprintf $msg, @etc : $msg;
            my $indent = $msg =~ /^(\s*)/ ? $1 : '';
            $msg = Text::Wrap::wrap( '', $indent, $msg ) if length $msg && $config->{settings}{wrap};
            CORE::say $msg;
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

        method cmd_showprofile (@args) {
            GetOptionsFromArray( \@args, 'json!' => \my $json, 'handle|H=s' => \my $handle );
            my $profile = $bsky->actor_getProfile( $handle // $config->{session}{handle} );
            if ($json) {
                $self->say( JSON::Tiny::to_json( $profile->_raw ) );
            }
            else {
                $self->say( 'DID: %s',         $profile->did->_raw );
                $self->say( 'Handle: %s',      $profile->handle->_raw );
                $self->say( 'DisplayName: %s', $profile->displayName // '' );
                $self->say( 'Description: %s', $profile->description // '' );
                $self->say( 'Follows: %d',     $profile->followsCount );
                $self->say( 'Followers: %d',   $profile->followersCount );
                $self->say( 'Avatar: %s',      $profile->avatar // '' );
                $self->say( 'Banner: %s',      $profile->banner // '' );
            }
            1;
        }

        method cmd_updateprofile() {
            ...;
        }
        method cmd_showsession() { }

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

                    #~ use Data::Dump;
                    #~ ddx $post->_raw;
                    # TODO: Support image embeds as raw links
                    $self->say(
                        '%s%s%s%s%s (%s)',
                        ' ' x ( $depth * 4 ),
                        color('red'), $post->author->handle->_raw,
                        color('reset'),
                        defined $post->author->displayName ? ' [' . $post->author->displayName . ']' : '',
                        $post->record->createdAt->_raw
                    );
                    if ( $post->embed && defined $post->embed->_raw->{images} )
                    {    # TODO: Check $post->embed->$type to match 'app.bsky.embed.images#view'
                        $self->say( '%s%s', ' ' x ( $depth * 4 ), $_->{fullsize} ) for @{ $post->embed->_raw->{images} };
                    }
                    $self->say( '%s%s',                 ' ' x ( $depth * 4 ), $post->record->text );
                    $self->say( '%s 👍(%d) ⚡(%d) 🔄(%d)', ' ' x ( $depth * 4 ), $post->likeCount, $post->replyCount, $post->repostCount );
                    $self->say( '%s',                   ' ' x ( $depth * 4 ) );
                }
                for my $post ( @{ $tl->{feed} } ) {

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

        method cmd_stream() {

            # Mojo::UserAgent is triggering 'Subroutine attributes must come before the signature' bug in perl 5.38.x
            return $self->err('Streaming client requires Mojo::UserAgent') unless $Mojo::UserAgent::VERSION;
        }

        method cmd_thread () {
            ...;
        }

        method cmd_post () {
            ...;
        }

        method cmd_delete ($cid) {
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

        method cmd_unfollow ($handle) {
            ...;
        }

        method cmd_follows ($handle) {
            ...;
        }

        method cmd_followers ( $user //= () ) {
            ...;
        }

        method cmd_block ($handle) {
            ...;
        }

        method cmd_unblock ($handle) {
            ...;
        }

        method cmd_blocks () {
            ...;
        }

        method cmd_login ( $ident, $password, @args ) {
            GetOptionsFromArray( \@args, 'host=s' => \my $host );
            $bsky = At::Bluesky->new( identifier => $ident, password => $password, defined $host ? ( _host => $host ) : () );
            return $self->err( '', 1 ) unless $bsky->session;
            $config->{session} = $bsky->session;    # Already raw
            $self->say( $config ?
                    'Logged in' .
                    ( $host ? ' at ' . $host : '' ) . ' as ' .
                    color('red') .
                    $ident .
                    color('reset') . ' [' .
                    $config->{session}{did} . ']' :
                    'Failed to log in as ' . $ident );
        }

        method cmd_notifications ($handle) {
            ...;
        }

        method cmd_notif ($handle) {
            ...;
        }

        method cmd_invitecodes () {
            ...;
        }

        method cmd_listapppasswords ($handle) {
            ...;
        }

        method cmd_addapppassword ($handle) {
            ...;
        }

        method cmd_revokeapppassword ($handle) {
            ...;
        }

        method cmd_config ( $field //= (), $value //= () ) {
            unless ( defined $field ) {
                $self->say('Current config:');
                for my $k ( sort keys %{ $config->{settings} } ) {
                    $self->say( '  %-20s %s', $k . ':', $config->{settings}{$k} );
                }
            }
            elsif ( defined $field && defined $config->{settings}{$field} ) {
                if ( defined $value ) {
                    $config->{settings}{$field} = $value;
                    $self->say( 'Config value %s set to %s', $field, $value );
                }
                else {
                    $self->say( $config->{settings}{$field} );
                }
            }
            else {
                return $self->err( 'Unknown config field: ' . $field, 1 );
            }
            return 1;
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
                $command = 'timeline'      if $command eq 'tl';
                $command = 'notifications' if $command eq 'notif';
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
