#绘制带error bar的柱状图
#柱状图的高度是平均值, error bar则是通过t.test()计算得到95%置信区间
#1.生成dataframe
d = data.frame(x=c('A','B','C','D','E','F'),y=c(9.891094,18.02256,28.20093,34.44795,4.280318,5.15715),CI_min=c(8.458976,15.41622,19.98536,30.5622,3.361856,4.144212),CI_max=c(11.323211,20.62890,36.41649,38.3337,5.198781,6.170088))
p <- ggplot(d,aes(x=x,y=y,fill=x))+geom_bar(stat="identity",position=position_dodge(width=0.6),width=0.25,alpha=0.95)
p+theme_classic()+scale_y_continuous(expand=c(0,0),limits=c(0,40),breaks=seq(0,40, by=10))+geom_errorbar(aes(ymin=CI_min, ymax=CI_max,width=0.10), position=position_dodge(width=0.6))+scale_x_discrete(label=c('C>G\nG>C','T>C\nA>G','C>A\nG>T','C>T\nG>A','T>A\nA>T','T>G\nA>C'))+xlab("")+ylab("rare inherited SNVs (%)")


#生物信息学转换  GO库使用
#library("org.Mm.eg.db")
library("GSEABase")
library("GOstats")
a=read.table("Tet1.H4K16ac.ov.gene.xxx")
genes=as.character(a[,1])
#goAnn <- get("org.Mm.egGO")
#universe <- Lkeys(goAnn)
#entrezIDs <- mget(genes, org.Mm.egSYMBOL2EG, ifnotfound=NA)

entrezIDs <- as.character(entrezIDs)
params <- new("GOHyperGParams",geneIds=entrezIDs,universeGeneIds=universe,annotation="org.Mm.eg.db",ontology="BP",pvalueCutoff=0.05,conditional=FALSE,testDirection="over")
over <- hyperGTest(params)
library("Category")
glist <- geneIdsByCategory(over)
glist <- sapply(glist, function(.ids) {
  .sym <- mget(.ids, envir=org.Mm.egSYMBOL, ifnotfound=NA)
  .sym[is.na(.sym)] <- .ids[is.na(.sym)]
  paste(.sym, collapse=";")
})
bp <- summary(over)
bp$Symbols <- glist[as.character(bp$GOBPID)]
keggAnn <- get("org.Mm.egPATH")
universe <- Lkeys(keggAnn)

keggAnn <- get("org.Mm.egPATH")
universe <- Lkeys(keggAnn)
params <- new("KEGGHyperGParams", 
              geneIds=entrezIDs, 
              universeGeneIds=universe, 
              annotation="org.Mm.eg.db", 
              categoryName="KEGG", 
              pvalueCutoff=1,
              testDirection="over")
over <- hyperGTest(params)
kegg <- summary(over)
library(Category)
glist <- geneIdsByCategory(over)
glist <- sapply(glist, function(.ids) {
  .sym <- mget(.ids, envir=org.Mm.egSYMBOL, ifnotfound=NA)
  .sym[is.na(.sym)] <- .ids[is.na(.sym)]
  paste(.sym, collapse=";")
})
kegg$Symbols <- glist[as.character(kegg$KEGGID)]

write.table(bp,file="Tet1.H4K16ac.ov.gene.bp.xls",sep="\t",quote=FALSE)
write.table(kegg,file="Tet1.H4K16ac.ov.gene.kegg.xls",sep="\t",quote=FALSE)

#library("pathview")
#gIds <- mget(genes, org.Mm.egSYMBOL2EG, ifnotfound=NA)
#gEns <- unlist(gIds)
#gene.data <- rep(1, length(gEns))
#names(gene.data) <- gEns
#for(i in 1:3){pv.out <- pathview(gene.data, pathway.id=as.character(kegg$KEGGID)[i], species="mmu", out.suffix="pathview", kegg.native=T)}


#在pdf文件中生成柱状图
a<-read.table("DNMR.sequ-context-5", header = TRUE)
a <- transform(a, period = factor(gene, levels = unique(gene)))
p <- ggplot(data = a, mapping = aes(x = period, y = dnmr)) + 
      geom_bar(width = 0.5, stat = 'identity') + 
  scale_fill_gradientn(colours=c("#052749","#ffffff","#CC1E11")) + 
  theme(axis.text.x=element_text(angle=45,colour='black',hjust=1,size = 8)) + 
  labs(x = 'Gene Symbol', y = 'DNMR', title = 'CG content') +  
  coord_cartesian(ylim=c(min(a$dnmr)*0.95,max(a$dnmr)*1.05))

pdf("XES_R0170_RP2_final_average_depth.pdf",width=5,height=4)
a=read.table("Exome_R0170__RP2_final_average_depth",header=F)

p<-ggplot(a,aes(x=V1,y=V2,fill = V3))+geom_bar(position = "dodge",stat="identity",width=0.2,alpha=0.8)+theme(axis.text.x=element_text(angle=85,colour="black",size=3.5,hjust=1))+xlab("")+ylab("")+geom_abline(intercept = 50, slope = 0,alpha=0.5,color="#4F94CD")+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+xlab("Physical locations of RP2 exon5")+ylab("Average WES depth")+labs(title = "WES_depth")+ylim(0,65)
print(p)
dev.off()


#绘制饼图#参考网址：http://blog.csdn.net/Bone_ACE/article/details/47455363
library(ggplot2)
type <- c("exonic","intronic","intergenic","splicing","upstream","downstream","UTR5","UTR3")
nums <- c(571,12921,16703,6,165,208,61,318)
df <- data.frame(type = type, nums = nums)
label_value <- paste('(', round(df$nums/sum(df$nums) * 100, 1), '%)', sep = '') #生成比例
label <- paste(df$type, label_value, sep = '')  #exonic(1.8%)
p <- ggplot(data = df, mapping = aes(x = '', y = nums, fill = type)) + geom_bar(stat = 'identity', position = 'stack', width = 1)+
      coord_polar(theta = "y")+
      labs(x="",y="",title="")+#去掉标签
      theme(axis.ticks = element_blank())+#去掉左上角短横线
      theme(axis.text.x = element_blank())+ #去掉白色外框的数字
      scale_fill_discrete(breaks = df$type, labels = label)#将标签带上百分比






