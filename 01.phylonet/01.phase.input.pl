use strict;
use warnings;

my $phylonet="/home/data_disk_38T/luzhiqiang_work/software/phylonet/PhyloNet_3.8.2.jar";
my $tree;
my $num=0;
open (F,"all.gene.tre.root")||die"$!";
while (<F>){
    chomp;    s/\:[0-9\.]+//g;
    s/\)\d+/\)/g;
    $tree .= "TREE gt$num = $_\n";
    $num++;
}
close F;

open (SH,">$0.sh");
for (my $i=1;$i<=5;$i++){
    open (O,">Net$i.script");
    print O "#NEXUS\n\nBEGIN TREES;\n\n";
    print O "$tree\n";
    print O "\nEND;\n\nBEGIN PHYLONET;\nInferNetwork_ML (all) $i -pl 50 -x 100 -n 5 po -di;\n\nEND;\n";
    close O;
    print SH "java -jar $phylonet Net$i.script > Net$i.result\n";
}
close SH;
    
