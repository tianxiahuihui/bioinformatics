#######################################################
##################  type hyper  #######################
##################  get args    #######################
##### args[1]: a fiile (previous permutation file) ####
##### args[2]: database (HBT or BrainSpan)         ####
##### args[3]: [3|4|5|6]:(p|FDR|log10(p)|log10(FDR)####
##### args[4]: a file of pdf                       ####
##### args[5]: a csv file (contain all information)####                                      
##### args[6]:  a csv matrix file (you ploted)     ####                                             
#######################################################
## E：
## cd cd E:/wen_zhou_task/wu/Spatial express
## Rscript HBT-or-BrainSpan-permutation_enrichment.R permutation.txt HBT 3 HBT_p.pdf detail-HBT-p.csv HBT-p.csv 
## Rscript HBT-or-BrainSpan-permutation_enrichment.R BrainSpan-permutaion.txt BrainSpan 3 BrainSpan_p.pdf detail-BrainSpan-p.csv BrainSpan-p.csv
rm(list=ls())
args = commandArgs(TRUE)
library('gplots')
library('RColorBrewer')
cell=as.numeric(args[3])
region_time_data<-read.table(args[1],header=F,sep='\t')  ####输入文件#####
FDR<-p.adjust(region_time_data[,3],method="fdr",n=length(region_time_data[,3]))
#log_10<--log10(p_value)
log_10<--log10(region_time_data[,3])
region_time_data[,4]<-FDR
region_time_data[,5]<-log_10
region_time_data[,6]<-log10(FDR)
colnames(region_time_data)<-c("region","time","p_value","FDR","log(P)","log(FDR)")
if (args[2]=='BrainSpan')
{
heat_map_data<-matrix(ncol=12,nrow=16)
}
if (args[2]=='HBT')
{
heat_map_data<-matrix(ncol=15,nrow=16)
}
colnames(heat_map_data)<-sort(unique(region_time_data$time))
row.names(heat_map_data)<-sort(as.character(unique(region_time_data$region)))
for (i in 1:dim(region_time_data)[1])
{
 names<-as.character(region_time_data[i,1])
 names2<-as.character(region_time_data[i,2])
 heat_map_data[names,names2]<-region_time_data[i,cell]
}
names3<-rownames(heat_map_data)
become_plot_data<-data.frame(names3,heat_map_data)
if (args[2]=='BrainSpan')
{
become_plot_data2<-data.frame(become_plot_data[,1],become_plot_data[,13],become_plot_data[,3],
                              become_plot_data[,5],become_plot_data[,6],become_plot_data[,7],
                              become_plot_data[,10],become_plot_data[,2],become_plot_data[,12],
                              become_plot_data[,8],become_plot_data[,11],become_plot_data[,4],
                              become_plot_data[,9])
#colnames(become_plot_data2)<-c("region","Early prenatal","Early prenatal","Early mid-prenatal",
                      #"Early mid-prenatal","Late mid-prenatal","Late prenatal","Early infancy",
                      #"Late infancy","Early childhood","Late childhood","Adolescence","Adulthood")
colnames(become_plot_data2)<-c("region","8-9PCW","10-12PCW","13-15PCW","16-18_PCW",
                      "19-24PCW","25-38PCW","0-5mos","6-18mos",
                      "19mos-5yrs","6-11yrs","12-19yrs","20-40yrs")


#heat_map_data<-read.csv(file="become_plot_data.csv",header=T,sep=',')
heat_map_data<-as.matrix(become_plot_data2[,2:dim(become_plot_data2)[2]])
rownames(heat_map_data)<-become_plot_data2$region
pdf(args[4],width=7,height=6)
scaelwhiter<-colorRampPalette(c("white","burlywood1","mistyrose","firebrick1"),space="rgb")
par(mar = c(0.5, 0.5, 0.5, 0.5), bg = "white")
heatmap.2(heat_map_data,Colv=FALSE,Rowv= FALSE, 
          density.info="none",
          trace="none",cexCol=1,sepwidth=c(0.05,0.05),col=scaelwhiter,
          sepcolor="burlywood1",rowsep=0:17,colsep=0:13,srtCol=45,
          main="    Spatiotemporal-specific\nexpression ")
dev.off()
#head(heat_map_data)
}
if (args[2]=='HBT')
{
colnames(become_plot_data)<-c("region","4-8PCW","8-10PCW","10-13PCW","13-16PCW","16-19PCW","19-24PCW","24-38PCW","0-6mos","6-12mos","1-6yrs","6-12yrs","12-20yrs","20-40yrs","40-60yrs","60yrs-die")
#heat_map_data<-read.csv(file="become_plot_data.csv",header=T,sep=',')
heat_map_data<-as.matrix(become_plot_data[,2:dim(become_plot_data)[2]])
rownames(heat_map_data)<-become_plot_data$region
pdf(args[4],width=7,height=6)
scaelwhiter<-colorRampPalette(c("white","burlywood1","mistyrose","firebrick1"),space="rgb")
par(mar = c(0.5, 0.5, 0.5, 0.5), bg = "white")
heatmap.2(heat_map_data,Colv=FALSE,Rowv=FALSE, 
          density.info="none",
          trace="none",cexCol=1,sepwidth=c(0.001,0.001),col = scaelwhiter,
          sepcolor="burlywood1",rowsep=0:16,colsep=0:17,srtCol=45,
          main="    expression_in_different_time")
dev.off()
}
write.csv(region_time_data,file=args[5],row.names=T)
write.csv(heat_map_data,file=args[6],row.names=T)
