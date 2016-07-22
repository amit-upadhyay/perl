#!/usr/bin/perl -w
use strict;

my %rep;


open IN,"$ARGV[0]" or die $!;

open OUT1,">TM_phobius.txt" or die $!;

my %tm;

my $ctr =0;
my $curr='';

while(my $ln = <IN>)
{
  if($ln =~/ID\s+(\S+)/)
 {
      my $acc = $1;
      print OUT1 "\n$acc\t";
 }
  if($ln=~/TRANSMEM\s+(\d+)\s+(\d+)/)
  {
    print OUT1 "TM\t$1\t$2\t";
  } 
}
