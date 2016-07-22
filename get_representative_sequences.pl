#!/usr/bin/perl -w

use strict;
use Set::Scalar;
use Bio::SeqIO;

# Reads in fasta file and all-against-all blast and outputs a fasta file of representative sequences
# Headers in both input and blast file were of the format >Accession| Taxid|Species|LengthOfDomain|DomainArchitecture

my $infasta = $ARGV[0]; # Input fasta file
my $blastfile = $ARGV[1]; # Input all-against-all Blast file

my $et = $ARGV[2]; # Evalue thrshold
my $covt = $ARGV[3]; # coverage threshold

my %cluster;
my %proteins;

# Get all input fasta sequences

my %header;
my %seq;

my $inseq = Bio::SeqIO->new(-file   => "$infasta", -format => "fasta",);
while (my $seq = $inseq->next_seq)
{
	my $head = $seq->display_id;
	my @arr = split(/\|/,$head);
	$seq{$arr[0]} = $head;
	$header{$arr[0]} = $seq->seq;
	$cluster{$arr[0]} = 1;
}
print "Finished parsing sequences\n";

# Initialize the representative set by adding self to the list of represented

my %rep;
my $x = keys %cluster;
foreach my $p(keys %cluster)
{
  push @{$rep{$p}}, $p;
}

# Reading all-against-all blast file

open IN,"$blastfile" or die $!;
  
while(my $ln=<IN>)
{
	my @arr = split(" ",$ln);

	my @arr1 = split(/\|/,$arr[0]); # Separate accession from other header information separated by |
	my $qlen = $arr1[3];

	my @arr2 = split(/\|/,$arr[1]); # Separate accession from other header information separated by |
	my $slen = $arr2[3];

	$proteins{$arr1[0]} = 1;
	$proteins{$arr2[0]} = 1;

	if($arr1[0] ne $arr2[0])
	{
		my $qstart = $arr[6];
		my $qend = $arr[7];
		my $sstart = $arr[8];
		my $send = $arr[9];
		my $eval = $arr[10];
			
		my $qcov = (($qend - $qstart) + 1 ) / $qlen;
		my $scov = (($send - $sstart) + 1 ) / $slen;

		if($eval < $et && $qcov >= $covt && $scov >= $covt)
		{
			push @{$rep{$arr1[0]}}, $arr2[0]; # array containing set of representatives for each protein
		}
	}

}
close IN;
print "Finished reading blast file\n";

my %size_set;
foreach my $p (keys %rep)
{
	$size_set{$p} = scalar(@{$rep{$p}});  # hash containing num of reps for each protein
}
  
 
# Print out reps for each protein
$infasta =~/(.*).fa/;
my $prefix = $1;
open OUT1, ">$prefix\_reps" or die $!;
foreach my $p (sort {$size_set{$b} <=>$size_set{$a}} keys %size_set)
{
	print OUT1 "$p\t$size_set{$p}\t@{$rep{$p}}\n";
}
close OUT1;


# Find the representative set for all sequences

my @arr = sort {$size_set{$b} <=>$size_set{$a}} keys %size_set;  # Sort proteins based on number of reps

# $univ set contains reps for first protein (with largest number of reps). Used to monitor how many seq are being represented
my $univ = Set::Scalar->new(@{$rep{$arr[0]}});                   


my @reps; # Representatives
push @reps, $arr[0];

my $usize1 = $univ->size;
my $usize = keys %cluster; # This is the number of sequences that we want to represent

print "Total $usize  Biggest_rep: $usize1\n"; 


# Remove subsets and equal sets to reduce computation
foreach my $p1(sort {$size_set{$b} <=>$size_set{$a}} keys %size_set) # foreach protein
{ 
	my $s1 = Set::Scalar->new(@{$rep{$p1}});  # create a set from array of reps
	my $size1 = $s1->size;

	foreach my $p2 (sort {$size_set{$b} <=>$size_set{$a}} keys %size_set) # compare to every other protein
	{
		if($p1 ne $p2)
		{
			my $s2 = Set::Scalar->new(@{$rep{$p2}}); # create set from array of reps for second protein
			my $size2 = $s2->size;

			my $cmp = $s1->compare($s2);               # compare to remove redundancy
			
			if($cmp eq "proper subset")
			{
				if($size1 > $size2)
				{
					delete $rep{$p2};
					delete $size_set{$p2};
				}
				else
				{
					delete $rep{$p1};
					delete $size_set{$p1};
				}
			} # proper subset

			elsif($cmp eq 'equal')
			{
				delete $rep{$p2};
				delete $size_set{$p2};
			}
		} 
	} 
} 
print "Finished removing redundancy\n";


my $c = keys %size_set;
print "$c proteins have to be checked\n";

# Get representatives 
  
while($usize1 < $usize)
{
	my $old = $univ->size;
	$univ += find_max($univ,\%rep, \%size_set,\@reps);
	my $x = $univ->size; 
	if($x == $old)
	{
		print "Could not add any proteins. Finishing.\n";
		last;
	}

	my $k = keys %size_set;
	my $l = scalar(@reps);  
	print "Representatives $l Represented proteins $x  Total $usize Rem proteins $k\n";
	$usize1 = $univ->size;
}

open OUT2, ">$prefix\_rep\_$et\_$covt\.fa" or die $!;
foreach my $p (@reps)
{
	print OUT2 ">$header{$p}\n$seq{$p}\n";
}



# Function to find the protein that when added to the list of representatives results in largest represented set
sub find_max
{
	my ($univ, $rep, $ss, $reps) = @_;  
	# $univ - Set storing how many seqs are represented
	# $rep - hash containing arrays for represented seqs
	# $ss -> hash with size of representatives. Used to get keys
	# $reps -> Array stores representatives


	# Find the rep that results in largest increase in number of represented seqs
	my $max = 0;

	my $prot = ""; # Temp variable to store the protein with max rep
	my $old = 0;
	my $curr = 0;
	foreach my $p1(sort { $$ss{$b} <=> $$ss{$a} } keys %{$ss})
	{

		my $tmp_set = $univ->copy; # Check how many seqs represented after adding each rep

		my $s1 = Set::Scalar->new(@{$$rep{$p1}});

		my $s1size = $s1->size;
		$tmp_set = $tmp_set + $s1;
		$curr = $tmp_set->size;
		$old = $univ->size;

		if($curr > $max && $curr > $old)
		{
			$max = $curr;
			$prot = $p1;
		}
		elsif($curr == $old)
		{
			delete $$rep{$p1};
			delete $$ss{$p1};
		}

		
	}
	
	if($prot)
	{
		push @$reps, $prot;
		my $max_p = Set::Scalar->new(@{$$rep{$prot}});
		$univ = $univ + $max_p;
		delete $$rep{$prot};
		delete $$ss{$prot};
	}
	else
	{
		my %new;
		my @elements = $univ->elements;
		foreach my $r (@elements) 
		{
			$new{$r} = 1;
		}
		print "Could not find reps for \t";
		foreach my $r1(keys %cluster)
		{
			if(!$new{$r1}){print "$r1\t";}
		}
		print "\n";
	} 
	return $univ;
}