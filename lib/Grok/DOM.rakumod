use v6.d+;

use Kaolin::Node;
use Kaolin::Wisp :Wisp;

#unit module Grok;   #= prevent GLOBAL:: pollution


#------------------------------------------------------------------------------
#| Grok Document-Object-Model - aka Tree of Wisp, e.g. created by Grok::DOM::Factory.create($file)
class Grok::DOM is Kaolin::Node is export(:DOM) {

    # $!id and $!name in Kaolin::Node;

    #has $!type;
    has Mu      $!thing = Nil;
    has Wisp    $!wisp  = Nil;
    has         @!content;

    submethod TWEAK ( |arg ) {

        #dd arg;
        #say 'tweak0: ', self.name, ' ', ( $!thing, $!wisp, @!content ).map(*.so).Str.join(' ');

        # new with: Wisp or Thing or Name
        $!thing     ||= arg<thing><>                    if arg<thing>:exists;
        $!thing     ||= arg<wisp>.thing<>               if arg<wisp>:exists;

        $!wisp      ||= arg<wisp>                       if arg<wisp>:exists;
        $!wisp      ||= Wisp.new(:thing(arg<thing><>))  if arg<thing>:exists;

        self.name   ||= arg<name>                       if arg<name>:exists;

        self.name   ||= $!wisp.ident || $!wisp.whom || $!wisp.what if $!wisp.defined;

        #say 'tweak9: ', self.name, ' ', ( $!thing, $!wisp, @!content ).map(*.raku).Str.join(' ');
        #say ''

    }
    #method type { $!type }
    method thing { $!thing }
    method wisp { $!wisp }
    method content { @!content }

    multi method new ( Mu \thing, |args ) {
        self.bless(:thing(thing),|args)
    }

    multi method new ( Wisp $wisp, |args ) {
        self.bless(:wisp($wisp),|args)
    }

    method descr ( --> Str ) {

        #$!wisp.dump if $!wisp;

        my $prefix = ': ';
        return $prefix ~ @!content.join(' ') if @!content.elems;
        return '' if self.name and not $!wisp;
        $prefix ~ $!wisp.gist(:notwhom(self.name)); # TODO: make it :whom
    }

}
