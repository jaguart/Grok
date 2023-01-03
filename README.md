[![Actions Status](https://github.com/jaguart/Grok/actions/workflows/test.yml/badge.svg)](https://github.com/jaguart/Grok/actions)

NAME
====

grok, wisp - introspection helpers.

SYNOPSIS
========

From the command line:

```bash
raku -MGrok -e 'grok( my $a = 42, :deeply :core)'

raku -MGrok -e 'say wisp( Endian )'
```

Within Raku code:

```bash
use Grok :wisp;

# print the Endian enumerations...
say wisp( Endian );
# Endian - Enum is: Int Cool Any Mu enums: NativeEndian LittleEndian BigEndian

# print Allomorth attributes, methods and recurse into parents, roles including ::CORE types
grok( Allomorph, :deeply, :core )
# lots of output ...
```

DESCRIPTION
===========

Grok contains introspection helpers that display information about Raku things.

For example: You want to know how many times a sub is wrapped - grok a golf to see what methods are available.

```bash
>raku -MGrok -e 'sub s { say "s" }; &s.wrap({ say "w"; next }); grok( &s );'
#s - () Sub+{Routine::Wrapped}
#  Sub - Class is: Routine Block Code Any Mu does: Callable
#  Routine - Class is: Block Code Any Mu does: Callable
#  Block - Class is: Code Any Mu does: Callable
#  Code - Class is: Any Mu does: Callable
#  Any - Class is: Mu
#  Mu - Class
#  Routine::Wrapped - Role
#  Callable - Role
#  $!dispatcher - Mu private read-only in Routine
#  $!do - Code private read-only in Code
#  $!flags - int private read-only in Routine
#  $!inline_info - Mu private read-only in Routine
#  $!package - Mu private read-only in Routine
#  $!phasers - Mu private read-only in Block
#  $!signature - Signature private read-only in Code
#  $!why - Mu private read-only in Block
#  $!wrapper-type - Routine private read-only in Sub+{Routine::Wrapped}
#  $!wrappers - Mu private read-only in Sub+{Routine::Wrapped}
#  @!compstuff - List private read-only in Code
#  @!dispatch_order - List private read-only in Routine
#  @!dispatchees - List private read-only in Routine
#  ADD-WRAPPER - (Sub+{Routine::Wrapped}: &wrapper, *%_ --> Nil) Method in Routine::Wrapped
#  REMOVE-WRAPPER - (Sub+{Routine::Wrapped}: &wrapper, *%_ --> Bool) Method in Routine::Wrapped
#  WRAPPER-TYPE - (Sub+{Routine::Wrapped}: *%_) Method in Routine::Wrapped
#  WRAPPERS - (Sub+{Routine::Wrapped}: *%_) Method in Routine::Wrapped
#  is-wrapped - (Sub+{Routine::Wrapped}: *%_ --> Bool) Method in Routine::Wrapped
```

... and you conclude it's worth checking out `.WRAPPERS.elems`

### sub grok

```raku
sub grok(
    Mu $thing is raw,
    :$deeply = Bool::False,
    :$core = Bool::False,
    :$local = Bool::False,
    :$detail = Bool::False,
    :$where = Nil
) returns Mu
```

Introspect a thing.&emsp; **:deeply** - recurse into parents, roles etc.&emsp; **:core** - include core classes.&emsp; **:local** - skip composed / imported methods.&emsp; **:detail** - include extra detail.&emsp;

### sub wisp

```raku
sub wisp(
    Mu $thing is raw
) returns Wisp
```

An introspection helper - provides .gist and .detail

AUTHOR
======

Jeff Armstrong <jeff@jaguart.tech>

Source can be found at: https://github.com/jaguart/Grok

This is my first Raku module - comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Jeff Armstrong

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

