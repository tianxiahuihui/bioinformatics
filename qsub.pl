#!/usr/bin/perl
#function:
use File::Path;
use File::Copy;
use File::Basename;
use Getopt::Long;
#use extend;

my $usage=<<USAGE;
usage:
	$0 [Options]
Version:
	1.0
Options:
	-raw [s] rawdata name,if sample name is S001,fq is S001_1.fq.gz,S002_2.fq.gz,then rawdata name is "sample_?.fq.gz" <required>
	-n [s] sampleimformation list,the format must be correct <required>
	-o [s] outdir <required>
Format:
	sampleimformation list format
		1		2
	samplein name	sampleout name

USAGE

unless(@ARGV>0){
	print "$usage";
	exit;
}

GetOptions(
	"raw=s" => \$rawdata,
	"n=s" => \$samplefile,
	"o=s" => \$outdir,
);

# createdir("$outdir/result");
createdir("$outdir/fq");
createdir("$outdir/script1");

open IN,"$samplefile" or die "can not open $samplefile \n";
while(<IN>){
	chomp;
	if(m/^#/){next;}
	my($samplein,$sampleout) = (split /\s+/,$_)[0,1];
	my $file=$rawdata;
	$file=~s/sample/$samplein/g;
	$in=$file;
	my $script = gettypescript($in,$samplein,$sampleout);
	open RUN,">$outdir/script1/$samplein.run.sh";
	print RUN "$script\n";
	close RUN;
	system "chmod 755 $outdir/script1/$samplein.run.sh";
	system "qsub $outdir/script1/$samplein.run.sh";

}
close IN;

sub gettypescript
{
my($in,$samplein,$sampleout) = @_;
my $script=<<Script;
#PBS -N $samplein.all 
#PBS -o $outdir/script1/$samplein.log
#PBS -e $outdir/script1/$samplein.err
#PBS -l nodes=1:ppn=5

cd $outdir

#less /public/home/chendenghui/run/blast/ST/new_meta/AS/20160524_YMN-AS-32/$sampleout.m8.txt.gz |tail -n +6 |awk '{print \$1"\\t"\$2}' > $sampleout.f.txt

#awk 'NR==FNR{a[\$1]=\$1}NR>FNR{if(\$2==a[\$2]){print \$1}}' /public/home/chendenghui/run/blast/AllID $sampleout.f.txt > $sampleout.s.txt

#python /public/home/chendenghui/run/blast/ST/call_STv4.py -i /public1/chendenghui/20160524_metagenome_wmb/$samplein.fastq.gz -o $sampleout.t.txt -d $sampleout.s.txt

#gzip $sampleout.t.txt

#mv $sampleout.t.txt.gz ./fq

#sed -i '1i\@ST-E00294:138:HVMMYCCXX:1:1102:25773:41286 1:N:0:CACCGGAT\\nGCGCAGGCGTTGAAGAGTGCCATGCAACAGTACACCAACCGTGACCGCCGCCGCTTCGGAGACCCAGACATCGCCAAGACCGCCCTGGTGAAATGGAAGGAAGAGATGGAAATCTGCCGAGACCAGCTTCATGGTTTCGACTATTCCGGC\\n+\\nAAFFFKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK' $outdir/$samplein/align/$samplein\_1.unmap

#sed -i '1i\@ST-E00294:138:HVMMYCCXX:1:1102:25773:41286 2:N:0:CACCGGAT\\nCGCTTCGAGTTGTCCTGTTCGAAGAAGCCGGAATAGTCGAAACCATGAAGCTGGTCTCGGCAGATTTCCATCTCTTCCTTCCATTTCACCAGGGCGGTCTTGGCGATGTCTGGGTCTCCGAAGCGGCGGCGGTCACGGTTGGTGTACTGT\\n+\\nAAFFFKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKFKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKAKFKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKFAK' $outdir/$samplein/align/$samplein\_2.unmap

/public/home/chendenghui/SPIP/software/metacv_2_2_6/metacv classify /public/home/chendenghui/SPIP/software/metacv_2_2_6/db_out/metacv_db $outdir/$samplein/align/$samplein\_1.unmap $outdir/$samplein/align/$samplein\_2.unmap $outdir/$samplein/meta/$samplein --threads=24

/public/home/chendenghui/SPIP/software/metacv_2_2_6/metacv res2table /public/home/chendenghui/SPIP/software/metacv_2_2_6/db_out/metacv_db $outdir/$samplein/meta/$samplein.res $outdir/$samplein/meta/$samplein

cp $outdir/$samplein/meta/$samplein.fun_hist /public/home/chendenghui/run/blast/ST/new_meta/meta/20160524_YMN-AS-32/meta/Meta
cp $outdir/$samplein/meta/$samplein.tax_hist /public/home/chendenghui/run/blast/ST/new_meta/meta/20160524_YMN-AS-32/meta/Meta
cp $outdir/$samplein/meta/$samplein.csv /public/home/chendenghui/run/blast/ST/new_meta/meta/20160524_YMN-AS-32/meta/Meta

Script
	return $script;
}

sub createdir
{
	my $dir = shift;
	unless(-e "$dir"){`mkdir -p "$dir"`;}
	unless(-e "$dir"){die "can not create $dir,may be no permission!\n";}
}

