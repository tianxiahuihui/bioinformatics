use strict;
use Getopt::Long;

my ($infile,$outfile,);

GetOptions(
  "in=s" => \$infile,
  "out=s" => \$outfile,
);

my $usage=<<USAGE;
this file is to calculate pearson correlation coefficient.
usage:  perl $0 -option <argument>
    -in     <STRING>        input file, you can input a data file.
    -out    <STRING>        the name of your output file.
USAGE

die $usage if (( ! defined($infile))||( ! defined($outfile)));

my(@line,@data,);
my($i,$item,$key1,$key2,$value1,$value2,$rstr,);
my(%symbols1,%symbols2);

open INFILE,"<$infile" or die $!;
while(<INFILE>){
    @line=split("\t",$_);
    foreach $item(@line[13..254]){
        $symbols1{$line[3]} .= "$item" . "\t";
        $symbols2{$line[3]} .= "$item" . "\t";
    }
}

$rstr=<<RSTR;
####################################################################
# Using R scripts to calculate pearson correlation coefficient     #
####################################################################
brain_expr <- read.table("rfile.txt",header=F)
temp1<-c()
for(i in seq(1,243)){temp1<-c(temp1,brain_expr[1,i])}
temp2<-c()
for(i in seq(1,243)){temp2<-c(temp2,brain_expr[2,i])}
res<-cor(temp1,temp2)
write.table(res,file="R_res.txt", append=F,row.names=F,col.names=F)
####################################################################
RSTR
open RPRO,">/home/users/lijinchen/mysqldata/R_prog.r" or die $!;
print RPRO $rstr;
close RPRO;

my $output;
my $header="symbol\t";
my $judge=0;
my $length=keys %symbols1;
while(($key1, $value1) = each %symbols1){
    my $line = $key1 . "\t";
    while(($key2, $value2) = each %symbols2){
        #print $key1,$value1,$key2,$value2,"\n\n";
        
        open RFILE,">/home/users/lijinchen/mysqldata/rfile.txt" or die $!;
        print RFILE substr($value1,0,-1);
        print RFILE substr($value2,0,-1);
        close RFILE;
        system("R CMD BATCH R_prog.r");
        if($judge==0){
            $header .= $key2 . "\t";
        }
        open RRES,"</home/users/lijinchen/mysqldata/R_res.txt" or die $!;
        while(<RRES>){
            $line .= substr($_,0,-1) . "\t";
        }
        close RRES;
    }
    if($judge==0){
        $header = substr($header,0,-1) . "\n";
        $output = $header;
    }
    $line = substr($line,0,-1) . "\n";
    $output .= $line;
    
    $judge++;
    my $percent=($judge*100.0)/$length;
    print "------$percent% completed------\n";
}
open OUTFILE,">$outfile" or die $!;
print OUTFILE $output;
close INFILE;
close OUTFILE;


#run.sh
#PBS -N pearson
#PBS -j oe
#PBS -l nodes=ibnode14:ppn=2


perl /public/home/jiangyi/pearson_calculate.pl -in /public/home/jiangyi/brain -out /public/home/jiangyi/pearson.txt >/public/home/jiangyi/log_brain_pearson


