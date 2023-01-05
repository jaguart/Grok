# Iterable -> I can return an Iterator
#   Iterator -> I can pull-one

class C does Iterable {

    method rando ( --> Int ) {
        (1..100).pick
    }

    method iterator {
        my $max-calls = (10..20).pick;
        say 'max-calls: ', $max-calls;

        class :: does Iterator {
            has $!called = 0;
            has $.on     is required;
            method pull-one {
                $!called++ >  $max-calls ?? IterationEnd !! $.on.rando;
            }
        }.new(on => self)
    }
}

my $c = C.new;

say $c.flat for ^10

=begin pod

role StrLike { method Str { self.join } method gist { self.Str } }

class S is Array { method Str { self.join('') )} };

class SkippingArray is Array {
    # skip all undefined values while iterating
    method iterator {
        class :: does Iterator {
            has $.index is rw = 0;
            has $.array is required;
            method pull-one {
                $.index++ while !$.array.AT-POS($.index).defined && $.array.elems > $.index;
                $.array.elems > $.index ?? $.array.AT-POS($.index++) !! IterationEnd
            }
        }.new(array => self)
    }
}

my @a := SkippingArray.new;

@a.append: 1, Any, 3, Int, 5, Mu, 7;

for @a {  .say  }

dd @a;


=end pod

=begin pod

class DNA does Iterable {
    has $.chain;
    method new ($chain where { $chain ~~ /^^ <[ACGT]>+ $$ / } ) {
        self.bless( :$chain );
    }

    method iterator(DNA:D:) {
        $!chain.comb.rotor(3).iterator;
    }
}

my $a := DNA.new('GAATCC');
dd $_ for $a; # OUTPUT: «(G A A)␤(T C C)␤»

=end pod