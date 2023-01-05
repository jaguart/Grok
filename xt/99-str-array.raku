role R { method Str { self.join }; method gist { self.Str } };
class S is Array does R { method xnew ( Str:D $str ) { self.bless( $str.comb ) } };
my $s = S.new("apples".comb); $s.say;
$s.tail .= succ; $s.say;
$s.splice(1,1); $s.say;
say $s.elems;