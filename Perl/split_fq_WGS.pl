#!/usr/bin/perl 
#=========================================
#	  Author : hushanshan
#	    Date : 2015/8/26
#	Function : split the fq of WGS
#=========================================
use Getopt::Long;

my $usage=<<USAGE;
	usage:perl $0 
		-in1	fq1
		-in2	fq2
		-n 		the num what you want to split into
		-o 		outdir
		-s 		sample
USAGE
unless(@ARGV>0){
	print "$usage\n";
	exit;
}
GetOptions(
	"n=i" => \$num,
	"in1=s" => \$fq1,
	"in2=s" => \$fq2,
	"o=s" => \$outdir,
	"s=s" => \$sample,
);
$num ||= 8;
my $line = `zcat $fq1 | wc -l`;
my $read = $line/4;
my $length = int($read/$num)*4;

if($fq1 =~ /\S+gz$/){
	open F1,"gzip -dc $fq1 |" or die "fq1 file doesn't exist!\n";
}else{
	open F1,"$fq1" or die "fq1 file doesn't exist!\n";
}
if($fq2 =~ /\S+gz$/){
	open F2,"gzip -dc $fq2 |" or die "fq2 file doesn't exist!\n";
}else{
	open F2,"$fq2" or die "fq2 file doesn't exist!\n";
}

for my $i(1..$num-1){
	open OUT1,"| gzip >$outdir/${sample}_${i}_1.fq.gz";
	open OUT2,"| gzip >$outdir/${sample}_${i}_2.fq.gz";
	$count=0;
	while($line1=<F1>){
		$line2=<F2>;
		$count++;
		if($count!=$length){
			print OUT1 "$line1";
			print OUT2 "$line2";
		}else{
			print OUT1 "$line1";
			print OUT2 "$line2";
			close OUT1;
			close OUT2;
			last;
		}
	}
}
open OUT1,"| gzip >$outdir/${sample}_${num}_1.fq.gz";
open OUT2,"| gzip >$outdir/${sample}_${num}_2.fq.gz";
while($line1=<F1>){
	$line2=<F2>;
	print OUT1 "$line1";
	print OUT2 "$line2";	
}
close OUT1;
close OUT2;
close F1;
close F2;
