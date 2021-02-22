#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $inputfa=shift or die "perl $0 \$inputfa\n";
die "$inputfa isn't exists\n" if (! -e "$inputfa");
my $fa;
if ($inputfa=~/(gz|gzip)$/){
    open my $zcat,"zcat $inputfa|" or die "$!";
    $fa=Bio::SeqIO->new(-fh=> $zcat ,-format=>"fasta");
}else{
    $fa=Bio::SeqIO->new(-file=>$inputfa,-format=>'fasta');
}

while (my $seq=$fa->next_seq) {
    my $id=$seq->id;
    my $len=$seq->length;
    my $seq=$seq->seq;
    $seq=~s/N//ig;
    my $len2=length($seq);
    my $ATseq=$seq;
    my $GCseq=$seq;
    $ATseq=~s/[ATat]//g;
    $GCseq=~s/[GCgc]//g;
    my $atlen=$len-length($ATseq);
    my $gclen=$len-length($GCseq);
    my $gcper=$gclen/($atlen+$gclen);
    print "$id\t$len\t$len2\t$gcper\n";
}
