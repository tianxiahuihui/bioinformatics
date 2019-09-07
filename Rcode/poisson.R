#poisson 检验，生成p value and p adjust
data<-read.table("ASD_Con_or.txt",header=TRUE,as.is=TRUE)
a1=c()
b1=c()
for (i in seq(1,length(data$DHS)))
{a <- poisson.test(c(data$ASD[i],data$non_ASD[i]),c(data$Con[i],data$non_Con[i]))
a1[i]=a$p.value
b1[i]=i}

a2=p.adjust(a1,method="fdr",n=length(a1))
just=c()
for (i in seq(1,length(data$DHS))) 
{m=0
for (j in seq(1,length(b1)))
    {if (i==b1[j]){just[i]=a2[j];break} else {m=m+1}}
    {if (m==length(b1)) {just[i]='-'}}	
}

datanew<-data.frame(DHS=data$DHS,ASD=data$ASD,Con=data$Con,non_ASD=data$non_ASD,non_Con=data$non_Con,OR=data$OR)
datanew$p_value<-a1
datanew$p_adjust<-just
write.table(datanew, "ASD_Con_or_p.txt", row.names=FALSE, sep="\t")
