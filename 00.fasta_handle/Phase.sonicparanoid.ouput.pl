#!/usr/bin/perl
use strict;
use warnings;

my $in=shift or die "perl $0 input_sonicparanoid_output\n";
my @id;

open (F,"$in")||die "$!";
while (<F>) {
    chomp;
    my @a=split(/\s+/,$_);
    if (/^group_id\s+group_size\s+/){
        print "group_id\t";
        for (my $i=4;$i<@a-1;$i=$i+2){
            print "$a[$i]\t";
        }
        print "\n";
    }else{
        my @line=("group_$a[0]");
        my $check=0;
        for (my $i=4;$i<@a-1;$i=$i+2){
            my @b=split(/,/,$a[$i]);
            my @outb;
            for my $b (@b){
	next if $b=~/\:0\.\d+$/;
	push @outb,$b;
            }
            $check++ if (scalar(@outb) != 1);
            last if $check > 0;
            $check++ if $outb[0] eq '*';
            last if $check > 0;
            push @line,$outb[0];
        }
        next if $check > 0;
        print join("\t",@line),"\n";
    }
}
close F;
