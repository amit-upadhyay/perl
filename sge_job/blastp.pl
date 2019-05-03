#!/usr/bin/perl -w
use strict;

my @files = <seq/*>;
my $num_files = scalar(@files);
print "$num_files\n";
my %done;
my $max_jobs = 1000;
my $i=0;
while ($i < $num_files)
{
    my $curr_jobs = qx/qstat | wc -l/;
    my $diff = $max_jobs - $curr_jobs;
    print "$i $max_jobs $curr_jobs $diff\n";

    while ($diff > 0)
    {

           if($i >= $num_files)
           {
              exit;
           }

           if($done{$files[$i]})
           {
              qx/echo "REPEAT ERROR\n" >>progress/ ;
               exit;
           }

            #submit jobs
            #print "$files[$i]\n";
           
            $files[$i]=~/seq\/(.*)/;
            my $id = $1;
            print "-$id-\n";
            open OUT, ">blast_nr_Dec8_2015/jobs/$id\-job.sge" or die $!;
            print OUT "\#\$ -N $id\_blast\n\#\$ -q medium*\n\#\$ -cwd\n ncbi-blast-2.2.28+/bin/blastp -db NR_Dec8_2015/nr -query ../seq/$id -out ../results/$id\_out -evalue 1 -max_target_seqs 1 -outfmt \'6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs qlen slen staxids sscinames sskingdoms\'\nmv ../seq/$id ../done/\n";
        
           chdir("blast_nr_Dec8_2015/jobs/") or die $!;
           system ("qsub $id\-job.sge");
          
                   
            $done{$files[$i]} = 1;
            $i++;
            $diff--;
            
     }
     sleep(10);
 }











