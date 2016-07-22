#!/usr/bin/perl -w

use strict;

use DBI;
use DBD::mysql;

my %tmhmm;
my %das;
my %phobius;

my %len;

my %num_tm;





my %acc_euk;
open EUK,"acc_euk" or die $!;
while(my $ln =<EUK>)
{
  chomp $ln;
  $acc_euk{$ln} = 1;

}


my @acc;

my %dom_arch;

my %all_tm;


open IN1,"TM_only_tmhmm_sort" or die $!;
while(my $ln =<IN1>)
{
  chomp $ln;
  my @arr = split(" ",$ln);

  my @arr1 = split(/\|/,$arr[0]);
  for(my $i=6;$i<scalar(@arr);$i+=3)
  {
    my $e = $arr[$i];
    my $s = $arr[$i-1];
    $tmhmm{$arr1[0]}{"$s-$e"}=1;
    $all_tm{$arr1[0]}{"$s-$e"} = 1;
  }
  push @acc,$arr1[0];


}

open IN2,"TM_only_das_sort" or die $!;
while(my $ln =<IN2>)
{

  my @arr = split(" ",$ln);
  my @arr1 = split(/\|/,$arr[0]);
  for(my $i=6;$i<scalar(@arr);$i+=3)
  {
    my $e = $arr[$i];
    my $s = $arr[$i-1];
    $das{$arr1[0]}{"$s-$e"}=1;
    $all_tm{$arr1[0]}{"$s-$e"} = 1;

  }
}
open IN3,"TM_only_phobius_sort" or die $!;
while(my $ln =<IN3>)
{
  my @arr = split(" ",$ln);
  my @arr1 = split(/\|/,$arr[0]);
  for(my $i=6;$i<scalar(@arr);$i+=3)
  {
    my $e = $arr[$i];
    my $s = $arr[$i-1];
    $phobius{$arr1[0]}{"$s-$e"}=1;
    $all_tm{$arr1[0]}{"$s-$e"} = 1;
  }
}


print "Finished parsing\n";

my %overlap;

foreach my $p (keys %all_tm)
{

  foreach my $tm(keys %{$all_tm{$p}})
  {
   
   
    my %tmp;
    my ($s,$e) = split("-",$tm);

    foreach my $tm1(keys %{$tmhmm{$p}})
    {
      #print "$tm1\n";
      #exit;
      my %tmp_pos;
      for(my $i=$s;$i<=$e;$i++) {$tmp{$i} = 1;$tmp_pos{$i}=1;}
      my %tmhmm_pos;
      my ($tmhmm_s,$tmhmm_e) = split("-",$tm1);
      for(my $i=$tmhmm_s;$i<=$tmhmm_e;$i++) {$tmhmm_pos{$i} = 1;$tmp_pos{$i}=1;}

      foreach my $pos(keys %tmp_pos)
      {
        if($tmp{$pos} && $tmhmm_pos{$pos})
        {
          $overlap{$p}{$tm}{"tmhmm"} = $tm1;
          last;
        }
      }
    }

    foreach my $tm1(keys %{$das{$p}})
    {
      my %tmp_pos;
      for(my $i=$s;$i<=$e;$i++) {$tmp{$i} = 1;$tmp_pos{$i}=1;}
      my %das_pos;
      my ($das_s,$das_e) = split("-",$tm1);
      for(my $i=$das_s;$i<=$das_e;$i++) {$das_pos{$i} = 1;$tmp_pos{$i}=1;}

      foreach my $pos(keys %tmp_pos)
      {
        if($tmp{$pos} && $das_pos{$pos})
        {
          $overlap{$p}{$tm}{"das"} = $tm1;
          last;
        }
      }
    }

    foreach my $tm1(keys %{$phobius{$p}})
    {
      my %tmp_pos;
      for(my $i=$s;$i<=$e;$i++) {$tmp{$i} = 1;$tmp_pos{$i}=1;}
      my %phobius_pos;
      my ($phobius_s,$phobius_e) = split("-",$tm1);
      for(my $i=$phobius_s;$i<=$phobius_e;$i++) {$phobius_pos{$i} = 1;$tmp_pos{$i}=1;}

      foreach my $pos(keys %tmp_pos)
      {
        if($tmp{$pos} && $phobius_pos{$pos})
        {
          $overlap{$p}{$tm}{"phobius"} = $tm1;
          last;
        }
      }
    }
  }
}

print "Finished overlapping regions\n";

my %consensus;

my %mtd3;
my %mtd2;
my %mtd1;

my $num3=0;
my $num_dp=0;
my $num_tp=0;
my $num_td=0;
my $num_t=0;
my $num_p=0;
my $num_d=0;


open OUT, ">Consensus" or die $!;
#open OUT1, ">Mtd1" or die $!;
#open OUT2, ">Mtd2" or die $!;
#open OUT3, ">Mtd3" or die $!;


foreach my $p (keys %overlap)
{

  foreach my $pos (keys %{$overlap{$p}})
  {

    if($overlap{$p}{$pos}{"tmhmm"}  &&  $overlap{$p}{$pos}{"das"} && $overlap{$p}{$pos}{"phobius"})
    {
      $consensus{$p}{$overlap{$p}{$pos}{"tmhmm"}} = "TMHMM-Das-Phobius\;".$overlap{$p}{$pos}{"tmhmm"}."\;".$overlap{$p}{$pos}{"das"}."\;".$overlap{$p}{$pos}{"phobius"};
      $mtd3{$p}{$overlap{$p}{$pos}{"tmhmm"}} = 1;
      $num3++;  
    }
    elsif($overlap{$p}{$pos}{"tmhmm"}  &&  $overlap{$p}{$pos}{"das"})
    {
      $consensus{$p}{$overlap{$p}{$pos}{"tmhmm"}} = "TMHMM-Das\;".$overlap{$p}{$pos}{tmhmm}."\;".$overlap{$p}{$pos}{das};
      $mtd2{$p}{$overlap{$p}{$pos}{"tmhmm"}} = 1;
      $num_td++;
    }
    elsif($overlap{$p}{$pos}{"tmhmm"}  &&  $overlap{$p}{$pos}{"phobius"})
    {
      $consensus{$p}{$overlap{$p}{$pos}{"tmhmm"}} = "TMHMM-Phobius\;".$overlap{$p}{$pos}{tmhmm}."\;".$overlap{$p}{$pos}{phobius};
      $mtd2{$p}{$overlap{$p}{$pos}{"tmhmm"}} = 1;
      $num_tp++;
    }
    elsif($overlap{$p}{$pos}{"phobius"}  &&  $overlap{$p}{$pos}{"das"})
    {
      $consensus{$p}{$overlap{$p}{$pos}{"phobius"}} = "Phobius-Das\;".$overlap{$p}{$pos}{phobius}."\;".$overlap{$p}{$pos}{das};
      $mtd2{$p}{$overlap{$p}{$pos}{"phobius"}} = 1;
      $num_dp++;
    }
    elsif($overlap{$p}{$pos}{"tmhmm"})
    {
      #print OUT1 "$p\tTMHMM\t$overlap{$p}{"tmhmm"}\n";
      $num_t++;
    }
    elsif($overlap{$p}{$pos}{"das"})
    {
       #print OUT1 "$p\tDas\t$overlap{$p}{"das"}\n";
      $num_d++;
    }
    elsif($overlap{$p}{$pos}{"phobius"})
    {
       #print OUT1 "$p\tPhobius\t$overlap{$p}{"phobius"}\n";
      $num_p++;
    }
    else
    {
      exit;
    }
  }
}


foreach my $p (keys %consensus)
{
  my $num_tm = keys %{$consensus{$p}};
  print OUT "$p\t$num_tm\_TM\t";
  foreach my $pos(keys %{$consensus{$p}})
  {
    my ($s,$e) = split("-",$pos);
    print OUT "$consensus{$p}{$pos}\t$s\t$e\t";
  
  }
  print OUT "\n";
}


print "All 3\t$num3\nTMHMM-DAS\t$num_td\nTMHMM-Phobius\t$num_tp\nPhobius-Das\t$num_dp\nTMHMM\t$num_t\nDas\t$num_d\nPhobius\t$num_p\n";


























