#!/usr/bin/perl
my @files=<*.fa>;

foreach my $f(@files)
{
  $f=~/(.*).fa/;
  my $name = $1;
  system ("linsi --thread 8 $f >$name\_aln.fa");
 
}

