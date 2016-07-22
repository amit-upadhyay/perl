#!/usr/bin/perl -w

use strict;

use DBI;
use DBD::mysql;


open IN, "Output_acc" or die $!;

open OUT,">Output.fa" or die $!;
open OUT1,">Output.pfam" or die $!;

my $platform = "mysql"; my $database1 = "pfam27"; my $host = "localhost"; my $port = "3306"; my $user = "amit";

my $dsn1 = "dbi:mysql:$database1:localhost:3306";
my $dbh1 = DBI->connect($dsn1, $user);

while(my $ln =<IN>)
{
  chomp $ln;
  my ($acc,$taxid,$arch) = split(",",$ln);
  print "-$acc-\n";
  my $q1 = "select t1.length, t1.species, t1.taxonomy,t1.evidence,t1.description, t1.sequence from pfamseq as t1 where t1.pfamseq_acc = \"$acc\"";
  my $sth1 = $dbh1->prepare($q1);
  $sth1->execute();
  while(my ($length,$species,$tax,$evid,$desc,$seq) = $sth1->fetchrow_array())
  {
    my $head = ">$acc|$length|$species|$arch|$taxid|$tax|$evid|$desc";
    $head =~ s/\s/_/g;

        print OUT "$head\n$seq\n";
        print OUT1 "$head\t$seq\n";
  }

$sth1->finish();
}











