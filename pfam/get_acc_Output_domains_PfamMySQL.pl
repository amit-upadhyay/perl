#!/usr/bin/perl -w

use strict;

use DBI;
use DBD::mysql;

open OUT,">Output_acc" or die $!; # output html file




my %out=("HATPase_c",1,"HisKA",1,"HisKA_3",1,"HATPase_c_3",1,"HATPase_c_2",1,"HATPase_c_5",1,"HisKA_2",1,"HWE_HK",1,"DUF2328",1,"MCPsignal",1,"CYTH",1,"Arc",1,"Arg_repressor",1,"ArsD",1,"BetR",1,"ComK",1,"Cro",1,"Crp",1,"CtsR",1,"DeoR",1,"FUR",1,"FaeA",1,"Fe_dep_repr_C",1,"Fe_dep_repress",1,"FeoC",1,"GcrA",1,"GerE",1,"GntR",1,"HSF_DNA-bind",1,"HTH_1",1,"HTH_10",1,"HTH_11",1,"HTH_12",1,"HTH_13",1,"HTH_15",1,"HTH_16",1,"HTH_17",1,"HTH_18",1,"HTH_19",1,"HTH_20",1,"HTH_21",1,"HTH_22",1,"HTH_23",1,"HTH_24",1,"HTH_25",1,"HTH_26",1,"HTH_27",1,"HTH_28",1,"HTH_29",1,"HTH_3",1,"HTH_30",1,"HTH_31",1,"HTH_32",1,"HTH_33",1,"HTH_34",1,"HTH_35",1,"HTH_36",1,"HTH_37",1,"HTH_38",1,"HTH_39",1,"HTH_5",1,"HTH_6",1,"HTH_7",1,"HTH_8",1,"HTH_9",1,"HTH_AraC",1,"HTH_AsnC-type",1,"HTH_CodY",1,"HTH_Crp_2",1,"HTH_DeoR",1,"HTH_IclR",1,"HTH_Mga",1,"HTH_WhiA",1,"HTH_psq",1,"Homez",1,"HrcA_DNA-bdg",1,"HxlR",1,"LacI",1,"LexA_DNA_bind",1,"LytTR",1,"MarR",1,"MarR",1,"MerR",1,"MerR",1,"MerR",1,"MerR",1,"Mga",1,"Mor",1,"Myb_DNA-binding",1,"PaaX",1,"PadR",1,"Pencillinase_R",1,"Phage_CI_repr",1,"PuR_N",1,"Put_DNA-bind_N",1,"RHH_1",1,"RHH_2",1,"ROS_MUCR",1,"RepL",1,"Sigma70_r2",1,"Sigma70_r3",1,"Sigma70_r4",1,"Sigma70_r4_2",1,"TetR_N",1,"Trans_reg_C",1,"TrmB",1,"Trp_repressor",1,"UPF0122",1,"EAL",1,"GGDEF",1,"HD",1,"Guanylate_cyc",1,"Rrf2",1,"RseA_N",1,"SpoIIE",1,"Pkinase",1,"Pkinase_Tyr",1,"ANTAR",1,"CsrA",1);

my $platform = "mysql"; my $database1 = "pfam27"; my $host = "localhost"; my $port = "3306"; my $user = "amit";

my $dsn1 = "dbi:mysql:$database1:localhost:3306";
my $dbh1 = DBI->connect($dsn1, $user);


#my $q1 = "select t1.pfamseq_acc, t1.ncbi_taxid, t2.architecture from pfamseq as t1, architecture as t2 where t1.auto_architecture = t2.auto_architecture and \(t2.architecture LIKE \"%~PAS_%~%\" or t2.architecture LIKE \"%~PAS~%\"  or t2.architecture LIKE \"%MEKHLA%\" or t2.architecture LIKE \"%PocR%\" \)";

my $q1 = "select t1.pfamseq_acc, t1.ncbi_taxid, t2.architecture from pfamseq as t1, architecture as t2 where t1.auto_architecture = t2.auto_architecture and is_fragment=0";
my $sth1 = $dbh1->prepare($q1);
$sth1->execute();
while(my @res = $sth1->fetchrow_array())
{
  my @doms;
  if($res[2] =~ /~/)
  {
    @doms = split("~",$res[2]);
  }
  else
  {
    push @doms, $res[2];
  }

  foreach my $dom(@doms)
  {
    if($out{$dom})
    {
        print OUT "$res[0],$res[1],$res[2]\n";
        last;

    }

  }
}
$sth1->finish();














__END__

		#print "$acc $len\n";
		my @cache_str;
		for (my $i=0; $i<$len;$i++)
		{
		  $cache_str[$i] = "n";
		}
                print OUT "<td width=\"10\"><font face=\"Courier\">&nbsp$acc&nbsp</font></td><td>&nbsp</td>";
		my $cache_start=0;
		my $cache_end=0;
		my $q2 = "select start,end from pfam_domains where accession='$acc' and (family = 'Cache_1' or family = 'Cache_2' or family='Cache_3' or family = 'YkuI_C')";
		my $sth2 = $dbh2->prepare($q2);
		$sth2->execute();
		while(my @row1 = $sth2->fetchrow_array())
		{
		   $cache_start=$row1[0];
		   $cache_end = $row1[1];
		   for (my $i=$cache_start-1; $i<$cache_end;$i++)
		   {
			 $cache_str[$i] = "Cache";
		   KE}
		}
		$sth2->finish();
        #print "$cache_start,$cache_end\n";
						
		my $q3 = "select  start, end from tmhmm where accession='$acc'";
		my $sth3 = $dbh2->prepare($q3);
		$sth3->execute();
		while (my ($tm_start,$tm_end) = $sth3->fetchrow_array()) 
		{
		    for (my $i=$tm_start-1; $i<$tm_end;$i++)
		    {
			  $cache_str[$i] = "TM";
		    }
		
		}#if tm_start
		$sth3->finish;
		
		
		
		my $q4 = "select seq,secstr from psipred where accession='$acc'";
		my $sth4 = $dbh2->prepare($q4);
		$sth4->execute();
		my ($seq,$ss) = $sth4->fetchrow_array(); 
		$sth4->finish;

		print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp1&nbsp</font></td>\n";
			
		print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp",$len,"&nbsp</font></td>\n";

		if($seq)
		{
			my @arr = split("",$ss);

			foreach my $pos(@arr)
			{
				print OUT "$tag{\"$pos\"}\n";
			}

			
			print OUT "<tr style=\"height:0.5px;\">\n";
			print OUT "<td width=\"10\"><font face=\"Courier\">&nbspCache&nbsp</font></td><td>&nbsp</td>";
			print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp",$cache_start,"&nbsp</font></td>\n";
			print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp",$cache_end,"&nbsp</font></td>\n";

			for (my $i=0;$i<$len;$i++)
			{
				if ($cache_str[$i] eq 'n')
			    {
					print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp</font></td>\n";
				}
				elsif ($cache_str[$i] eq "Cache")
				{
					print OUT "<td><hr size=\"5\" color=\"black\"></td>\n";
				}
				elsif ($cache_str[$i] eq "TM")
				{
					print OUT "<td><hr size=\"5\" color=\"green\"></td>\n";
				}
			}# for newcache
			print OUT "</tr>";
			
			
		#	print OUT "<tr style=\"height:0.5px;\">\n";
	#		print OUT "<td width=\"10\"><font face=\"Courier\">&nbsp$acc&nbsp</font></td><td>&nbsp</td>";
	#		print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp",$cache_start,"&nbsp</font></td>\n";
	#		print OUT "<td width=\"4\"><font face=\"Courier\">&nbsp",$cache_end,"&nbsp</font></td>\n";
	#		my @arr1 = split("",$seq);

	#		foreach my $aa(@arr1)
	#		{
	#			print OUT "<td><font face=\"Courier\">$aa</font></td>\n";
	#		}
	#		print OUT "</tr>";




		}#seq_trunc  


	


		}
		else
		{
		print "Could not find length for $acc\n";
	}# if length
	$sth1->finish();
}# while
