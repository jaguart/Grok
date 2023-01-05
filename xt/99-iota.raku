use v6.d

use Grok::Iota;
use Grok::Wisp;

our %SEEN;

# Jeff 05-Jan-2023 playing with a new grok wrapper class
# thinking about DOM / trees of MOP descriptions.

#_grok( Grok::Iota.new( Routine ), :deeply  );
#_grok( my $a = 4 );
_grok( sub x ( --> Str ) { 'x'}, :deeply  );

#say Grok::Iota.new(:thing( my $b = 4 ));
#say Wisp.new(:thing( my $c = 4 ));

sub _grok ( Mu $thing is raw, :$deeply ) {



    my $iota = $thing ~~ Grok::Iota ?? $thing !! Grok::Iota.new( $thing );

    return if %SEEN{$iota.which}++;

    say $iota;
    say '  where: ', $iota.where;

    for <
        parents
        roles
        attributes
        methods
        exports
        knows
        enums
        > -> $method {

        if my @iotas = $iota."$method"() {
            say '  ', $method;
            say '    ', $_.gist(:notwhere($iota.where)) for @iotas;
        }
    }
    say '';

    if $deeply {
        _grok( $_ ) for $iota.parents;
        _grok( $_ ) for $iota.roles;
        _grok( $_ ) for $iota.exports;
        _grok( $_ ) for $iota.enums;
    }

}