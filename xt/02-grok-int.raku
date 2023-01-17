use v6;

use Grok::DOM;

my $dom = Grok::DOM::Factory.create( my $a = 4 );
$dom.dump(:plain);
say '';
say $dom;
say '';

