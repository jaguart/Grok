use v6.d+;

use Grok::Wisp;

#| Grok::Iota wraps a Raku thing and provides introspection.
unit class Grok::Iota is export;

#| The Mu being introspected
has $.thing is built(:bind);

has Wisp $!wisp handles <whom what where origin detail why gist >;

submethod TWEAK {
    $!wisp = Wisp.new(:thing($!thing));
}

multi method new( Mu $thing is raw ) {
    return self.bless(:$thing);
}

method which        { $!thing.WHICH }

# MOPish things
method parents      { $!wisp.mop.parents.map({      Grok::Iota.new( $_<> ) })    }
method roles        { $!wisp.mop.roles.map({        Grok::Iota.new( $_<> ) })    }

method exports      { $!wisp.mop.exports.map({      Grok::Iota.new( $_<> ) })    }
method enums        { $!wisp.mop.enums.map({        Grok::Iota.new( $_<> ) })    }
method attributes   { $!wisp.mop.attributes.map({   Grok::Iota.new( $_<> ) })    }
method methods      { $!wisp.mop.methods.map({      Grok::Iota.new( $_<> ) })    }
method knows        { $!wisp.mop.knows.map({        Grok::Iota.new( $_<> ) })    }

#| Composition - what we are made of.
method composition  { self.parents, self.roles,                                  }

#| Components - what we encapsulate.
method components   { self.exports, self.enums, self.attributes, self.methods    }

=begin pod

Thinking of tree-like walking through an iota... feels interesting, but I'm not quite sure of the
use cases.

Maybe because I am thinking along the lines of a DOM for rendering in Text, HTML etc.

* Has a composition plane - parents, roles - antecedents
* Has a structural-contains plane - attributes, methods, exports, knows, enums
* Has a face - whom, what, where...

Might be viewed as an hourglass - aka a Hyperboloid of one sheet, where the iota is the throat, and
composition parts are above, structural-contains below


=end pod
