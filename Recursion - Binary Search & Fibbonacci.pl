# purpose : Lab #2
# author : delvin so

#/usr/bin/perl
use strict;
use warnings;


###################### Lab 2 : Part A ######################

#analyze the algorithm and rewrite the code as a subroutine called "recursiveBinarySearch"
#that accepts 2 parameters EXACTLY as:
#1. A sorted array by reference only, and
#2. A search key.

#Your subroutine will use recursion to look for the search key within the array.
#If the key is found, your subroutine will return the index in the array where the key
#was located or else return -1 if the key cannot be found.
#NOTE: If designed properly, your solution should work with both arrays of numbers
# as well as arrays of strings!

print "###################### Lab 2 : Part A ###################### \n \n";

# Given
my (@array1, @array2, $rv);
@array1 = (898, 0, 13, 27, -451, 9, 77, 123101, -2, 18);
@array1 = sort {$a <=> $b} @array1;
@array2 = qw(Apple IBM Unix Fibonacci perl bioInformatics Seneca);
@array2 = sort {$a cmp $b} @array2;

# test number search
$rv = recursiveBinarySearch(\@array1, 77);
print "binary search complete... Item ", ($rv== -1) ? "NOT " : "", "found at index: $rv \n\n";
 $rv = recursiveBinarySearch(\@array1, 999);
 print "binary search complete... Item ", ($rv == -1) ? "NOT " : "", "found at index: $rv \n\n";

# test string search
$rv = recursiveBinarySearch(\@array2, "unknown", $array2[0], $array2[-1]);
print "binary search complete... Item ", ($rv == -1) ? "NOT " : "", "found at index: $rv \n\n";
$rv = recursiveBinarySearch(\@array2, "Apple", $array2[0], $array2[-1]);
print "binary search complete... Item ", ($rv == -1) ? "NOT " : "", "found at index: $rv \n\n";


sub recursiveBinarySearch($$) {
  my ($array, $target)= @_;
  my $rv = 0;
  my $midIndex = int(scalar(@{$array})/2);
  #print "mid is $midIndex, array is @$array, rv is $rv \n";
  #<STDIN>;

  #return -1 if target doesn't match anything when length of scalar is 1 (ie. last possible term)
  return $rv = -1 if scalar(@$array) == 1 && $target != @$array[0] || scalar(@$array) == 1 && $target ne @$array[0] ;

  #if grep number then run lt/gt/eq else use the code for text
  if ($target =~ /^[0-9]/) {
    if ($target == $array->[$midIndex]) {
      return $rv = $midIndex;
    }
    if ($target < $array->[$midIndex]) { #if search is less than the value at the middle index..
       $rv = recursiveBinarySearch([@$array[0..($midIndex-1)]],$target);
    }
    elsif ($target > $array->[$midIndex]) { #if search is greater than the value at the middle index
      $rv = recursiveBinarySearch([@$array[$midIndex+1..$#$array]],$target);
      $rv == -1 ? return $rv : ($rv += $midIndex +1);

    }
    return $rv;
  }
else {    #check letters
    if ($target eq $array->[$midIndex]) {
      return $rv = $midIndex;
    }
    if ($target lt $array->[$midIndex]) { #if search is less than the value at the middle index..
       $rv = recursiveBinarySearch([@$array[0..($midIndex-1)]],$target);
    }
    elsif ($target gt $array->[$midIndex]) { #if search is greater than the value at the middle index..
      $rv = recursiveBinarySearch([@$array[$midIndex+1..$#$array]],$target);
      $rv == -1 ? return $rv : ($rv += $midIndex +1);
    }
  }
  return $rv;
}


###################### Lab 2 : Part B ######################

# Write the code for a Perl subroutine called: "recursiveFibonacci" that accepts an integer
# representing the n'th + 1 term in the sequence and computes and returns the value of the
# Fibonaci number at that position (n'th + 1 term).
# For example, given the Fibonacci sequence:
# 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233 ...
# 
# then, recursiveFibonacci(6) would return 8 (7th term in the series),
# recursiveFibonacci(0) would return 0 (1st term in the series), and
# recursiveFibonacci(3) would return 2 (4th term in the series)
# 

print "###################### Lab 2 : Part B ###################### \n \n";
my @sampleValues = (5, 6, 8, 10);
my $var;

foreach (@sampleValues) {
   print "recursiveFibonacci($_) = ";
   foreach $var (0..$_) {
      print recursiveFibonacci($var); #print output of fibonacci
      print ", " unless $var == $_;
   }
   print "\n";
}


sub recursiveFibonacci($);
sub recursiveFibonacci($) {
   my $num = shift;
   #print "my num is $num \n";

   if ($num <= 1) {
     return $num;
   }
   else {
     return recursiveFibonacci($num - 1) + recursiveFibonacci($num - 2);
   }
}
