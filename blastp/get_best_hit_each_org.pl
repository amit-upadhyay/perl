#!/usr/bin/perl -w
use strict;

my %org;

open IN,"7.headers" or die $!;
while(my $ln = <IN>)
{
  my @arr = split(/\|/,$ln);
  $org{$arr[0]} = $arr[2];
}
close IN;

# qseqid sseqid stitle qlen slen qstart qend sstart send evalue bitscore score length pident mismatch positive qcovs qcovhsp
open IN,"5.blast_all_against_all_out_besthsp" or die $!;
open OUT,">blast_all_against_all_out_besthsp_besteachorg" or die $!;

my %done;

while(my $ln = <IN>)
{
  my @arr = split("\t",$ln);

  my @q_arr = split(/\|/,$arr[0]);
  my $q = $q_arr[0];

  my @s_arr = split(/\|/,$arr[1]);
  my $s = $s_arr[0];

  if(!($done{"$q-$org{$s}"}))
  {
    print OUT $ln;
    $done{"$q-$org{$s}"} = 1;
  }


}



