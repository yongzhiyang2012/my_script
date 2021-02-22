

sub read_fasta_seq{
    use Bio::SeqIO;
    my ($tmpinput)=@_;
    my $tmpfa=Bio::SeqIO->new(-format=>"fasta",-file=>"$tmpinput");
    my %returnseq;
    while (my $obj=$tmpfa->next_seq) {
        my $tmpid=$obj->id;
        my $tmpseq=$obj->seq;
        $returnseq{$tmpid}=$tmpseq;
    }
    return %returnseq;
}
