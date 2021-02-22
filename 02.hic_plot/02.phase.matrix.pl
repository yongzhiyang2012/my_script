use strict;
use warnings;

open (F,"HiC_contact_matrix.txt")||die"$!";
open (O,">HiC_contact_matrix.phase.txt");
while (<F>) {
    chomp;
    my @a=split(/\s+/,$_);
    $a[2]=$a[2]/log(2);
    $a[2]=20 if $a[0] eq $a[1];
    print O "$a[0]\t$a[1]\t$a[2]\n";
    print O "$a[1]\t$a[0]\t$a[2]\n" if $a[0] ne $a[1];
}
close F;
close O;
