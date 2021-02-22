#!/usr/bin/perl
use strict;
use warnings;

## using samtools to statistic the mapping ratio. Yongzhi Yang. 2017/2/28 ##

my $inbam=shift or die "perl $0 input.bam.file\n";
my %count;
my @line=`samtools flagstat -@ 20 $inbam`;

for my $line (@line){
    chomp $line;
    if ($line=~/^(\d+)\s+\+\s+\d+\s+in\s+total\s+\(/){
        $count{total_paired} = $1;
    }
    if ($line=~/^(\d+)\s+\+\s+\d+\s+mapped\s+/){
        $count{total_maped}=$1;
    }
    if ($line=~/^(\d+)\s+\+\s+\d+\s+with\s+itself\s+and\s+mate\s+mapped/){
        $count{pair_end}=$1;
    }
    if ($line=~/^(\d+)\s+\+\s+\d+\s+singletons\s+\(\S+\s+\:\s+\S+\)/){
        $count{single_end}=$1;
    }
}

print "File\tTotal_pairs\tPair_end_mapped_reads\tPair_end_mapped_ratio\tSingle_end_mapped_reads\tSingle_end_mapped_ratio\tTotal_mapped_reads\tTotal_mapped_ratio\n";
print "$inbam\t$count{total_paired}\t$count{pair_end}\t",($count{pair_end}/$count{total_paired})*100,"\t$count{single_end}\t",($count{single_end}/$count{total_paired})*100,"\t$count{total_maped}\t",($count{total_maped}/$count{total_paired})*100,"\n";

