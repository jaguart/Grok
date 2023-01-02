use v6.d+;

unit module Grok::Utils;

#sub is-type-class ( Mu $o --> Bool ) is export(:is-type-class) {
#  return False if $o.DEFINITE;
#  return True if $o.HOW.^name.contains('ClassHOW');
#  return False;
#}

sub is-core-class ( Mu $o --> Bool ) is export(:is-core-class) {

  my $cwn = cleanup-which-name($o);
  #say 'cwn: ', $cwn;

  # Jeff 01-Jan-2023 Grammar has a .WHICH.Str of Str|NQPMatchRole

  return True if $cwn.starts-with('NQP');
  return True if $cwn.starts-with('Per;6::');

  # Jeff 01-Jan-2023 Grammar and Match have an issue with this
  return True if CORE::{$cwn}:exists;

  #my $name = $o.^name.split(/ \+ | \{ | \| /)[0]; say 'name: ', $name;

  #return True if CORE::{$cwn}.WHICH === $o.WHICH;


  #say 'name: ', $name;
  #say '.^name: ', $o.^name;
  #say '.WHICH: ', $o.WHICH;
  #say 'cwn: ', cleanup-which-name($o);

  #return True if CORE::{$name}.WHICH === CORE::{cleanup-which-name($o)}.WHICH;

 #  say "not-core: name: $name -> ", CORE::{$name}.WHICH, " vs ", cleanup-which-name($o);

  #return True if CORE::{$name}.WHICH and $o.^name.contains('['); #? Type qualification?
  #say 'not-core ', CORE::{$name}.WHICH, ' vs ', $o.WHICH, ' ', $name, ' ', $o.^name;

  #say "not-core cwn: ", $cwn;

  return False;
}

sub cleanup-mop-name ( Str $name is copy --> Str ) is export(:cleanup-mop-name) {


  $name  = $name.split('+')[0];
  $name  .=subst('Perl6::Metamodel::', '');
  $name  .=subst('ClassHOW', 'Class');
  $name  .=chop(3) if $name.ends-with('HOW');
  $name   = 'Role' if $name eq 'ParametricRoleGroup';
  return $name;
}

sub cleanup-which-name ( Mu $o --> Str ) is export(:cleanup-which-name) {

  #dd $o;

  my $name = $o ~~ Str:D ?? $o.Str !! $o.?WHICH.gist // '';
  return '' if $name eq 'Nil';  # e.g. KnowHOW
  $name = $name.subst('Grok::Moppet::Subtyped[Str]','');
  $name = $name.subst('Grok::Moppet::Identified[Str]','');
  $name = $name.subst('+{,}|','|');

  # e.g. Method+{<anon|1>}+{Grok::Moppet::Identified[Str],Grok::Moppet::Subtyped[Str]}
  return $name.split(/ \| U ? <digit> + $ /)[0];
}

#| Pad left and right, but only for content, otherwise empty string.
#| :l(' ') - left padding
#| :r(' ') - right padding
sub pad-lr ( Str $what, :$l=' ', :$r=' ' ) is export(:pad-lr) {
  $what.so ?? $l ~ $what ~ $r !! ''
}

#| Header line with embedded description, fixed width
#| $description
#| :w(80) - width
sub header-line ( Str $descr = '', :$w=80 ) is export(:header-line) {
  ('--' ~ pad-lr($descr) ~ '-' x 78).substr(0,$w)
}

