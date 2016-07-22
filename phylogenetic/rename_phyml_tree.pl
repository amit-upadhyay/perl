my %headers;

open IN,"4.Synrrep_greengenes_nr99_rem_red_in_gg_synrep_aln.fa" or die $!;
while(my $ln = <IN>)
{
  chomp $ln;
  if($ln =~/>(.*)/)
  {
    $headers{$1} = 1;
  }
}
close IN;

open IN,"5.phyml_tree.txt" or die $!;
open OUT,">7.phyml_headers.txt" or die $!;

while(my $ln = <IN>)
{
  my @arr = split(",",$ln);
  foreach my $id(@arr)
  {
    $id =~/(.*?):(.*)/;
     
    my $pre = $1;
    my $suff = $2;
    
    $pre=~/(\(*)(\d+.*)/;
    my $branch = $1;
    my $x = $2;
    foreach my $h(keys %headers)
    {
      if(index($h,$x) != -1)
      {
        print OUT "$x\t$h\n";
        last;
      }
    }
  }
}