library("regioneR")
library(GenomicRanges)
library("genomation")
library(dplyr)
library(ggpubr)
library(ggplot2)
library(stringr)
#Rscript ~/pipeline/code/regionR3.r 41IP_1n.peak.bed /home/chendenghui/database/rmsk.class.bed 1000 random
setwd("/home/chendenghui/process/20190807_chip/bed")

Args <- commandArgs(TRUE)
peakfile<-Args[1]
repeatfile<-Args[2]
perm_times<-Args[3]
modes<-Args[4]

samID <- gsub(".r.bed", "", basename(peakfile))
outfile1 <-str_c(samID,".anno.csv")
outfile2 <-str_c(samID,".ran.pdf")
outfile3<-str_c(samID,".ran.bed")
perm_times <- as.numeric(perm_times)

pt.summary <-function(pt,rclass,samID) {
  
  pt_summary  <- data.frame(
    reclass <- rclass,
    observed = unlist(lapply(pt, function(x){x$observed})),
    permuted = unlist(lapply(pt, function(x){mean(x$permuted)})),
    lg2fc = log2(unlist(lapply(pt, function(x){x$observed}))/unlist(lapply(pt, function(x){mean(x$permuted)}))),
    zscore = unlist(lapply(pt, function(x){x$zscore})),
    alter = unlist(lapply(pt, function(x){x$alternative})),
    pval = unlist(lapply(pt, function(x){x$pval}))
    
  )
  
  rownames(pt_summary) <- samID
  pt_summary
}

hg19_size = read.delim("/home/chendenghui/database/hg19/hg19.chrom.sizes",header = F)
hg19 = getGenome(hg19_size)

repeatregion <- readBed(repeatfile, track.line = FALSE, remove.unusual = FALSE,zero.based = TRUE)#####cannot with header
peakregion <- readBed(peakfile, track.line = FALSE, remove.unusual = FALSE,zero.based = TRUE)

class1 <- c("DNA","DNA?","LINE","LINE?","Low_complexity","LTR","LTR?","Other","RC","RNA","rRNA","Satellite","scRNA","Simple_repeat","SINE","SINE?","snRNA","srpRNA","tRNA","Unknown","Unknown?")
#family1 <- c()
#class1 <- c("DNA","LINE")
for(rclass in class1){
LINEregion <- as.data.frame(repeatregion) %>% filter(name == rclass)

outfile1 <-str_c(samID,".",rclass,".anno.csv")
outfile2 <-str_c(samID,".",rclass,".ran.pdf")
outfile3<-str_c(samID,".",rclass,".ran.bed")

#over=numOverlaps(LINEregion, peakregion, count.once=TRUE)
#numOverlaps(LINEregion, repeatregion, count.once=TRUE)
#cat(paste("overlap regions",over,"\n"))

if (modes == "resample"){
pt <- permTest(A=peakregion, B=LINEregion, randomize.function=resampleRegions,allow.overlaps=FALSE,count.once=TRUE, universe=repeatregion,evaluate.function=numOverlaps,ntimes=perm_times,genome=hg19,mc.cores=10)
}else if (modes == "random"){
pt <- permTest(A=peakregion, B=LINEregion, randomize.function=randomizeRegions,evaluate.function=numOverlaps,ntimes=perm_times,genome=hg19,mc.cores=10)
}else if (modes == "circularRandomizeRegions") {
pt <- permTest(A=LINEregion, B=peakregion, randomize.function=circularRandomizeRegions,
	   evaluate.function=numOverlaps,ntimes=perm_times,genome=hg19,mc.cores=10)
}
else {
print("please provide permutation mode : random or resample(should provide universe region set)")
}

#summary(pt)
write.csv(pt.summary(pt,rclass,samID),file=outfile1,quote=FALSE)

#pdf(outfile2)
d <- data.frame(feature = c('real', rep('shuffled', length(pt$numOverlaps$permuted))),overlaps = c(pt$numOverlaps$observed, pt$numOverlaps$permuted))

#title_string <- paste0("Region: ", samID, "\n","Feature: ", rclass, "\n","shuffles: ", pt$numOverlaps$ntimes, "\n","observed: ", pt$numOverlaps$observed, "\n","p-val: ", format.pval(pt$numOverlaps$pval) ,"\n")
    
#gghistogram(d, x = "overlaps",add = "mean", rug = TRUE,color = "feature", fill = "feature",palette = c("#00AFBB", "#E7B800"),title = title_string)

write.table(d,file=outfile3,quote=FALSE,sep="\t")

#dev.off()
}

