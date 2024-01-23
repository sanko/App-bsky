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

# Commands

## config

```
# Print all configuration values
bsky config

# Print a single config value and exit
bsky config wrap

# Set a configuration value
bsky config wrap 100
```

View or change configuration values. See [Configuration](#configuration) for a list of current options.

### Options

```
key         optional
value       optional
```

## show-profile

show profile

## update-profile

update profile

## timeline

```
bsky timeline

bsky timeline --json

# shorthand:
bsky tl
```

Display posts from timeline.

### Options

```
--json      boolean flag; content is printed as JSON objects if given
```

## thread

show thread

## post

post new text

## vote

```
bsky vote [uri] [bool]
```

Vote on the post

### Options

```
uri
bool      optional, a true value (the default) votes the post up, an untrue value is a downvote
```

## votes

```
bsky votes [uri]
```

Show votes of the post.

### Options

```
uri
```

## repost

```
bsky repost [uri]
```

Repost the post

### Options

```
uri
```

## reposts

```
bsky reposts [uri]
```

Show reposts of the post

### Options

```
uri
```

## follow

```
bsky follow [handle]
```

Follow the handle

### Options

```
handle
```

## follows

```perl
bsky follows [user]
```

Show follows.

### Options

```perl
user        optional, defaults to the current logged in account
```

## followers

```perl
bsky followers [user]
```

Show followers.

### Options

```perl
user        optional, defaults to the current logged in account
```

## delete

```
bsky delete [cid]
```

Delete an item.

### Options

```
cid
```

## login

```
bsky login [ident] [password] [--host http://bsky.social]
```

Log into a Bluesky account.

### Options

```
ident
password
--host        optional, defaults to https://bsky.social
```

## help

shows a list of commands or help for one command

# Global Options

```
-a value       profile name
-V             verbose (default: false)
--help, -h     show help
--version, -v  print the version
```

# Configuration

Current configuration values include:

- `wrap`

    ```
    bsky config wrap 100
    ```

    Sets word wrap width in characters for terminal output. The default is `72`.

# See Also

[At](https://metacpan.org/pod/At).pm

[https://github.com/mattn/bsky](https://github.com/mattn/bsky) - Original Golang client

# LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2\. Other copyrights, terms, and conditions may apply to data transmitted through this module.

# AUTHOR

Sanko Robinson <sanko@cpan.org>
