#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $cds=shift or die "give the cds fasta\n";
my $fa=Bio::SeqIO->new(-format=>"fasta",-file=>"$cds");
while (my $seq=$fa->next_seq) {
    my $id=$seq->id;
    my $seq=$seq->seq;
    my $pep=&TranslateDNASeq($seq);
    print ">$id\n$pep\n";
}

sub TranslateDNASeq(){
    use Bio::Seq;
    (my $dna)=@_;
    my $seqobj=Bio::Seq->new(-seq =>$dna, -alphabet =>'dna');
    return $seqobj->translate()->seq(); # if the codetable is mit of vertebrate you should replace translate() to translate (-codontable_id => 2); invertebrate mito 5
}
