
# purpose : given two sequences, s1 and s2, finds the best possible alignment (i.e. globally, the alignment between both sequences that 
# implies the fewest number of mutations) using the needleman-wunsch algorithm. The algorithm takes a larger problem, the sequence, and 
# divides it into a series of smaller problems with the solutions to those problems solving the larger problem.
# (https://en.wikipedia.org/wiki/Needleman–Wunsch_algorithm). 
# author : delvin so

#/usr/bin/perl

use strict;
use warnings;

my ($s1, $s2, $m, $n, @NWTable, $x, $y, $gapPenalty, $match, $misMatch);
$s1 = "ACTGATTCA";
$s2 = "ACGCATCA";
#parameters
$match = 1;
$misMatch = -1;
$gapPenalty = -2;
$m = length($s1);
$n = length($s2);
$NWTable[0][0] = 0;

for($x = 1; $x < $m + 1; $x++) {         # fill first row and first column (excluding 0,0) with gapPenalty
   $NWTable[0][$x] = $gapPenalty * $x;   # because boundaries would cause formula to generate default result
}
for($y = 1; $y < $n + 1; $y++) {
   $NWTable[$y][0] = $gapPenalty * $y;
}

#logic for assigning the value at an index of our 2D array
for ($y=1; $y < $n +1;$y++) {
    for($x=1; $x < $m +1;$x++) {
      $NWTable[$y][$x] = recurrenceRelation($y, $x); #(1,1), (1,2),(1,3), etc
    }
}

#subroutine for recurrence relation
sub recurrenceRelation($$) {
  my ($y,$x) = @_;
  my ($diag,$left,$above);
  $diag = ($NWTable[$y-1][$x-1] + match($y, $x));
  $left = ($NWTable[$y][$x-1] + $gapPenalty);
  $above = ($NWTable[$y-1][$x] + $gapPenalty);
  #pushing numbers into an array, sorting and returning the largest (final) value

  return max($diag,$left,$above);
  #my @numbers = ($diag,$left,$above); #subroutine to calculate
  #@numbers= sort {$a <=> $b} @numbers;
}

#subroutine for determining whether the nucleotides match as it scans along the other sequence
sub match($$) {
  my ($y,$x) = @_;
  substr($s1,$x-1,1) eq substr($s2,$y-1,1) ? return 1 : return -1;
}

#subroutine for determining the greatest of 3 numbers
sub max($$$){
  my ($diag, $left, $above) = @_;
  #print $diag,$left,$above, "\n";
  my @numbers = ($diag,$left,$above);
  @numbers= sort {$a <=> $b} @numbers;
  return $numbers[-1];
}

#printing the 2d array
for (my $row=0; $row < $n +1;$row++) {
  for(my $col = 0; $col < $m + 1; $col++) {
    print $NWTable[$row][$col], " ";
  }
  print "\n";
}
print $NWTable[$n][$m],"\n";

# Output
#
# 0 -2 -4 -6 -8 -10 -12 -14 -16 -18
# -2 1 -1 -3 -5 -7 -9 -11 -13 -15
# -4 -1 2 0 -2 -4 -6 -8 -10 -12
# -6 -3 0 1 1 -1 -3 -5 -7 -9
# -8 -5 -2 -1 0 0 -2 -4 -4 -6
# -10 -7 -4 -3 -2 1 -1 -3 -5 -3
# -12 -9 -6 -3 -4 -1 2 0 -2 -4
# -14 -11 -8 -5 -4 -3 0 1 1 -1
# -16 -13 -10 -7 -6 -3 -2 -1 0 2
# 2
