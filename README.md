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

```
bsky show-profile

bsky show-profile --handle sankor.bsky.social

bsky show-profile --json
```

Show profile.

### Options

```perl
--handle handle     user handle; defaults to the logged in account
-H handle           alternative to --handle
--json              boolean flag; content is printed as JSON objects if given
```

## update-profile

```
bsky update-profile --description "Looks like we made it!"

bsky update-profile --name "John Smith"

bsky update-profile --avatar https://cataas.com/cat?width=100 --banner https://cataas.com/cat?width=1000
```

Update profile elements.

### Options

```
--avatar        optional, avatar image (url or local path)
--banner        optional, banner image (url or local path)
--description   optional, blurb about yourself
--name          optional, display name
```

## show-session

```
bsky show-session

bsky show-session --json
```

Show current session.

### Options

```
--json              boolean flag; content is printed as JSON objects if given
```

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

bsky follow sankor.bsky.social

bsky follow did:plc:2lk3pbakx2erxgotvzyeuyem
```

Follow the handle

### Options

```perl
handle          user handle or DID
```

## unfollow

```
bsky unfollow [handle]

bsky unfollow sankor.bsky.social

bsky unfollow did:plc:2lk3pbakx2erxgotvzyeuyem
```

Unfollow the handle

### Options

```perl
handle          user handle or DID
```

## follows

```
bsky follows

bsky follows --handle sankor.bsky.social

bsky follows --json
```

Show follows.

### Options

```perl
--handle handle     user handle; defaults to the logged in account
-H handle           alternative to --handle
--json              boolean flag; content is printed as JSON objects if given
```

## followers

```
bsky followers

bsky followers --handle sankor.bsky.social

bsky followers --json
```

Show followers.

### Options

```perl
--handle handle     user handle; defaults to the logged in account
-H handle           alternative to --handle
--json              boolean flag; content is printed as JSON objects if given
```

## block

```
bsky block [handle]

bsky block sankor.bsky.social

bsky block did:plc:2lk3pbakx2erxgotvzyeuyem
```

Block the handle.

### Options

```perl
handle          user handle or DID
```

## unblock

```
bsky unblock [handle]

bsky unblock sankor.bsky.social

bsky unblock did:plc:2lk3pbakx2erxgotvzyeuyem
```

Unblock the handle.

### Options

```perl
handle          user handle or DID
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

## notifications

```
bsky notifications

bsky notifications --all

bsky notifications --json

# shorthand
bsky notif --all
```

Show notifications.

### Options

```
--all               boolean flag, show all notifications
--json              boolean flag; content is printed as JSON objects if given
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
