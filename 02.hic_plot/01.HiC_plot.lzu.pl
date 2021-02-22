#!/usr/bin/perl
use strict;
use warnings;

my ($bam,$agp,$chrlen,$window)=@ARGV;
die "perl $0 input_bam AGP chr_len_table window_size\n" if scalar(@ARGV) <4;

my %len=&read_chrlen($chrlen);
my %agp=&read_agp($agp);
my %contact;
if ($bam=~/bam$/){
    open (F,"samtools view $bam|")||die"$!";
}else{
    open (F,"$bam")||die"$!";
}
while (<F>) {
    chomp;
    next if /^\@/;
    my $l1=$_;chomp $l1;
    my $l2=<F>;chomp $l2;
    my @l1=split(/\s+/,$l1);
    my @l2=split(/\s+/,$l2);
    die "wrong reads without paried\n" if (($l1[0] ne $l2[0]) || ($l1[2] eq "*") || ($l2[2] eq "*"));
    my ($ctg1,$ctg1pos,$ctg2,$ctg2pos)=($l1[2],$l1[3],$l2[2],$l2[3]);
    my ($chr1,$chr1pos)=&get_chr_pos($ctg1,$ctg1pos);
    my ($chr2,$chr2pos)=&get_chr_pos($ctg2,$ctg2pos);
    my $bin1=int($chr1pos / $window);
    my $bin2=int($chr2pos / $window);
    my $bin1k="$chr1"."_bin$bin1";
    my $bin2k="$chr2"."_bin$bin2";
    $contact{$bin1k}{$bin2k}++;
}
close F;
open (O,">HiC_contact_matrix.txt")||die"$!";
my @chrk=sort keys %len;
for my $chrk (@chrk){
    my $chrlen=$len{$chrk};
    my $chrbinnum=int($chrlen/$window);
    for (my $i=0;$i<=$chrbinnum;$i++){
        my $outbin1="$chrk"."_bin$i";
        $chrk=~/maozhen.counts_GATC.11g(\d+)/;
        my $fixnum1=$1 + 10000;
        my $fixnum2=$i+1000000;
        my $outbinaaa="chr$fixnum1"."B$fixnum2";
        for my $chrk2 (@chrk){
            my $chrlen2=$len{$chrk};
            my $chrbinnum2=int($chrlen2/$window);
            for (my $j=0;$j<=$chrbinnum2;$j++){
	my $outbin2="$chrk2"."_bin$j";
	$chrk2=~/maozhen.counts_GATC.11g(\d+)/;
	my $fixnum3=$1 + 10000;
	my $fixnum4=$j+1000000;
	my $outbinbbb="chr$fixnum3"."B$fixnum4";
	my $value;
	if (exists $contact{$outbin1}{$outbin2}){
	    $value=$contact{$outbin1}{$outbin2};
	    $value=log($value)/log(2);
	}elsif(exists $contact{$outbin2}{$outbin1}){
	    $value=$contact{$outbin2}{$outbin1};
	    $value=log($value)/log(2);
	}else{
	    $value=0;
	}
	print O "$outbinaaa\t$outbinbbb\t$value\n";
	print O "$outbinbbb\t$outbinaaa\t$value\n" if $outbinbbb ne $outbinbbb;
            }
        }
    }
}
close O;

sub read_chrlen{
    my %r;
    my ($tin)=@_;
    open (TF,"$tin");
    while (<TF>) {
        chomp;
        my @ta=split(/\s+/,$_);
        $r{$ta[0]}=$ta[1];
    }
    close TF;
    return %r;
}
sub get_chr_pos{
    my ($tmpname,$tmppos)=@_;
    my ($outnmae,$outpos);
    for my $k (sort keys %{$agp{$tmpname}}){
        my ($kend,$kstrand,$kchr,$kchrs,$kchre)=($agp{$tmpname}{$k}{end},$agp{$tmpname}{$k}{strand},$agp{$tmpname}{$k}{chr},$agp{$tmpname}{$k}{chrs},$agp{$tmpname}{$k}{chre});
        if (($k <= $tmppos) && ($tmppos <= $kend)){
            $outnmae=$kchr;
            if ($kstrand eq "-"){
	$outpos=$kchre-($tmppos-$k);
            }elsif ($kstrand eq "+") {
	$outpos=$tmppos-$k+$kchrs;
            }else{
	die "$tmpname\t$k\n";
            }
            last;
        }
    }
    return ($outnmae,$outpos);
}
sub read_agp{
    my %r;
    my ($tin)=@_;
    open (TF,"$tin")||die"$!";
    while (<TF>) {
        chomp;
        my @ta=split(/\s+/,$_);
        next unless $ta[4] eq "W";
        $r{$ta[5]}{$ta[6]}{end}=$ta[7];
        $r{$ta[5]}{$ta[6]}{chr}=$ta[0];
        $r{$ta[5]}{$ta[6]}{strand}=$ta[8];
        $r{$ta[5]}{$ta[6]}{chrs}=$ta[1];
        $r{$ta[5]}{$ta[6]}{chre}=$ta[2];
    }
    close TF;
    return %r;
}
