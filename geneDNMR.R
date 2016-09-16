#!/usr/local/bin/Rscript

#/usr/local/bin/Rscript geneDNMR.R CHD8
setwd("/var/www/html/mirdnmr/data/DNMR_gene")
args = commandArgs(TRUE)
gene <- as.character(args[1])
newgene <- paste('./geneDNMR',gene,sep="/")
inputfile <- paste(newgene,"txt",sep=".")
outputfile <- paste(gene,"pdf",sep=".")
#print(inputfile)
#print(outputfile)

library(ggplot2)
a<-read.table("DNMR.value.log10.result.txt",sep="\t",header=TRUE)
p<-ggplot(a,aes(x=DNMR,y=Class))+geom_jitter(alpha=0.05,shape=1)

pdf(outputfile,height=8,width=10)
b<-read.table(inputfile,sep="\t",header=TRUE)
p<-p+geom_point(data=b,aes(x=Vline,y=Class),size=3,color="red")+xlab("-log10(DNMR)")+ylab("DNMR TYPE")+theme(panel.grid.major =element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(),axis.line = element_line(colour = "black"))+scale_y_discrete(limits=c("DNMR-DM(Syn)","DNMR-DM(Mis)","DNMR-DM(LoF)","DNMR-DM(All)","DNMR-MF(Syn)","DNMR-MF(Mis)","DNMR-MF(LoF)","DNMR-MF(All)","DNMR-SC(Syn)","DNMR-SC(Mis)","DNMR-SC(LoF)","DNMR-SC(All)","DNMR-GC(All)"),labels=c("DNMR-DM (Syn)","DNMR-DM (Mis)","DNMR-DM (LoF)","DNMR-DM (All)","DNMR-MF (Syn)","DNMR-MF (Mis)","DNMR-MF (LoF)","DNMR-MF (All)","DNMR-SC (Syn)","DNMR-SC (Mis)","DNMR-SC (LoF)","DNMR-SC (All)","DNMR-GC (All)"))
print(p)

dev.off()
