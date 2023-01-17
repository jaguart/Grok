use v6;

# Move things from Skry into Grok
# Get Grok to make DOM
# Upgrade public interface to use this DOM

# Jeff 17-Jan-2023 need this or we won't be able to load
# modules relative to ./ as there won't be a CompUnit::Repository
# to handle the load.
use lib <.>;

use Grok :grok;
use Grok::DOM;
use Grok::Iota;

grok($_) for ( Grok::DOM, Grok::Iota );
_grok($_) for ( Grok::DOM, Grok::Iota );

sub _grok ( Mu \x ) {
    my $dom = Grok::DOM::Factory.create( x );
    $dom.dump(:plain);
    say '';
}
