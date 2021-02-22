#!/usr/bin/perl
use strict;
use warnings;

my ($in,$chr,$start,$end)=@ARGV;
die "in chr start end\nresult: chr start end (1-based): ATCG\n" if (! $end);

use Bio::SeqIO;
my $fa=Bio::SeqIO->new(-format=>"fasta",-file=>"$in");
while (my $seq=$fa->next_seq) {
    my $id=$seq->id;
    my $seq=$seq->seq;
    if ($id eq "$chr"){
        my $newseq=substr($seq,$start-1,$end-$start+1);
        print "$chr $start $end (1-based): $newseq\n";
        last;
    }
}
