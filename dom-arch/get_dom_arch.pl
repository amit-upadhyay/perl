#!/usr/bin/perl -w

use strict;

use DBI;
use DBD::mysql;

my %tmhmm;
my %das;
my %phobius;
my %pfam_pos;
my %len;

my %num_tm;

my %consensus;
open ALL,"Consensus" or die $!;
while(my $ln =<ALL>)
{
  my @arr = split(" ",$ln);
  for(my $i=4;$i<scalar(@arr);$i+=3)
  {
    my $e = $arr[$i];
    my $s = $arr[$i-1];
    $consensus{$arr[0]}{"$s-$e"}=1;
    $num_tm{$arr[0]} = $arr[1];
  }
}

my %acc_euk;
open EUK,"acc_euk" or die $!;
while(my $ln =<EUK>)
{
  chomp $ln;
  $acc_euk{$ln} = 1;

}

my %dom_arch;

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
    $dom_arch{$arr1[0]} = $arr1[3]; 
    $len{$arr1[0]} = $arr1[1];
  }
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
    $dom_arch{$arr1[0]} = $arr1[3];
    $len{$arr1[0]} = $arr1[1];

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
    $dom_arch{$arr1[0]} = $arr1[3];
    $len{$arr1[0]} = $arr1[1];

  }
}


my $platform = "mysql"; my $database1 = "pfam27";my $database2 ="Cache27"; my $host = "localhost"; my $port = "3306"; my $user = "amit";

my $dsn1 = "dbi:mysql:$database1:localhost:3306";
my $dbh1 = DBI->connect($dsn1, $user);

my $dsn2 = "dbi:mysql:$database2:localhost:3306";
my $dbh2 = DBI->connect($dsn2, $user);




foreach my $p (keys %consensus)
{
  #if($num_tm{$p}==0) {next;}
  system("mkdir Dom_arch/$num_tm{$p}");
  open OUT,">>Dom_arch/$num_tm{$p}/$num_tm{$p}\_out" or die $!;
  print "\n\nProtein $p\n";
  my $arch="";
  my $cov="";
  my @domains = split("~",$dom_arch{$p});
  my $col="";
  my $dom_pos = "";
  my $old_start=0;
  my $old_dom="TEST"; 

  foreach my $d (@domains)
  {
    if($d eq $old_dom) {$old_start +=1;}
    my $q2 = "select seq_start,seq_end from pfamA as A, pfamA_reg_full_significant as B, pfamseq as C where A.auto_pfamA = B.auto_pfamA and B.auto_pfamseq = C.auto_pfamseq and A.pfamA_id='$d' and C.pfamseq_acc='$p' and B.seq_start >= $old_start order by seq_start";
    #print "$q2\n";

    my $sth2 = $dbh1->prepare($q2);
    $sth2->execute();
    my @row1 = $sth2->fetchrow_array();
    if(@row1)
    {
    $dom_pos.="$row1[0]-$row1[1]\;";
    #print "$d $dom_pos $old_start\n";
    $old_start = $row1[0];
    $old_dom = $d;      
    $col.="Pfam27.0\;";
    $arch.="$d\;";
    $cov.="x\;";
    }
    else
    {

#     $q2 = "select seq_start,seq_end from pfamA as A, pfamA_reg_full_significant as B, pfamseq as C where A.auto_pfamA = B.auto_pfamA and B.auto_pfamseq = C.auto_pfamseq and A.pfamA_id='$d' and C.pfamseq_acc='$p' and B.seq_start >= $old_start order by seq_start";
    #print "$q2\n";

#     $sth2 = $dbh1->prepare($q2);
 #   $sth2->execute();
  #  my @row1 = $sth2->fetchrow_array();
   # if(@row1)
    #{
   #   $dom_pos.="$row1[0]-$row1[1]\;";
      #print "$d $dom_pos $old_start\n";
   #   $old_start = $row1[0];
   #   $col.="Pfam27.0\;";
   #   $arch.="$d\;";
   #   $cov.="x\;";
   # }

    # else
    # {
      print "Cannot find record for $p $d $old_start\n";
      exit;

    # }
    }
  }
  
  my $con_pos;
  foreach my $posn (keys %{$consensus{$p}})
  {
    $con_pos.="\'$posn\',";
  }
  my $con_pos2;
  if($con_pos)
  {
    $con_pos2 = substr $con_pos,0,-1;
  }
  else
  {
    $con_pos2 = "\'\'";
  }


  foreach my $posn (keys %{$tmhmm{$p}})
  {
      $dom_pos.="$posn\;";
      $col .="pdb\;";
      $cov.="x\;";
      $arch .= "P\;";
  }

  foreach my $posn (keys %{$phobius{$p}})
  {
      $dom_pos.="$posn\;";
      $col .="cdd\;";
      $cov.="x\;";
      $arch .= "P\;";
  }  
  foreach my $posn (keys %{$das{$p}})
  {
      $dom_pos.="$posn\;";
      $col .="pfam\;";
       $cov.="x\;";
      $arch .= "D\;";
  }

  
  print OUT "<tr><td>$p</td><td width=\"$len{$p}\"><script>drawall(\'$p\',$len{$p},[$con_pos2],\'[]\',\'[]\',\'$arch\',\'$dom_pos\',\'$cov\',\'$col\',\'$cov\')</script></td></tr>\n";
    
}








