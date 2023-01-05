use v6;

unit module TestUtils;

#------------------------------------------------------------------------------
sub get-output-name( Mu $thing ) is export {
  my $ident = $thing ~~ Str:D ?? $thing !! $thing.^name;
  my $name = S/\.rakutest// given "{$*PROGRAM-NAME.IO.dirname}/check-{$*PROGRAM-NAME.IO.basename}-{$ident}.txt";
  S:g/ \: + /-/  given  $name;
}

#------------------------------------------------------------------------------
# addresses change: "something |U123456789) another" --> "something |U*********) another"
sub purified ( Str $output is copy --> Str ) is export {
  $output ~~ s:g/ \| (<alpha> ?) (\d +) \) /|$0$('*' x $1.chars))/;
  $output ~~ s:g/\r\n/\n/;  # Windows;
  $output;
}
