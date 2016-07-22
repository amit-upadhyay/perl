#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

########################################

# Input: Sequence file, Clusters (accessions on each line)
# Output: Sequences for Cluster in separate files

########################################

# Read a sequence file and get accessions and sequence

my $seq_file = $ARGV[0];
my $cluster_file = $ARGV[1];


my %seq;
my %acc;
my $seqio = Bio::SeqIO->new(-file => "$seq_file");
while (my $seq = $seqio->next_seq) 
{
  my $head =  $seq->display_id;
  my @arr = split(/\|/,$head);
  
  $acc{$arr[0]} = $head;
  $seq{$arr[0]} = $seqio->seq;
}
close IN;

# for each line that is a list of proteins, get protein sequence for each cluster

open IN,"$cluster_file" or die $!;
my $ctr = 0;
while(my $ln=<IN>)
{
  $ctr++;
  chomp $ln;
  my @prot=split("~",$ln);
  my $clust= "Cluster$ctr";
   
  open OUT,">$clust\.fa" or die $!;
  foreach my $p(@prot)
  {
    my @arr = split(/\|/,$p);
    if(!$acc{$arr[0]})
    {
      print "Line $ln Protein $p\nSplit$arr[0]\n";
    }  
     print OUT ">$acc{$arr[0]}\n$seq{$arr[0]}\n";
  }
  close OUT;
}
close IN;



