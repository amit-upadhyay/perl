#!/usr/bin/perl

use Bio::SeqIO;

# Read file with accessions and get corresponding sequences from fasta file
my $acc_file = $ARGV[0];
my $seq_file = $ARGV[1];

my %acc;
open IN,"$acc_file" or die $!;
while(my $ln = <IN>)
{
  chomp $ln;
   $acc{$ln} = 1;
}

open OUT,">$ARGV[0]\.fa" or die $!;
my $seqio = Bio::SeqIO->new(-file => "$seq_file");
while (my $seq = $seqio->next_seq) 
{
  my $acc =  $seq->display_id;
  my @arr = split(/\|/,$acc);
  if($acc{$arr[0]})
  {
    print OUT ">$acc\n";
    print OUT $seq->seq,"\n";
  }
}
