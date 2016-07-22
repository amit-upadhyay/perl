#!/usr/bin/perl
use strict;
my %map;
open IN,"gi_taxid_prot.dmp" or die $!;

while(my $ln = <IN>)
{
  $ln=~/(\d+)\s+(\d+)/;
  $map{$1} = $2;
}

open IN,"$ARGV[0]" or die $!;
open OUT,">$ARGV[0]\_taxid" or die $!;
while(my $ln = <IN>)
{
  $ln=~/(\S+)/;
  print OUT "$1\t$map{$1}\n";
}

close IN;
close OUT;


