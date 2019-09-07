#@/usr/bin/perl
use strict;
use warnings;
use Encode;
use Encode::CN;
use utf8;
open VCF,"hgmd_pro_hgmd_annovar.xls" or die $!;
open (MUT,"<:encoding(utf8)","./Tab/hgmd_pro_allmut.xls") or die $!;
open EXT,"./Tab/hgmd_pro_extrarefs.xls" or die $!;
open OUT,">HGMD_mut_based.2.xls" or die $!;
open GENE,"./Tab/hgmd_pro_allgenes.xls" or die $!;
open AMI,"./Tab/hgmd_pro_aminoseq.xls" or die $!;
my %hash_vcf=();
my %hash_ext=();
my %hash_gene=();
my %hash_ami=();
while (<VCF>) {
	chomp;
	next unless ($. > 1);
	my @tmp=split("\t",$_);
	$hash_vcf{$tmp[7]}=$_;
}
close VCF;
while (<EXT>){
	chomp;
	next unless ($. > 1);
	my @tmp=split("\t",$_);
	$hash_ext{$tmp[0]}=$_;
}
close EXT;
while (<GENE>) {
	chomp;
	my @tmp=split("\t",$_);
	$hash_gene{$tmp[2]}=$_;
}
close GENE;
while (<AMI>){
	chomp;
	my @tmp=split("\t",$_);
	next if($.==1);
	next unless ($tmp[4] eq "human");
	$hash_ami{$tmp[1]}=$_;
}
close AMI;
while (<MUT>) {
	chomp;
	my $tmp_str=$_;
	my @tmp=split("\t",$tmp_str);
	my @outs=();
	my $id=$tmp[29];
#	my $id=$tmp[28];
	if ($. == 1) {
		push (@outs,"Chr");
		push (@outs,"Begin");
		push (@outs,"End");
		push (@outs,"Ref");
		push (@outs,"Obs");
	}else{
		if (exists ($hash_vcf{$id})) {
			my @tmp2=split("\t",$hash_vcf{$id});
			push (@outs, $tmp2[0]);
			push (@outs, $tmp2[1]);
			push (@outs, $tmp2[2]);
			push (@outs, $tmp2[3]);
			push (@outs, $tmp2[4]);
		}else{
			push (@outs, $tmp[15]);
			push (@outs, $tmp[16]);
			push (@outs, $tmp[17]);
			push (@outs, 0);
			push (@outs, 0);
		}
	}
	push (@outs,$tmp[0]);
	if ($. == 1){
		my @tmp0=split("\t",$hash_gene{'gene'});
		for(my $i=1; $i<=11;$i++){
			push(@outs, $tmp0[$i]);
		}
		push(@outs, $tmp0[17]);
		push(@outs, $tmp0[18]);
		push(@outs, "prot_acc");
		push(@outs, "prot_seq");
	}else{
		if (exists($hash_gene{$tmp[1]})){
			my @tmp0=split("\t",$hash_gene{$tmp[1]});
			for(my $i=1; $i<=11;$i++){
                        	push(@outs, $tmp0[$i]);
               		}
			push(@outs, $tmp0[17]);
			push(@outs, $tmp0[18]);
		}else{
			for(my $i=1; $i<=13; $i++){
				push(@outs,"-");
			}
		}
		if (exists($hash_ami{$tmp[1]})){
			my @tmp0=split("\t",$hash_ami{$tmp[1]});
			push(@outs,$tmp0[6]);
			push(@outs,$tmp0[5]);
		}else{
			 push(@outs,"-");
			 push(@outs,"-");
		}
	}
	for (my $i=9; $i<=13; $i++){
                push (@outs,$tmp[$i]);
        }
		push (@outs,$tmp[18]);	
	for (my $i=20; $i<=26; $i++){
		push (@outs,$tmp[$i]);
	}
	push (@outs,$tmp[29]);
	push (@outs,$tmp[30]);
	if ($. == 1){
		push (@outs,"mutation_type");
	}else{
		if ($tmp[31] eq "D"){
			push (@outs,"deletion");
		}elsif ($tmp[31] eq "E") {
			push (@outs,"amplet");
		}elsif ($tmp[31] eq "G"){
			push (@outs,"grosdel");
		}elsif ($tmp[31] eq "I") {
			push (@outs,"insertion");
		}elsif ($tmp[31] eq "M"){
			push (@outs,"mutation");
		}elsif ($tmp[31] eq "N"){
			push (@outs,"grosins");
		}elsif ($tmp[31] eq "P"){
			push (@outs,"complex");
		}elsif ($tmp[31] eq "R"){
			push (@outs,"prom");
		}elsif ($tmp[31] eq "S"){
			push (@outs,"splice");
		}elsif ($tmp[31] eq "X"){
			push (@outs,"indel");
		}else{
			push (@outs,"-");
		}
	}
	my $str=join("\t",@outs);
#	$str=encode("GB2312",$str);
#	$str = Encode::decode("utf8", $str);
	print OUT "$str\n"; 
}
