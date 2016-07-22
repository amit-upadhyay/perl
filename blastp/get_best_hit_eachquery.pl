#!/usr/bin/perl -w
use strict;

open IN, "$ARGV[0]" or die $!;
open OUT,">$ARGV[0]\_besthit" or die $!;

my %eval;

while(my $ln=<IN>)
{
	if(!($ln=~/#/))
	{
		my @arr = split(" ",$ln);

		if(!(defined $eval{$arr[0]}))
		{
			$eval{$arr[0]} = $arr[12];
			print OUT $ln;
		} 
	}
}

