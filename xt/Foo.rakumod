=begin pod

A very simple Pod6 document

=begin code
my $name = 'John Doe';
say $name;
=end code

=end pod


#| I am Foo!
module Foo:ver<0.1.3>:api<1.2>:auth<zef:jaguart> {

  our Str constant θ = " " x 4; # Just a tab

  my $boo = 'wahey';

  #| Now serving. This declarator should be on $bar.
  our $bar is export = 42;

  sub baz is export {
    say "this is .baz()"
  }

  sub bar () {
    'bar';
  }

  role EvenMore:api<1>:ver<3.2.5>:auth<zef:jef> {
    has Str $!more-or-less;
    multi method even-more () { say 'even-more' }
  }

  role Clickable does EvenMore is rw {
    has $!clicked = False;
    multi method click-him () {
      }
    method click-me () {
      $!clicked = True;
    }
  }

  #| does writable notes
  role Notable does Clickable {
    has Str $.notes is rw = '';
    multi method notes() { "$!notes\n" };
    multi method notes( Str $note ) { $!notes ~= "$note\n" ~ θ };
  }

  #| Interactive clickable belly-buttons
  class Button {
    has $.pressing-need;
    method !gently () {
      say 'bait';
    }
    submethod tradie () {
      say 'bait';
    }
    method click () {
      say 'bait';
    }
    method ^mymetab (\obj ) {
      say 'mymetab';
    }

  }

  #| No-one really loves an innie.
  class Innie:api<0.5>
    is Button
    is rw
    does Notable
    {

    #| how sharp is your wit?
    our $adze is export = 4;

    has Str $.belly is readonly = 'inny' ;

    #| Should I make this private read-only - compiler warns?
    has Bool $!secret;

    #| This is where the magic happens
    has Str $.mage is required('magic needed');

    has Str $.sadly is DEPRECATED('joy may still be possible');

    #| descr returns a Str describing this instance of Innie
    method descr() {
      return "My belly is {$!belly}. " ~ self.notes;
    }

    method !privee () {
      say 'internal use only';
    }

    method ^mymeta ($obj) {
      say 'my meta method';
    }

    #| Often sweet and red - sometimes bitter and green.
    our sub apples is export {
      say 'apples';
    }

  }


}

class Bar:auth<zef:jaguart>:ver<1.0.3> {
  has Int $.um = 3;
  has Str $.sh = 'sh';
}

class Bob::Apple:auth<zef:jaguart>:ver<2.0.4> {
  has Int $.water = 3;
  has Str $.colour = 'red';
  multi method dunk () { ... }
}

