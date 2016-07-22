#!/usr/bin/perl -w
use strict;

use Bio::SeqIO;

my @files = <*.faa>;
foreach my $f(@files)
{
  my $org;
  if($f =~/(.*).genes.faa/)
  {
    $org = $1;
  }
  elsif($f =~/(.*).faa/)
  {
    $org = $1;
  }
  print "$f\n";
  my $out = "$org\.pep";
  open OUT,">$out";
  my $seqio = Bio::SeqIO->new(-file=>$f);
  while(my $seq = $seqio->next_seq)
  {
    my $head = $seq->display_id();
    my $s = $seq->seq;
    if(!($s eq "No sequence found" || $s eq "Nosequencefound"))
    {
      print OUT ">$head\n$s\n";
    }
  }


}
