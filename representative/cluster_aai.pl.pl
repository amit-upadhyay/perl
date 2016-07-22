#!/usr/bin/perl -w
use strict;

use Graph::UnionFind;

my %count;
my %sum;
my %total;


# Get organism name for each sequence
my %org;

open IN,"10.headers" or die $!;
while(my $ln = <IN>)
{
  my @arr = split(/\|/,$ln);
  $org{$arr[0]} = $arr[2];
}
close IN;


# Read blast file

# qseqid sseqid stitle qlen slen qstart qend sstart send evalue bitscore score length pident mismatch positive qcovs qcovhsp

open IN,"7.blast_all_against_all_out_besthsp_besteachorg" or die $!;
while(my $ln = <IN>)
{
  
  my @arr = split("\t",$ln);

  my @q_arr = split(/\|/,$arr[0]);
  my $q = $q_arr[0];

  my @s_arr = split(/\|/,$arr[1]);
  my $s = $s_arr[0];

  #print "$q $org{$q} $s $org{$s} $arr[13] $arr[16]\n";

  my @o1arr = split("_",$org{$q});
  my @o2arr = split("_",$org{$s});
  
  #print " $o1arr[0]  $o2arr[0]\n";
  #exit;

  if($arr[13] >=98 && $o1arr[0] eq $o2arr[0])
  {
    $count{"$org{$q}~$org{$s}"}++;
    $sum{"$org{$q}~$org{$s}"} += $arr[13]; 
  }

  $total{$org{$q}}++;
  $total{$org{$s}}++;
  
}

print "Finished parsing blast\n";


my %avg;
foreach my $pair(keys %sum)
{
  $avg{$pair} = $sum{$pair}/$count{$pair};
}


my $uf100 = Graph::UnionFind->new;
my %v100;

foreach my $pair(keys %avg)
{
  my ($p1,$p2) = split("~",$pair);
 
  if($avg{"$p1~$p2"} >= 98 && $avg{"$p2~$p1"} >= 98 && $total{$p1} == $total{$p2} && $count{"$p1~$p2"} == $count{"$p2~$p1"})
  {
    ++$v100{$_} for $p1,$p2;
    $uf100->union($p1,$p2);
  }
}

print "Finished graph\n";


open OUT1, ">clusters_98_2" or die $!;

my %c100;
foreach my $v (keys %v100)
{
    my $b = $uf100->find($v);
    die "$0: no block for $v" unless defined $b;
    push @{ $c100{$b} }, $v;
}

say OUT1 join ",", @$_ for values %c100;
close OUT1;





























