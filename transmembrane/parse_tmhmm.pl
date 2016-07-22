#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;

open OUT1,">TM.txt" or die $!;

my %tm;

my $ctr =0;
my $curr='';

while(my $ln = <IN>)
{
  if($ln =~/\#\s+(\S+)\s+Number of predicted TMHs\:\s+(\d+)/)
  {
    my $acc = $1;
    my $tm_num = $2;
    print OUT1 "\n$acc\t$tm_num\t";
    $tm{"$tm_num"}++;
    $curr = $acc;
  }
  if($ln=~/(\S+)\s*.*TMhelix\s*(\d+)\s*(\d+)/)
  {
    if($curr ne $1)
    {
      print "Check! No line for number of TM\n";
      exit;
    }
    else
    {
      print OUT1 "TM\t$2\t$3\t";
   }
  } 
}
