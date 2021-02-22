use strict;
use warnings;

my %h;
my $in=shift or die "in";
#open (F,"HiC_contact_matrix.txt")||die"$!";
open (F,"$in")||die"$!";
while (<F>) {
    chomp;
    my @a=split(/\s+/,$_);
    $h{$a[0]}{$a[1]}=$a[2];
}
close F;
my @out=sort keys %h;
print "\t",join("\t",@out),"\n";
for my $k (@out){
    print "$k\t";
    for my $k2 (@out){
        my $v;
        if (exists $h{$k}{$k2}){
            $v=$h{$k}{$k2};
        }elsif(exists $h{$k2}{$k}){
            $v=$h{$k2}{$k};
        }else{
            $v=0;
        }
        print "$v\t";
    }
    print "\n";
}
