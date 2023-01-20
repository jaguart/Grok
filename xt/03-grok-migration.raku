use v6.d+;

# Move things from Skry into Grok
# Get Grok to make DOM
# Upgrade public interface to use this DOM

# Jeff 17-Jan-2023 need this or we won't be able to load
# modules relative to ./ as there won't be a CompUnit::Repository
# to handle the load.


use Grok :grok;

use lib $?FILE.IO.parent;
use Foo;

grok( Foo, :ascend, :descend );