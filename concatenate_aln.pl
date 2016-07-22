#!/usr/bin/perl
use strict;
use Bio::SeqIO;

# Concatenate alignment for individual COG files
# Input: Aligned files ( <COG>_aln.fa )
# Header for alignment files: >OrganismName_accession

my %seqs;

my @files = <*_aln.fa>;
foreach my $f(@files)
{
  my $inseq = Bio::SeqIO->new(-file   => "$f", -format => "fasta",);
  $f=~/(.*)_aln.fa/;
  my $cog = $1; 
  while (my $seq = $inseq->next_seq)
  {
    my $head = $seq->display_id;
    $head=~/(.*)_\d+/;
    my $org = $1;
    print "$org\n";
    my $s = $seq->seq;
    $seqs{$org}{$cog} = $s;
  }
}

open OUT,">Concatenated_aln.fa" or die $!;
foreach my $o (sort keys %seqs)
{
  print OUT ">$o\n";
  foreach my $c(sort keys %{$seqs{$o}})
  {
    print OUT "$seqs{$o}{$c}";
  }
  print OUT "\n";
}




