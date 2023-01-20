use v6.d+;

# Move things from Skry into Grok
# Get Grok to make DOM
# Upgrade public interface to use this DOM

# Jeff 17-Jan-2023 need this or we won't be able to load
# modules relative to ./ as there won't be a CompUnit::Repository
# to handle the load.
use lib <.>;

use Grok::DOM::Factory;

my $file = @*ARGS[0] if @*ARGS.elems;

die 'Please specify the name of a Raku module to load' unless $file;
die 'Not found: ' ~ $file unless $file.IO.e;


my $dom = Grok::DOM::Factory.create( $file.IO );
$dom.dump(:plain);
say '';
say $dom, ' from ', $file.Str;
say '';

