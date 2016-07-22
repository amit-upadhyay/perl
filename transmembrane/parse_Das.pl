#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;

open OUT1,">TM_Das.txt" or die $!;

my %tm;

my $ctr =0;
my $curr='';

while(my $ln = <IN>)
{
  chomp $ln;
  if($ln =~/>(\S+)/)
  {
     my $acc = $1;
     print OUT1 "\n$acc\t";
     $curr = $acc;
  }
  if($ln=~/Warning! Non-TM protein!/)
  {
    $curr = '';
  } 
    #print "$ln";
  if($curr ne '' && $ln=~/@\s+\d+\s+(\S+)\s+core:\s+(\d+)\s+..\s+(\d+)/)
  {
     if($1 > 3)
     {
       print OUT1 "TM\t$2\t$3\t";

     }
  }
}
