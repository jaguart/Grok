use v6.d;

use lib <lib>;
use Grok::Iota;

role Identified [$id] {has $.ident = $id }

# Curious about all the CORE:: things?

for CORE::.sort {
    say $_.key, ': ', my $i = Iota.new( $_.value );
    say '    ', $_ for $i.components.flat;
}