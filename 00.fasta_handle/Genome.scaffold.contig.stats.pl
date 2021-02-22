#!/usr/bin/env perl
use strict;
use warnings;
use Bio::SeqIO;

my $inputfa=shift or die "perl $0 inputfile\n";
my %h;
my $fa;
my ($all_site,$all_n,$all_gc,$contig_all)=(0,0,0,0);
if ($inputfa=~/(gz|gzip)/){
    open my $zcat,"zcat $inputfa|" or die "$!";
    $fa=Bio::SeqIO->new(-fh=> $zcat ,-format=>"fasta");
}else{
    $fa=Bio::SeqIO->new(-file=>$inputfa,-format=>'fasta');
}

while(my $seq=$fa->next_seq){
    my $id=$seq->id;
    my $seq=uc($seq->seq);
    my $len=length($seq);
    $all_site += $len;
    $h{scaffold}{$id}=$len;
    my $newseq=$seq;
    $newseq=~s/N//ig;
    $all_n += $len-length($newseq);
    $newseq=~s/[AT]//ig;
    $all_gc += $len - $all_n - length($newseq);
    my @seq=split(/N+/,$seq);
    for (my $i=0;$i<@seq;$i++){
        my $contiglen=length($seq[$i]);
        next if $contiglen < 100;
        $contig_all += $contiglen;
        my $k="$id-$i";
        $h{contig}{$k}=$contiglen;
    }
}

my %out;
## scaffold
my @chr=sort{$h{scaffold}{$b} <=> $h{scaffold}{$a}} keys %{$h{scaffold}};
print "## scaffold\n";
print "total    :\t",scalar(@chr),"(seqs), $all_site(bases), average length: ",$all_site/@chr,"\n";
print "longest  :\t$chr[0](name)\t$h{scaffold}{$chr[0]}(length)\n";
print "shortest :\t$chr[-1](name)\t$h{scaffold}{$chr[-1]}(length)\n";
print "N base   :\t$all_n\tper  :\t",$all_n/$all_site,"\n";
print "GC base  :\t$all_gc\tper  :\t",$all_gc/($all_site-$all_n),"\n";
for (my $i=0;$i<@chr;$i++){
    my $len=$h{scaffold}{$chr[$i]};
    $out{sum} += $len;
    if ($out{sum}/$all_site >= 0.5){
        if (! exists $out{N50}){
            print "N50  =\t$h{scaffold}{$chr[$i]}\tnumbers:\t",$i+1,"\n";
            $out{N50}=$chr[$i];
        }
    }
    if ($out{sum}/$all_site >= 0.9){
        if (! exists $out{N90}){
            print "N90  =\t$h{scaffold}{$chr[$i]}\tnumbers:\t",$i+1,"\n";
            $out{N90}=$chr[$i];
            last;
        }
    }
}

## contig
undef %out;
my @contig=sort{$h{contig}{$b} <=> $h{contig}{$a}} keys %{$h{contig}};
print "## contig\n";
print "total    :\t",scalar(@contig),"(seqs), $contig_all(bases), average length: ",$contig_all/@contig,"\n";
print "longest  :\t$contig[0](name)\t$h{contig}{$contig[0]}(length)\n";
print "shortest :\t$contig[-1](name)\t$h{contig}{$contig[-1]}length\n";
for (my $i=0;$i<@contig;$i++){
    my $len=$h{contig}{$contig[$i]};
    $out{sum} += $len;
    if ($out{sum}/$all_site >= 0.5){
        if (! exists $out{N50}){
            print "N50  =\t$h{contig}{$contig[$i]}\tnumbers:\t",$i+1,"\n";
            $out{N50}=$contig[$i];
        }
    }
    if ($out{sum}/$all_site >= 0.9){
        if (! exists $out{N90}){
            print "N90  =\t$h{contig}{$contig[$i]}\tnumbers:\t",$i+1,"\n";
            $out{N90}=$contig[$i];
            last;
        }
    }
}
