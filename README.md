[![Actions Status](https://github.com/sanko/App-bsky/actions/workflows/ci.yml/badge.svg)](https://github.com/sanko/App-bsky/actions) [![MetaCPAN Release](https://badge.fury.io/pl/App-bsky.svg)](https://metacpan.org/release/App-bsky)
# NAME

bsky - A Command-line Bluesky Client

# SYNOPSIS

```perl
# create user session
$ bsky login [handle] [password]

# view recent posts
$ bsky timeline ...

# create a post
$ bsky post ...
```

# DESCRIPTION

`bsky` is a simple command line client for Bluesky in Perl.

# Usage

```
bsky [global options] command [command options] [arguments...]
```

## Commands

- `show-profile`

    show profile

- `update-profile`

    update profile

- `timeline`, `tl`

    show timeline

- `thread`

    show thread

- `post`

    post new text

- `vote`

    vote the post

- `votes`

    show votes of the post

- `repost`

    repost the post

- `reposts`

    show reposts of the post

- `follow`

    follow the handle

- `follows`

    show follows

- `followers`

    show followers

- `delete`

    delete the note

- `login`

    login the social

- `help`, `h`

    shows a list of commands or help for one command

## Global Options

> ```
> -a value       profile name
> -V             verbose (default: false)
> --help, -h     show help
> --version, -v  print the version
> ```

# See Also

[At](https://metacpan.org/pod/At).pm

[https://github.com/mattn/bsky](https://github.com/mattn/bsky) - Original Golang client

# LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2\. Other copyrights, terms, and conditions may apply to data transmitted through this module.

# AUTHOR

Sanko Robinson <sanko@cpan.org>
