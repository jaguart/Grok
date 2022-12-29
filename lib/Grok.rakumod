unit module Grok;

use Grok::Inspector;
use Grok::Utils :is-core-class;

sub _pad ( Str $str ) {  return $str.chars ?? ' ' ~ $str ~ ' ' !! ''; }

#our %SEEN;

#-------------------------------------------------------------------------------
#| Introspect a thing.
#| :deeply -> recurse into parents, roles etc;
#| :core -> include core classes.
sub grok (
    Mu $thing is raw,
    :$deeply  =False,
    :$core    =False,
    --> Grok::Inspector:D
  ) is export {

    our %SEEN;
    _grok( $thing, %SEEN, :$deeply, :$core);

}


#-------------------------------------------------------------------------------
#| internal - for recursion
sub _grok (
    Mu $thing is raw,
    %SEEN is raw,
    :$deeply,
    :$core,
    :$context = '',
    :$ident   = '',
    --> Grok::Inspector:D
  ) {

  return if %SEEN{$thing.WHICH}++;
  return if !$core and is-core-class($thing);


  my $layout = '%-20s: ';
  my $inspector = Grok::Inspector.new( $thing, :$ident );

  say ('--' ~ _pad($context || $inspector.descr ) ~ '-' x 80).substr(0,80);

  for <
    ident
    name
    raku
    type
    var
    var-name
    var-type
    var-of
    why
  > -> $method {
    #if $inspector."$method"() -> $descr {
    #  say $layout.sprintf($method), $descr // 'undef';
    #} else {
      say $layout.sprintf($method), $inspector."$method"();
    #}
  }


  for <
    exports
    #knows
    parents
    roles
    attributes
    methods
  > -> $method {
    next if $method.starts-with: '#';

    say $layout.sprintf($method), $_.gist for $inspector."$method"();

  }

  say '';

  if $deeply {
    for $inspector.exports -> $wisp {
      _grok( $wisp.thing, %SEEN, :ident($wisp.ident), :context( $inspector.descr ~ ' export'), :$deeply, :$core );
    }
    for $inspector.parents.map( *.thing ) -> $item {
      _grok( $item, %SEEN, :context( $inspector.descr ~ ' parent'), :$deeply, :$core );
    }
    for $inspector.roles.map( *.thing ) -> $item {
      _grok( $item, %SEEN, :context( $inspector.descr ~ ' role'), :$deeply, :$core );
    }
  }


  $inspector;

}


=begin pod

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
