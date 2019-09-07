#!/usr/bin/perl 
#=========================================
#	  Author : hushanshan
#	    Date : 2015/8/23
#	Function : merge the all fq file of one sample
#=========================================
use Getopt::Long;

my $usage=<<USAGE;
	usage:perl $0 -n samplelist -i indir -o outdir -p node
USAGE
unless(@ARGV>0){
	print "$usage\n";
	exit;
}
GetOptions(
	"n=s" => \$samplelist,
	"i=s" => \$indir,
	"o=s" => \$outdir,
	"p=i" => \$node,
);

system("mkdir -p $outdir/script/");
open IN,"$samplelist" or die "the samplelist doesn't exist";
while(<IN>){
	chomp;
	my($index,$file) = (split /\s+/,$_)[0,1];
	system("ls $indir/*$index*R1*gz > $outdir/$file-1.txt");
	system("ls $indir/*$index*R2*gz > $outdir/$file-2.txt");
	open OUT,">$outdir/script/$file.sh";
	my $head=<<Script;
#PBS -N $file.all
#PBS -o $outdir/script/$file.log
#PBS -e $outdir/script/$file.err
#PBS -l nodes=node$node:ppn=1
Script
	print OUT "$head\n";
	open IN1,"$outdir/$file-1.txt";
	while($line1=<IN1>){
		chomp $line1;
		print OUT "zcat $line1 >> $outdir/${file}_1.fq\n";
	}
	close IN1;
	print OUT "gzip ${file}_1.fq\n";
	open IN2,"$outdir/$file-2.txt";
	while($line2=<IN2>){
		chomp $line2;
		print OUT "zcat $line2 >> $outdir/${file}_2.fq\n";
	}
	close IN2;
	print OUT "gzip ${file}_2.fq\n";
	system("qsub $outdir/script/$file.sh");
}
close IN;
