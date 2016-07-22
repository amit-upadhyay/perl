#!/usr/bin/perl -w
use strict;


# Get alignment file

if(!$ARGV[0])
{
  print "Enter location of parent alignments\n";
  exit;
}



# Get hash: acc => sequence
my %seqs;

open IN,"../Seq.fa" or die $!;
my $acc;
while(my $ln=<IN>)
{
  chomp $ln;
  if($ln=~/>(.*)/)
  {
    my @arr = split(/\|/,$1);
    $acc = $arr[0];   
    $ln=<IN>;
    chomp $ln;
    $seqs{$acc} = $ln; 
  }
}





# Get modified accessions using node file with annotations

my %header;


my %dom;
my %out;
my %phylum;
my %class;
my %lig;
my %pdb;

open IN2,"../node_attr" or die $!;

while(my $ln=<IN2>)
{
  my @arr = split("\t",$ln);
  my @arr1= split (/\|/,$arr[0]);
  #$dom{$arr1[0]} = $arr[6];
  #$out{$arr1[0]} = $arr[7]; 
  #$phylum{$arr1[0]} = $arr[9];
  #$class{$arr1[0]} = $arr[10];
  $header{$arr1[0]} = "$arr[0]|$arr[6]|$arr[7]|$arr[9]|$arr[10]";
}

system("mkdir tobeadded");
system("mkdir new_aln");
system("mkdir new_fasta");


# Get sequences for each cluster; Add them to parent alignment; Realign

my @files =<Cluster*>;
foreach my $f(@files)
{
  open IN3,"$f" or die $!;
  open OUT, ">tobeadded/$f\_add.fa" or die $!;
  while(my $ln=<IN3>)
  {
    chomp $ln;
    print OUT ">$header{$ln}\n$seqs{$ln}\n";
  }
  system ("cat $ARGV[0]/$f\.fa tobeadded/$f\_add.fa > new_fasta/$f\_new.fa");
  system ("linsi --reorder --thread 20 --legacygappenalty new_fasta/$f\_new.fa > new_aln/$f\_new_aln.fa");
  
}




