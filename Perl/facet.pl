#!/usr/bin/perl-w
use strict;
die  "\nUsage: $0 <InPutdir><Out>\n" unless (@ARGV <= 3);
my $input = "$ARGV[0]";

my $count = `awk 'END{print NR}' $input`;
if($count <= 40){
	`awk '{print 1"\t"\$1"\t"\$2}' $input 1<>$input`;
}elsif($count > 40 && $count <= 80){
	my $newcount = int($count/2)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else{print 2"\t"\$1"\t"\$2}}' $input 1<>$input`;
}elsif($count > 80 && $count <= 120){
	my $newcount = int($count/3)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else if(NR/$newcount>1 && NR/$newcount<=2){print 2"\t"\$1"\t"\$2}else{print 3"\t"\$1"\t"\$2}}' $input 1<>$input`;
}elsif($count > 120 && $count <= 160){
	my $newcount = int($count/4)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else if(NR/$newcount>1 && NR/$newcount<=2){print 2"\t"\$1"\t"\$2}else if(NR/$newcount>2 && NR/$newcount<=3){print 3"\t"\$1"\t"\$2}else{print 4"\t"\$1"\t"\$2}}' $input 1<>$input`;
}elsif($count > 160 && $count <= 200){
	my $newcount = int($count/5)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else if(NR/$newcount>1 && NR/$newcount<=2){print 2"\t"\$1"\t"\$2}else if(NR/$newcount>2 && NR/$newcount<=3){print 3"\t"\$1"\t"\$2}else if(NR/$newcount>3 && NR/$newcount<=4){print 4"\t"\$1"\t"\$2}else{print 5"\t"\$1"\t"\$2}}' $input 1<>$input`;
}elsif($count > 200 && $count <= 250){
	my $newcount = int($count/6)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else if(NR/$newcount>1 && NR/$newcount<=2){print 2"\t"\$1"\t"\$2}else if(NR/$newcount>2 && NR/$newcount<=3){print 3"\t"\$1"\t"\$2}else if(NR/$newcount>3 && NR/$newcount<=4){print 4"\t"\$1"\t"\$2}else if(NR/$newcount>4 && NR/$newcount<=5){print 5"\t"\$1"\t"\$2}else{print 6"\t"\$1"\t"\$2}}' $input 1<>$input`;
}elsif($count > 250 && $count <= 300){
	my $newcount = int($count/7)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else if(NR/$newcount>1 && NR/$newcount<=2){print 2"\t"\$1"\t"\$2}else if(NR/$newcount>2 && NR/$newcount<=3){print 3"\t"\$1"\t"\$2}else if(NR/$newcount>3 && NR/$newcount<=4){print 4"\t"\$1"\t"\$2}else if(NR/$newcount>4 && NR/$newcount<=5){print 5"\t"\$1"\t"\$2}else if(NR/$newcount>5 && NR/$newcount<=6){print 6"\t"\$1"\t"\$2}else{print 7"\t"\$1"\t"\$2}}' $input 1<>$input`;
}elsif($count > 300 && $count <= 350){
	my $newcount = int($count/8)+1;
	`awk '{if(NR/$newcount<=1){print 1"\t"\$1"\t"\$2}else if(NR/$newcount>1 && NR/$newcount<=2){print 2"\t"\$1"\t"\$2}else if(NR/$newcount>2 && NR/$newcount<=3){print 3"\t"\$1"\t"\$2}else if(NR/$newcount>3 && NR/$newcount<=4){print 4"\t"\$1"\t"\$2}else if(NR/$newcount>4 && NR/$newcount<=5){print 5"\t"\$1"\t"\$2}else if(NR/$newcount>5 && NR/$newcount<=6){print 6"\t"\$1"\t"\$2}else if(NR/$newcount>6 && NR/$newcount<=7){print 7"\t"\$1"\t"\$2}else{print 8"\t"\$1"\t"\$2}}' $input 1<>$input`;
}

`sed -i '1i num\tgene\tdnmr' $input`;
