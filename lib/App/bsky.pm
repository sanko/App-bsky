package App::bsky 0.01 {
    use v5.38;
    use Getopt::Long qw[];
    use At;
    use experimental 'class';
    $|++;

    class App::bsky::CLI {

        method err ( $msg, $fatal //= 0 ) {
            die "$msg\n" if $fatal;
            warn "$msg\n";
            $fatal;
        }

        method say ($msg) {
            CORE::say $msg;
            1;
        }

        method run (@args) {

            #~ use Data::Dump;
            #~ ddx \@args;
            return $self->err( 'No subcommand found. Try bsky --help', 1 ) unless @args;
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

        method cmd_timeline() {
            ...;
        }
        method cmd_tl() { $self->cmd_timeline; }

        method cmd_thread () {
            ...;
        }

        method cmd_post () {
            ...;
        }

        method cmd_vote () {
            ...;
        }

        method cmd_votes () {
            ...;
        }

        method cmd_repost () {
            ...;
        }

        method cmd_reposts () {
            ...;
        }

        method cmd_follow () {
            ...;
        }

        method cmd_follows () {
            ...;
        }

        method cmd_followers () {
            ...;
        }

        method cmd_delete () {
            ...;
        }

        method cmd_login ( $ident, $password ) {
            warn 'Log in as ' . $ident;
            ...;
        }

        method cmd_help() {    # cribbed from App::cpm::CLI
            use Pod::Text;
            open my $fh, '>', \my $out;
            Pod::Text->new->parse_from_file( $0, $fh );
            $out =~ s/^[ ]{6}/    /mg;
            $self->say($out);
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

    $ bsky ...

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
