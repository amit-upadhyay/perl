#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;
open OUT,">$ARGV[0]\_nooverlap_positions" or die $!;
open OUT1,">$ARGV[0]\_nooverlap_arch" or die $!;

# Pfamscan output format
# 0           1           2         3          4         5         6       7     8    9       10        11       12        13   14   15        16      17        18      19        20      21    
# target_name target_acc target_len query_name query_acc query_len E-value score bias Num_hit Total_hit c-Evalue i-Evalue score bias hmm_start hmm_end ali_start ali_end env_start env_end unknown description

my %doms;
while(my $ln=<IN>)
{
  my @arr = split(" ",$ln);
  
  my $key = "$arr[0]~$arr[17]~$arr[18]~$arr[6]~$arr[12]";  
  $doms{$arr[3]}{$key} = 1;
}

foreach my $acc(keys %doms)
{
  foreach my $d1 (keys %{$doms{$acc}})
  {
    foreach my $d2 (keys %{$doms{$acc}})
    {
      if($d1 ne $d2 && $doms{$acc}{$d1} && $doms{$acc}{$d2})
      {
        my ($dom1,$s1,$e1,$seval1,$deval1) = split("~",$d1);        
        my ($dom2,$s2,$e2,$seval2,$deval2) = split("~",$d2);
        my $overlap = check_overlap($s1,$e1,$s2,$e2);
        if($overlap)
        {
          if($deval1 < $deval2)
          {
            delete($doms{$acc}{$d2});
          }
          else
          {
            delete($doms{$acc}{$d1});
          }
        }
      }
    }
  }
}

foreach my $acc(keys %doms)
{
  my $arch;
  my $str;
 
  foreach my $dom(keys %{$doms{$acc}})
  {
    $str.="$dom\t";
    my ($dom1,$s1,$e1,$seval1,$deval1) = split("~",$dom);
    $arch .= "$dom1~";
    print OUT "$acc\t$dom1\t$s1\t$e1\t$seval1\t$deval1\n";
 
  }
  print OUT1 "$acc\t$arch\t$str\n";  
}

sub check_overlap
{
  my ($s1,$e1,$s2,$e2) = @_;
  if($s1 >= $s2 && $s1 < $e2 && $e1 <=$e2)
  {
    return 1;
  }
  elsif ($s1 >= $s2 && $s1 < $e2 && $e1 > $e2)
  {
    return 1;
  }
  elsif($s2 >= $s1 && $s2 < $e1 && $e2 <=$e1)
  {
    return 1;
  }
  elsif($s2 >= $s1 && $s2 < $e1 && $e2 > $e1)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

