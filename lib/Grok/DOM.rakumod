use v6.d+;

use Kaolin::Node;
use Kaolin::Wisp :Wisp;

use Grok :grok;

#unit module Grok;   #= prevent GLOBAL:: pollution


#------------------------------------------------------------------------------
#| Grok Document-Object-Model - aka Tree of Wisp, e.g. created by Grok::DOM::Factory.create($file)
class Grok::DOM is Kaolin::Node is export(:DOM) {


    # $!id and $!name in Kaolin::Node;

    has $!type;
    has $!thing = Nil;
    has $!wisp;
    has @!content;

    submethod TWEAK ( |args ) {

        if self.name and not args<thing>:exists {
            # this node is just a name
        }
        else {
            $!thing     ||= args<thing>;
            $!wisp      = Wisp.new(:thing($!thing<>));
            self.name   ||= $!wisp.whom || $!wisp.what;
        }

        #@!content.append( $!wisp.gist, ) unless @!content.elems;
        #say 'TWEAK ', $?CLASS.^name, ;#' --> ', args;

    }
    method type { $!type }
    method thing { $!thing }
    method wisp { $!wisp }
    method content { @!content }

    multi method new ( Mu \thing, |args ) {
        self.bless(:thing(thing),|args)
    }

    method descr ( --> Str ) {
        my $prefix = ': ';
        return $prefix ~ @!content.join(' ') if @!content.elems;
        return '' if self.name and not $!wisp;
        $prefix ~ $!wisp.gist(:notwhom)
    }

}


