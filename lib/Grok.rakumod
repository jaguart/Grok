use v6.d+;

unit module Grok;

use Grok::Wisp;

use Grok::Utils :is-core-class, :header-line;

# recursion control
our $DEPTH;
our %SEEN;

#-------------------------------------------------------------------------------
#| Introspect a thing.
#| :deeply -> recurse into parents, roles etc;
#| :core -> include core classes.
#| :local -> skip composed / imported methods
#| :detail -> include extra detail
sub grok (
    Mu $thing is raw,
    :$deeply  = False,
    :$core    = False,
    :$local   = False,
    :$detail  = False,
    :$where   = Nil,
  ) is export {

  $DEPTH = 0;
  %SEEN = ();

  #say
  #  'grok: ',
  #    (
  #      $deeply  ?? ':deeply' !! '' ,
  #      $core    ?? ':core'   !! '' ,
  #      $local   ?? ':local'  !! '' ,
  #      $detail  ?? ':detail' !! '' ,
  #      $where   ?? ':where'  !! '' ,
  #    )
  #    .grep( *.so )
  #    .join(' ') || 'defaults',
  #    ;

  _grok( $thing, :$deeply, :$core, :$local, :$detail, :$where );

}

#-------------------------------------------------------------------------------
#| internal - for recursion
sub _grok (
    Mu $thing is raw,
    :$deeply,
    :$core,
    :$local,
    :$detail,
    :$where,
    :$context = '',
  ) {

  return if %SEEN{$thing.WHICH}++;

  # The count is just in case we directly grokked a core
  return if !$core && is-core-class($thing) && %SEEN.elems > 1 ;

  #say header-line( $context );
  my $prefix = '  ';

  my $wisp = Wisp.new(:thing($thing));

  say $wisp.gist( :$detail, :notwhere($wisp.mop.package)  );

  # $notwhere controls whether gist includes 'where' aka 'in ' ~ .package.
  # To reduce noise, we suppress in-package on local attributes and methods
  # $notwhere should be:
  #   True    -> DON'T  gist in-package at all.
  #   False   -> ALWAYS gist in-package
  #   String  -> ONLY   gist in-package when NOT this string
  #
  # Note that $detail overrides $notwhere in Wisp
  #
  my $notwhere =
    do given $where {
      when Bool:D { not $where }
      default     { $wisp.mop.package }
    };

  for $wisp.mop.parents( :all, :$local ) -> $parent {
    say $prefix, Wisp.new(:thing($parent)).gist( :$detail );
  }

  for $wisp.mop.roles( :all, :$local ) -> $role {
    say $prefix, Wisp.new(:thing($role)).gist( :$detail );
  }

  for $wisp.mop.attributes( :$local, ) -> $attribute {
    say $prefix, Wisp.new(:thing($attribute)).gist( :$detail, :$notwhere );
  }

  for $wisp.mop.methods( :$local ) -> $method {
    say $prefix, Wisp.new(:thing($method)).gist( :$detail, :$notwhere );
  }

  say '';

  if $deeply {

    $DEPTH++;
    for $wisp.mop.parents( :all, :$local ) -> $parent {
      _grok(
          $parent,
          :$deeply,
          :$core,
          :$local,
          :$detail,
          :$where,
          :context( $wisp.whom ~ ' parent ' ~ $DEPTH )
        );
    }
    for $wisp.mop.roles( :all, :$local ) -> $role {
      _grok(
          $role,
          :$deeply,
          :$core,
          :$local,
          :$detail,
          :$where,
          :context( $wisp.whom ~ ' role ' ~ $DEPTH )
        );
    }
    $DEPTH--;
  }

  return;

}

#-------------------------------------------------------------------------------
#| Describe a thing.
sub wisp (
    Mu $thing is raw,
    :$detail  = False,
    :$where   = Nil,
  ) is export {

  my $wisp = Wisp.new(:thing($thing));
  my $notwhere =
    do given $where {
      when Bool:D { not $where }
      default     { $wisp.mop.package }
    };

  say $wisp.gist( :$detail, :$notwhere );

}

=begin pod

![Build Status](https://github.com/jaguart/Grok/actions/workflows/test.yml/badge.svg)

=head1 NAME

Grok - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use Grok;

=end code

=head1 DESCRIPTION

Grok is ...

=head1 AUTHOR

Jeff Armstrong <jeff@jamatic.tech>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Jeff Armstrong

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
