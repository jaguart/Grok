use v6.d;

use Grok::Utils :is-core-class, :cleanup-mop-name, :is-type-class;

unit module Grok::Wisp;

#| A small wisp that provides .thing .gist .detail for info from the MOP.
class Base {

  has Mu    $.thing is required;
  has Str   $.ident;      #= external name / identity
  has Str   $.prefix;     #= prefix after .ident
  has Str   $.name;       #= internal name
  has Str   $.supertype;  #= parent-type description
  has Str   $.type;       #= type description
  has Str   $.subtype;    #= subtype description, e.g. Multi, Private
  has Str   $.gist;       #= main .gist content
  has Str   $.suffix;     #= suffix after gist
  has Str   $.extra;      #= extra for .detail
  has Str   $.why;        #= Declarator POD
  has Bool  $.debug;      #= Debug Wisp construction

  submethod TWEAK ( ) {

    $!subtype     //= '';
    $!extra       //= '';
    $!why         //= '';
    $!prefix      //= '';
    $!suffix      //= '';
    $!debug       //= False ;

    $!ident       //= '';                               # External name

    try $!name    //= $!thing.name;                     # Local name

    if not $!thing.DEFINITE {
      try $!name    //= cleanup-mop-name($!thing.^name);  # Class Name
    }
    $!name //= '';

    # Type and subtype
    try $!type    //= $!thing.type.^name;               # Attributes have .type
    $!type        //= $!thing.^name;                    # Class name

    # Type - blank or one-up the hierarchy?
    #$!type         = '' if $!type eq $!name;
    $!type          = $!thing.HOW.^name if $!type eq $!name;

    $!type          = cleanup-mop-name( $!type );

    $!subtype       //= cleanup-mop-name( $!thing.HOW.^name );
    $!subtype       = '' if $!subtype eq $!type;
    $!subtype       //= '';

    $!supertype       //= '';

    #say "i: $!ident n: $!name t: $!type s: $!subtype";

    my $short = $!name.split('::').tail;

    # Jeff 29-Dec-2022 NQPAttribute doesn't have a .gist
    $!gist    //= $!type eq 'Str' ?? $!thing.raku !! try $!thing.gist;  # Str -> .raku == with quotes
    $!gist    //= '';

    # Jeff 29-Dec-2022 .gist by default often contains details added elsewhere, so we sometimes ignore it
    $!gist      = '' if $!gist eq $!name;           #
    $!gist      = '' if $!gist eq "($!name)";       # (Any)
    $!gist      = '' if $!gist eq "($short)";       # (Innie)
    $!gist      = '' if $!gist eq "$!type $!name";  # bigint $!value - but not ~~ Attribute

    # Jeff 29-Dec-2022 this is a loooong builtin .gist
    $!gist      = 'Rakudo specific' if $!gist.contains("Rakudo-specific", :i);


  }

  #| gist --> :format.sprintf(name) prefix type gist why
  #
  # Any --> $name Any - $type Class
  # Mu --> $name Mu - $type Class


  # whom    - ident || name + signature
  # descr   - name if ident, subtype type supertype origin
  # detail  - further details
  # pod     - declarators


  method gist ( :$format="%s", :$detail=False, :$debug=$!debug --> Str ) {
    # final tweaks to remove duplicated values
    my $ident = $!ident || $!name;
    my $name  = $ident.contains($!name)   ?? '' !! $!name;
    my $gist  = $ident.contains($!gist)   ?? '' !! $!gist;
    my $type  = $ident.contains($!type)   ?? '' !! $!type;

    my $divider = $ident.chars + $!prefix.chars ?? '-' !! '';

    (
      $format.sprintf($ident),
      $!prefix,
      $divider,
      $name,
      $gist,
      $!subtype,    # Multi
      $type,        # Method
      $!supertype,  # Class
      $!suffix,
      $detail ?? $!extra !! '',
      ( $!why ?? ('#', $!why ) !! () ),
      ($debug ?? 'by ' ~ self.^name !! '' )
    )
    .map({ $debug ?? ($_, '‧') !! $_ })
    .grep( *.chars )
    .join(' ');
  }

  #| detail --> :format.sprintf(name) prefix type gist extra why
  method detail ( |arg --> Str ) {
    self.gist( :detail, |arg );
  }

}

#| Add POD Declarators to .gist/.detail
class Whyish is Base {
  multi method new (|args) {
    callwith(
      :why( try { args<thing>.?WHY } ?? args<thing>.?WHY.contents.join('?') !! '' ),
      |args,
    );
  }
}

#| .gist and .detail for custom Classes
class Classish is Whyish {
  multi method new(|args) {
    callwith(
      :gist(''),
      #:extra( ( "args<thing>.file.split(' ')[0], args<thing>.line", ).join(' ') ), <-- ditto
      |args
    );
  }
}

#| .gist..detail for Code like things.
class Codeish is Whyish {
  multi method new(|args) {

    my $subtype = args<subtype> // '';
    my $type    = args<thing>.^name.split('+')[0];

    my $sig     = try { args<thing>.signature.gist }  // '';
    my $of      = try { args<thing>.of.^name }        // '';
    my $suffix  = try { 'in ' ~ args<thing>.package.^name } // '';
    my $extra   = try { args<thing>.file.split(' ')[0] ~ ' ' ~ args<thing>.line } // '';

    # Jeff 23-Dec-2022 https://docs.raku.org/language/nativecall#Passing_and_returning_values
    # 'Note that the lack of a returns trait is used to indicate void return type'
    # but this yields --> Mu

    callwith(
      :prefix( (
          $sig,
          $sig.contains('--> ') ?? Empty
            !! $of eq 'Mu'      ?? Empty
            !! ('-->', $of),
        ).grep(*.chars).join(' ') ),
      :suffix( $suffix ),
      :extra( $extra ),
      |args,

    );
  }
}

#| .gist/.detail for Attributes.
#  Jeff 21-Dec-2022 - note there are NQP leakages that can fail here.
class Attrish is Whyish {
  multi method new(|args) {
    my $attribute = args<thing>;
    my @descr =
          ##$attribute.type.^name,
          $attribute.?DEPRECATED  ?? 'DEPRECATED: [' ~ $attribute.DEPRECATED ~ ']' !! '',
             $attribute.?required ~~ Str  ?? 'required: [' ~  $attribute.?required ~ ']'
          !! $attribute.?required         ?? 'required'
          !! '',
          $attribute.has_accessor ?? 'public'       !! 'private',
          $attribute.?rw          ?? 'read-write'   !! 'read-only',
          ;
    callwith(
      :suffix( @descr.grep(*.chars).join(' ') ),
      :gist( '' ), # suppress - duplicates name, type and suffix
      |args
    );
  }
}

#| Formatted .gist/.detail for MOP Inspectors
class Wisp is export {

  #| returns a specialised sub-class.
  method new (|args) {

    my $thing := args<thing>;
    my $ident = args<ident> // '';

    if $thing ~~ Pair and $thing.DEFINITE and !$ident {
      $thing := args<thing>.value;
      $ident  = args<thing>.key;
    }

    return Codeish.new(|args, :thing($thing), :ident($ident) )  if $thing ~~ Code;
    return Attrish.new(|args, :thing($thing), :ident($ident) )  if $thing ~~ Attribute;

    # Differentiate core-classes from custom-classes
    # <gfldex> m: say CORE::<Any> =:= Any;
    return Classish.new(|args, :thing($thing), :ident($ident) )
      if  is-type-class($thing) and not is-core-class($thing);

    # We assume that it might have POD Declarators
    return Whyish.new(|args, :thing($thing), :ident($ident) );
  }

}
