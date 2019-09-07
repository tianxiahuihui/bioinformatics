#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;



my ($list,$dep,$out,$annovar,$rm,$LowQual,$het,$hom,$markered,$bed);
GetOptions(
	"list=s" => \$list,
	"out=s" => \$out,
	"annovar=s" => \$annovar,
	"dep=i" => \$dep,
	"rm" => \$rm,	
	"LowQual=s" => \$LowQual,
	"het=s" => \$het,
	"hom=s" => \$hom,
	"markered"  => \$markered,
	"bed=s" => \$bed,
);

my $usage=<<USAGE;
usage   :       perl $0 
	-list		which have contain the information about: <Child_ID> <Father_ID> <Mother_ID> <Gender> <VCF infile1> [VCF infile2] 
	-out	outfile prefix
	-annovar="<str>"	paramenter of auto_ANNOVAR3.pl (-i -o are not necessary) default is " -type CDS -filterdatabase snp138NonFlagged,exac02,ESP6500si,1000g2014oct_all -filterfre  0.001 -functionsoft SIFT_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,RadialSVM_pred,LR_pred,VEST3_predict,CADD_predict,GERP++_predict,phyloP100way_predict,SiPhy_29way_predict -damaged 8 --inhouse --hgmd --remove   "; 
	-dep		min allele depth, defaut is 4
	-het	min heterozygous rate, defaut is 0.1
	-hom	min homozygous rate, defaut is 0.95
	-LowQual	filter LowQual of vcf, default is N
	-bed		bedfile, default is faulse
	--rm		rm files in process
	--markered
USAGE
die "$usage" unless ($list and $out);

$annovar ||= "-type CDS -filterdatabase snp138NonFlagged,exac02,ESP6500si,1000g2014oct_all -filterfre  0.001 -functionsoft SIFT_pred,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,RadialSVM_pred,LR_pred,VEST3_predict,CADD_predict,GERP++_predict,phyloP100way_predict,SiPhy_29way_predict -damaged 8 --inhouse --hgmd --remove ";
$LowQual ||= "N";
$dep ||= 2;
$het ||= 0.1;
$hom ||= 0.95;
if ($annovar =~ /^\"(.+)\"$/) {
	$annovar = $1;
}
my $auto_variation ||= "/public/home/duyaoqiang/software/Annovar/auto_ANNOVAR2016_du.pl";
my %hash_gender=();
my %hash_bed=();
open TRAN,">$out.transmitted.annovar" or die $!;
open LOG,">$out.filter.log" or die $!;
open LIST,"$list" or die $!;
if ($bed) {
	if ($bed =~ /^\S+.gz$/) {
		open BED,"gzip -dc $bed |" or die $!;
	}else{
		open BED,"$bed" or die $!;
	}
	while (<BED>) {
		chomp;
		my @tmp=split("\t",$_);
		for (my $i=$tmp[1]-5; $i<=$tmp[2]+5; $i++) {
			$hash_bed{$tmp[0]}{$i}="";
		}
	}
}

while (<LIST>) {
	chomp;
	my @tmp=split("\t",$_);
	die "List file formart error: $_" unless (@tmp>=5);
	$hash_gender{$tmp[0]}=$tmp[3]; 
	if (!$markered) {
	for (my $i=4; $i<@tmp; $i++) {
		if ($tmp[$i] =~ /^\S+.gz$/) {
			open IN,"gzip -dc $tmp[$i] |" or die "$!:$tmp[$i]";
		}else{
			open IN,"$tmp[$i]" or die "$!:$tmp[$i]";
		}
		print STDOUT "Progressing: trio $tmp[0]: $tmp[$i]\n";
		my %hash_name=();
		while (<IN>) {
			chomp;
			my @tmp2=split("\t",$_);
			if ($_ =~ /^\#\#/) {
				next;
			}elsif($_ =~ /^\#/){
				die "$tmp[$i] may not trios-based vcf\n" unless (@tmp2>=12);
				for (my $i=9; $i<@tmp2; $i++) {
					$hash_name{$tmp2[$i]}=$i;
				}
				die "Can not find ID of trio $tmp[0]/$tmp[1]/$tmp[2] in vcf file, $tmp[$i]" unless (exists($hash_name{$tmp[0]}) and exists($hash_name{$tmp[1]}) and exists($hash_name{$tmp[2]}));
			}else{
				if ($bed) {
					next unless(exists ($hash_bed{$tmp2[0]}{$tmp2[1]}));
				}
				if ($LowQual eq "Y" and $tmp2[6] eq "LowQual"){
					print LOG "Line $.: filter LowQual: $_\n";
					next;
				}
				if ($tmp2[0] eq "chrY" or $tmp2[0] eq "chrM"){
					print LOG "Line $.: filter chrY/M: $_\n";
					next;
				}
				my @obss=($tmp2[3]);
				my @tmp3=split(",",$tmp2[4]);
				for (my $i=0; $i<@tmp3; $i++) {
					push(@obss,$tmp3[$i]);
				}
				if (@obss>3){
					print LOG "Line $.: filter complex: $_\n";
					next; 
				}
				if ($tmp2[$hash_name{$tmp[0]}] =~ /\.\/\./ or $tmp2[$hash_name{$tmp[1]}] =~ /\.\/\./ or $tmp2[$hash_name{$tmp[2]}] =~ /\.\/\./) {
					print LOG "Line $.: filter NonCovered: $_\n";
					next; 
				}
				my %hash_tmp=();
				my $marker=0;
				for (my $j=0; $j<3; $j++) {
					if ($tmp2[$hash_name{$tmp[$j]}] =~ /0\/1:(\d+),(\d+):/){
						if ($1<$dep or $2<$dep or ($2/($1+$2))<$het){
							print LOG "Line $.: filter LowDep/Het: $_\n";
							last;
						}else{
							$hash_tmp{$j}="$1/$2";
							$marker++;
						}
					}elsif ($tmp2[$hash_name{$tmp[$j]}] =~ /1\/1:(\d+),(\d+):/){
						if ($2<($dep*2) or ($2/($1+$2))<$hom){
							print LOG "Line $.: filter LowDep/Hom: $_\n";
							last;
						}else{
							$hash_tmp{$j}="$1/$2";
							$marker++;
						}
					}elsif ($tmp2[$hash_name{$tmp[$j]}] =~ /1\/2:(\d+),(\d+),(\d+):/){
						if ($2<$dep or $3<$dep or $1>$dep or (($2/($1+$2+$3))<$het) or (($3/($1+$2+$3))<$het)){
							print LOG "Line $.: filter LowDep/Het2: $_\n";
							last;
						}else{
							$hash_tmp{$j}="$1/$2/$3";
							$marker++;
						}
					}elsif($tmp2[$hash_name{$tmp[$j]}] =~ /0\/0:(\d+),(\d+):/){
						if ($1<($dep*2) or ($1/($1+$2))<$hom){
							print LOG "Line $.: filter LowDep/Wild: $_\n";
							last;
						}else{
							$hash_tmp{$j}="$1/$2";
							$marker++;
						}
					}else{
						print LOG "Line $.: filter Unknownvcf$j: $_\n";
						last;
					}
				}
				if ($marker<3) {
					print LOG "Line $.: filter NotAllCovered: $_\n";
					next;
				}
				if ($tmp2[$hash_name{$tmp[0]}] =~ /0\/1:(\d+),(\d+):/){
					if ($tmp2[0] eq "chrX") {
						if($tmp[3] eq "M") {
							print LOG "Line $.: filter ChrX_Het_Man: $_\n";
							next;
						}elsif($tmp[3] eq "F"){
							if ($tmp2[$hash_name{$tmp[1]}] =~ /1\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/0:(\d+),(\d+):/) {
								store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TF\tHet1=$hash_tmp{0};Hom=$hash_tmp{1};Wild=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
							}elsif ($tmp2[$hash_name{$tmp[1]}] =~ /0\/0:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/){
								store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TM\tHet1=$hash_tmp{0};Wild=$hash_tmp{1};Het=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");								
							}else{
								print LOG "Line $.: filter UnknownInheritedHet1: $_\n";
								next;
							}
						}else{
							print LOG "Line $.: filter UnknownGender: $_\n";
							next;
						}
					}else{
						if ($tmp2[$hash_name{$tmp[1]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/0:(\d+),(\d+):/) {
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TF\tHet1=$hash_tmp{0};Het1=$hash_tmp{1};Wild=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}elsif($tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[1]}] =~ /0\/0:(\d+),(\d+):/ ){
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TM\tHet1=$hash_tmp{0};Wild=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}else{
								print LOG "Line $.: filter UnknownInheritedHet1: $_\n";
								next;
							#store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TFoM\t$tmp2[$hash_name{$tmp[0]}];$tmp2[$hash_name{$tmp[1]}];$tmp2[$hash_name{$tmp[2]}]");
						}
					}

				}elsif ($tmp2[$hash_name{$tmp[0]}] =~ /1\/1:(\d+),(\d+):/){
					if ($tmp2[0] eq "chrX") {
						if($tmp[3] eq "M") {
							if ($tmp2[$hash_name{$tmp[1]}] =~ /0\/0:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/ ) {
								store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TM\tHom=$hash_tmp{0};Wild=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
							}else{
								print LOG "Line $.: filter UnknownInheritedHom: $_\n";
								next;
							}
						}elsif($tmp[3] eq "F"){
							print LOG "Line $.: filter NoDisease: $_\n";
						}else{
							print LOG "Line $.: filter UnknownGender: $_\n";
							next;
						}
					}else{
						if ($tmp2[$hash_name{$tmp[1]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/) {
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TFM\tHom=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}else{
							print LOG "Line $.: filter UnknownInheritedHom: $_\n";
							next;
						}
					}
				}elsif ($tmp2[$hash_name{$tmp[0]}] =~ /1\/2:(\d+),(\d+),(\d+):/){
					if ($tmp2[0] eq "chrX") {
						print LOG "Line $.: filter ChrX_Het2: $_\n";
						next;
					}else{
						if ($tmp2[$hash_name{$tmp[1]}] =~ /0\/1:(\d+),(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/2:(\d+),(\d+),(\d+):/) {
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TF\tHet2=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[2],"TM\tHet2=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}elsif($tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[1]}] =~ /0\/2:(\d+),(\d+),(\d+):/){
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"TM\tHet2=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[2],"TF\tHet2=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}else{
							print LOG "Line $.: filter UnknownInheritedHet2: $_\n";
							next;
						}
					}
				}elsif($tmp2[$hash_name{$tmp[0]}] =~ /0\/0:(\d+),(\d+):/){
					if ($tmp2[0] eq "ChrX") {
						if($tmp[3] eq "M") {
							if ($tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[1]}] =~ /0\/0:(\d+),(\d+):/) {
								store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"NTM\tWild=$hash_tmp{0};Wild=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
							}else{
								print LOG "Line $.: filter UnknownInheritedHet2: $_\n";
								next;
							}
						}elsif($tmp[3] eq "F"){
							if ($tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/ or $tmp2[$hash_name{$tmp[1]}] =~ /0\/0:(\d+),(\d+):/) {
								store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"NTM\tWild=$hash_tmp{0};Wild=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
							}else{
								print LOG "Line $.: filter UnknownInheritedHet2: $_\n";
								next;
							}
						}else{
							print LOG "Line $.: filter UnknownGender: $_\n";
							next;
						}
					}else{
						if ($tmp2[$hash_name{$tmp[1]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/) {
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"NTFM\tWild=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}elsif($tmp2[$hash_name{$tmp[1]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[2]}] =~ /0\/0:(\d+),(\d+):/){
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"NTF\tWild=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}elsif($tmp2[$hash_name{$tmp[2]}] =~ /0\/1:(\d+),(\d+):/ and $tmp2[$hash_name{$tmp[1]}] =~ /0\/0:(\d+),(\d+):/){
							store($tmp2[0],$tmp2[1],$tmp2[1],$obss[0],$obss[1],"NTM\tWild=$hash_tmp{0};Het1=$hash_tmp{1};Het1=$hash_tmp{2}\t$tmp[0]\t$tmp[3]");
						}else{
							print LOG "Line $.: filter UnknownGender: $_\n";
							next;
						}
					}
				}else{
					print LOG "Line $.: filter Others: $_\n";
					next;
				}
			}
		}
		close IN;
	}
	}
}
close TRAN;
if (! $markered) {
	#system("perl $auto_variation -i $out.transmitted.annovar -o $out.transmitted.annovar --extreme --remove $annovar");
	system("perl $auto_variation -i $out.transmitted.annovar -o $out.transmitted.annovar --extreme --remove ");
}else{
	system("perl $auto_variation -i $out.transmitted.annovar.marker.xls --markered -o $out.transmitted.annovar --extreme --remove");
}
open EXTREME,"$out.transmitted.annovar.extreme.xls" or die $!;
open OUT,">$out.rareinherited.xls" or die $!;
print OUT "Sample\tType\tTrans\t";
my %hash_gene=();
my %hash_chr=();
while (<EXTREME>) {
	chomp;
	my @tmp=split("\t",$_);
	if($.==1){
		print OUT "$_\n";
		next;
	}
	if ($tmp[-5] eq "Y" and ($tmp[-4] eq "TF" or $tmp[-4] eq "TM" or $tmp[-4] eq "TFM")) {
		$hash_gene{$tmp[-2]}{$tmp[7]}{$tmp[-4]}{$.}=$_;
		$hash_chr{$tmp[7]}=$tmp[0]; 
		if ($tmp[-4] eq "TFM") {
			print $_;
		}
	}
}
close EXTREME;
foreach my $key (sort keys %hash_gene) { 
	foreach my $key2 (sort keys %{$hash_gene{$key}}) { 
		if (exists($hash_gene{$key}{$key2}{'TFM'})) {
			foreach my $key3 (sort keys %{$hash_gene{$key}{$key2}}) {
				my $st=".\t.\t.";
				if ($key3 eq "TFM") {
					$st="$key\tHomzygous\t$key3";
				}else{
					$st="$key\tHetrozygous\t$key3";
				}
				foreach my $key4 (sort keys %{$hash_gene{$key}{$key2}{$key3}}) {
					print OUT "$st\t$hash_gene{$key}{$key2}{$key3}{$key4}\n";
				}
			}
		}elsif(exists($hash_gene{$key}{$key2}{'TF'}) or exists($hash_gene{$key}{$key2}{'TM'})){
			foreach my $key3 (sort keys %{$hash_gene{$key}{$key2}}) {
				foreach my $key4 (sort keys %{$hash_gene{$key}{$key2}{$key3}}) {
					print OUT "$key\tHetrozygous\t$key3\t$hash_gene{$key}{$key2}{$key3}{$key4}\n";
				}
			}
		}elsif(exists($hash_gene{$key}{$key2}{'TM'}) and $hash_gender{$key} eq "M" and $hash_chr{$key2} eq "chrX"){
			foreach my $key3 (sort keys %{$hash_gene{$key}{$key2}}){
				foreach my $key4 (sort keys %{$hash_gene{$key}{$key2}{$key3}}) {
					print OUT "$key\tHemizygous\t$key3\t$hash_gene{$key}{$key2}{$key3}{$key4}\n";
				}
			}
		}
	}
}

sub store {
	my $chr0=shift;
	my $begin=shift;
	my $end=shift;
	my $ref=shift;
	my $obs=shift;
	my $ref_l=length($ref);
	my $obs_l=length($obs);
	my $str_dep0=shift; 
	if ($obs_l>$ref_l) { #insertion
		$ref="-";
		$obs=substr($obs,$ref_l);
	}elsif ($obs_l<$ref_l) { #deletion
		$end=$begin+$ref_l-1;
		$begin=$begin+$obs_l;
		$obs="-";
		$ref=substr($ref,$obs_l);
	}
	print TRAN "$chr0\t$begin\t$end\t$ref\t$obs\t$str_dep0\n";
}
