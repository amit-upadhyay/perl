#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;
open OUT,">$ARGV[0]\_besthsp" or die $!;

my %done;

while(my $ln = <IN>)
{
  my @arr = split("\t",$ln);
  if(!($done{"$arr[0]-$arr[1]"}))
  {
    print OUT $ln;
    $done{"$arr[0]-$arr[1]"} = 1;
  }
}
