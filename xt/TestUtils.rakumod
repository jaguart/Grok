use v6;

unit module TestUtils;

#------------------------------------------------------------------------------
sub get-output-name( Mu $thing ) is export {
  my $name = S/\.rakutest// given "./t/check-{$*PROGRAM-NAME.IO.basename}-{$thing.^name}.txt";
  S:g/ \: + /-/  given  $name;
}

#------------------------------------------------------------------------------
# addresses change: "something |U123456789) another" --> "something |U*********) another"
sub purified ( Str $output is copy --> Str ) is export {
  $output ~~ s:g/ \| (<alpha> ?) (\d +) \) /|$0$('*' x $1.chars))/;
  $output ~~ s:g/\r\n/\n/;  # Windows;
  $output;
}
