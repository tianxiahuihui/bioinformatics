#!/usr/bin/perl-w
use strict;
die  "\nUsage: $0 <InPutdir><Out>\n" unless (@ARGV == 3);
my $input = "$ARGV[0]";
my $outdir = "$ARGV[1]";
my $sample = "$ARGV[2]";
my $CG="$input/$sample";

my $count = `awk 'END{print NR}' $CG`;

open R,">$outdir/$sample.R" or die "$!";
#open R,">$outdir/$sample.R" or die "$!";

if($count<=40){
print R "pdf(\"$outdir/$sample.pdf\",height=6,width=18)
	library(ggplot2)
	a<-read.table(\"$CG\", header = TRUE)
	a <- transform(a, period = factor(gene, levels = unique(gene)))
	b<-as.data.frame(table(a\$num==1))
	number<-b[1,2]
	p <- ggplot(data = subset(a,a\$num==1), mapping = aes(x = period, y = dnmr)) + geom_bar(width = 0.5, stat = 'identity',fill = colorRampPalette(c(\'#F6D882\', \'#B81C31\'))(number)) + theme(axis.text.x=element_text(angle=45,colour='black',hjust=1,size = 10)) + labs(x = 'Gene Symbol', y = 'DNMR', title = 'Average') +  coord_cartesian(ylim=c(min(a\$dnmr)*0.95,max(a\$dnmr)*1.05))
	print(p)	

	dev.off()";
}else{
print R "pdf(\"$outdir/$sample.pdf\",height=6,width=18)
	library(ggplot2)
	a<-read.table(\"$CG\", header = TRUE)
	a <- transform(a, period = factor(gene, levels = unique(gene)))

	for (i in 1:max(a\$num)) {
		b<-as.data.frame(table(a\$num==i))
		number<-b[2,2]
		p <- ggplot(data = subset(a,a\$num==i), mapping = aes(x = period, y = dnmr)) + geom_bar(width = 0.5, stat = 'identity',fill = colorRampPalette(c(\'#F6D882\', \'#B81C31\'))(number)) + theme(axis.text.x=element_text(angle=45,colour='black',hjust=1,size = 10)) + labs(x = 'Gene Symbol', y = 'DNMR', title = 'Average') +  coord_cartesian(ylim=c(min(a\$dnmr)*0.95,max(a\$dnmr)*1.05))
		print(p)
	
	}
	
	dev.off()";
}

close R;
`R CMD BATCH $outdir/$sample.R`;
`rm -f $sample.Rout`;
