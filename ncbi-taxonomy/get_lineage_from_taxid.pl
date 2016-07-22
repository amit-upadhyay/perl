#!/usr/bin/perl  
use strict;

my %names;
open IN,"names.dmp" or die $!;
while(my $ln = <IN>)
{
  if($ln=~/scientific name/)
  {
  $ln=~/(\d+)\s+\|\s+(\w+.*?)\s+\|/;
  #print "$1 $2\n";
  $names{$1} = $2;
  }
}
close IN;

my %parent;
my %rank;
open IN,"nodes.dmp" or die $!;
while(my $ln = <IN>)
{
  $ln=~/(\d+)\s+\|\s+(\d+)\s+\|\s+(\w.*?)\s+\|.*/;
  #print "$1 $2 $3\n";
  $parent{$1} = $2;
  $rank{$1} = $3;
}
close IN;

open IN,"$ARGV[0]" or die $!;
open OUT,">$ARGV[0]\_taxonomy" or die $!;

while(my $ln = <IN>)
{
  chomp $ln;
  my @arr = split(" ",$ln);
  my $tax = get_tax("$arr[1]");
  print OUT "$arr[0]\t$arr[1]\t$tax\n";

}

sub get_tax
{
  my ($taxid) = @_;
  #print "$taxid\n"; 
  my $lineage = "$rank{$taxid}:$names{$taxid}";
  while($parent{$taxid})
  {
    $taxid = $parent{$taxid};
    if($names{$taxid} eq "root") {last;}
    $lineage = "$rank{$taxid}:$names{$taxid}~$lineage";
    #print "$taxid $lineage\n\n";
  }
  return $lineage;

}
