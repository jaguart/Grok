use v6.d+;

# mi6 has it's own opinion
#![Build Status](https://github.com/jaguart/Grok/actions/workflows/test.yml/badge.svg)
# Much of the POD layout etc is due to how mi6 does POD.
# Some of the Declarator content is for markdown - hmmm

=begin pod

[![Version](https://raku.land/zef:jaguart/Grok/badges/version)](https://raku.land/zef:jaguart)
[![Actions Status](https://github.com/jaguart/Grok/actions/workflows/test.yml/badge.svg)](https://github.com/jaguart/Grok/actions)


=head1 NAME

Grok - The way of Raku - Introspection tools


=head1 SYNOPSIS

From the command line:

=begin code :lang<bash>

raku -MGrok -e 'grok( my $a = 42, :deeply :core)'

raku -MGrok -e 'say wisp( Endian )'

=end code


Within Raku code:

=begin code :lang<bash>

use Grok :wisp;

# print the Endian enumerations...
say wisp( Endian );
# Endian - Enum is: Int Cool Any Mu enums: NativeEndian LittleEndian BigEndian

# print Allomorth attributes, methods and recurse into parents, roles including ::CORE types
grok( Allomorph, :deeply, :core )
# lots of output ...

=end code


=head1 DESCRIPTION

Grok contains introspection helpers that display information about Raku things.

For example: You want to know how many times a sub is wrapped - grok a golf to see what methods are available.

=begin code :lang<bash>

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

=end code

... and you conclude it's worth checking out C<.WRAPPERS.elems>.

=end pod
#' - UE syntax highlight

#-------------------------------------------------------------------------------
unit module Grok;

use Grok::DOM::Factory;

use Kaolin::Wisp  :Wisp;
use Kaolin::Utils :is-core-class, :header-line;

# recursion control
our $DEPTH;
our %SEEN;

#-------------------------------------------------------------------------------
#| Introspect a thing. `` grok( Allomorph, :deeply, :core ); ``
#| - **:deeply**  - recurse into parents, roles etc.
#| - **:core**    - include core classes.
#| - **:local**   - skip composed / imported methods.
#| - **:detail**  - include extra detail.
#| - **:where**   - True - show in-package, False - hide in-package, Default - show imported package names.
#| - **:hide**    - hide this string, used by Scry to remove POD generation artifacts.
sub grok (
    Mu $thing is raw,
    #:$deeply  = False,
    #:$core    = False,
    #:$local   = False,
    #:$detail  = False,
    #:$where   = Nil,
    #:$hide    = Nil,


    :$ascend  = False,
    :$descend = False,
    :$deeply  = False,

    :$local   = False,
    :$filter  = Nil,

    :$core    = False,
    :$detail  = False,
    :$hide    = Nil,

    :$where   = Nil,



  ) is export(:DEFAULT,:grok) {


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

  #_grok( $thing, :$deeply, :$core, :$local, :$detail, :$where, :$hide );

  my $dom = Grok::DOM::Factory.new.create(
                $thing,
                :$ascend,
                :$descend,
                :$deeply,
                :$local,
                :$filter,
                :$core,
                :$detail,
                :$hide,
                :$where,
            );
  $dom.dump( :plain );
  say $dom;

}

#-------------------------------------------------------------------------------
# internal - for recursion
my sub _grok (
    Mu $thing is raw,
    :$deeply,
    :$core,
    :$local,
    :$detail,
    :$where,
    :$context = '',
    :$hide = '',
  ) {

  my $which = $thing.?WHICH;
  return if $which and %SEEN{$which}++;

  # The count is just in case we directly grokked a core
  return if !$core && is-core-class($thing) && %SEEN.elems > 1 ;

  #say header-line( $context );
  my $prefix = '  ';

  my $wisp = Wisp.new(:thing($thing),:$hide);

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
    say $prefix, Wisp.new(:thing($parent),:$hide).gist( :$detail );
  }

  for $wisp.mop.roles( :all, :$local ) -> $role {
    say $prefix, Wisp.new(:thing($role),:$hide).gist( :$detail );
  }

  for $wisp.mop.exports() -> $p {
    say $prefix, Wisp.new(:thing($p.value),:$hide).gist( :$detail );
  }

  for $wisp.mop.knows() -> $p {
    say $prefix, Wisp.new(:thing($p.value),:$hide).gist( :$detail );
  }

  for $wisp.mop.attributes( :$local, ) -> $attribute {
    say $prefix, Wisp.new(:thing($attribute),:$hide).gist( :$detail, :$notwhere );
  }

  for $wisp.mop.methods( :$local ) -> $method {
    say $prefix, Wisp.new(:thing($method),:$hide).gist( :$detail, :$notwhere );
  }

  say '';

  if $deeply {

    $DEPTH++;

      for $wisp.mop.exports() -> $pair {
        _grok(
            $pair.value
            :$deeply,
            :$core,
            :$local,
            :$detail,
            :$where,
            :context( $wisp.whom ~ ' export ' ~ $DEPTH )
            :$hide,
            );
      }

    for $wisp.mop.parents( :all, :$local ) -> $parent {
      _grok(
          $parent,
          :$deeply,
          :$core,
          :$local,
          :$detail,
          :$where,
          :context( $wisp.whom ~ ' parent ' ~ $DEPTH )
          :$hide,
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
          :$hide,
        );
    }
    $DEPTH--;
  }

  return;

}

#-------------------------------------------------------------------------------
#| An introspection helper - e.g. `` say wisp( Endian ) ``
#| Provides:
#| - **.gist**    - string containing: whom, what, where, why
#| - **.detail** - string containing: whom, what, where, origin, why
sub wisp ( Mu $thing is raw, |args  --> Wisp ) is export(:DEFAULT,:wisp) {
  Wisp.new(:thing($thing), |args)
}

#-------------------------------------------------------------------------------
=begin pod

=head1 AUTHOR

Jeff Armstrong <jeff@jaguart.tech>

Source can be found at: https://github.com/jaguart/Grok

This is my first Raku module - comments and Pull Requests are appreciated.


=head1 COPYRIGHT

Copyright 2022 Jeff Armstrong

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
