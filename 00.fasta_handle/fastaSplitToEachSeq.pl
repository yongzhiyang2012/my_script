#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

### Author: Yang Yongzhi; date: 2017-2-23; function: split a multi sequence fasta file into one sequence one file ###

my ($in,$dir)=@ARGV;
die "perl $0 inputfasta outputdir\n" if (!  $dir);

`mkdir $dir` if (! -e "$dir");

my $fa=Bio::SeqIO->new(-format=>"fasta",-file=>"$in");
while (my $seq=$fa->next_seq){
    my $id=$seq->id;
    my $seq=$seq->seq;
    open (O,">$dir/$id.fa");
    print O ">$id\n$seq\n";
    close O;
}
