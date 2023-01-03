use v6;

unit module TestUtils;

#------------------------------------------------------------------------------
sub get-output-name( Mu $thing ) is export {
  my $name = S/\.rakutest// given "./t/check-{$*PROGRAM-NAME.IO.basename}-{$thing.^name}.txt";
  S:g/ \: + /-/  given  $name;
}

#------------------------------------------------------------------------------
# addresses change: "something |U123456789) another" --> "something |U*********) another"
sub purified ( Str $output --> Str ) is export {
  S:g/ \| (<alpha> ?) (\d +) \) /|$0$('*' x $1.chars))/
    given $output
}
