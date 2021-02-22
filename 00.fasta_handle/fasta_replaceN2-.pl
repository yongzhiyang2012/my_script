use strict;
use warnings;

my $in=shift or die "perl $0 input\n";

if ($in=~/(fa|fas|fa.gz|fa.gzip|fas.gz|fas.gzip)$/){
    &read_fas($in);
}else{
    &read_common_text($in);
}

sub read_fas{
    my ($inputfa)=@_;
    use Bio::SeqIO;
    my $fa;
    if ($inputfa=~/(gz|gzip)/){
        open my $zcat,"zcat $inputfa|" or die "$!";
        $fa=Bio::SeqIO->new(-fh=> $zcat ,-format=>"fasta");
    }else{
        $fa=Bio::SeqIO->new(-file=>$inputfa,-format=>'fasta');
    }
    while(my $seq=$fa->next_seq){
        my $id=$seq->id;
        my $seq=$seq->seq;
        $seq=~s/n/-/ig;
        print ">$id\n$seq\n";
    }
}
sub read_common_text{
    my ($in)=@_;
    open (F,"$in")||die"$!";
    while (<F>) {
        chomp;
        if (/^(\S+\s+)(.*)$/){
            my ($first,$end)=($1,$2);
            $end=~s/n/-/ig;
            print "$first$end\n";
        }else{
            s/n/-/ig;
            print "$_\n";
        }
    }
}
