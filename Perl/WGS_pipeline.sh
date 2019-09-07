#拆分文件


#step1: 对拆分成的8个文件
for i in {1..8};do echo "
#PBS -N qiurihua_L2_${i}.step1
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/qiurihua_L2_${i}.step1.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/qiurihua_L2_${i}.step1.err
#PBS -l nodes=node2:ppn=10

/public/home/chendenghui/SPIP/src/WGS.pl -in1 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/fq/qiurihua_L2_${i}_1.fq.gz -in2 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/fq/qiurihua_L2_${i}_2.fq.gz -s qiurihua_L2_${i} -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua -r /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/tmp -process 110000000
" > qiurihua_L2_${i}.step1.sh;done

#上一步生成的脚本运行
#PBS -N qiurihua_L3.step1
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/qiurihua_L3.step1.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/qiurihua_L3.step1.err
#PBS -l nodes=node5:ppn=10

/public/home/chendenghui/SPIP/src/WGS.pl -in1 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua_ZTD16105408_H32VFALXX_L3_1.clean.fq.gz -in2 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua_ZTD16105408_H32VFALXX_L3_2.clean.fq.gz -s qiurihua_L3 -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua -r /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/tmp -process 110000000

#对8个bam文件合并处理
#PBS -N qiurihua_L2.step2
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/qiurihua_L2.step2.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/qiurihua_L2.step2.err
#PBS -l nodes=node9:ppn=30

/public/home/chendenghui/SPIP/src/WGS.pl -in1 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_5/align/qiurihua_L2_5.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_6/align/qiurihua_L2_6.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_4/align/qiurihua_L2_4.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_7/align/qiurihua_L2_7.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_8/align/qiurihua_L2_8.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_1/align/qiurihua_L2_1.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_3/align/qiurihua_L2_3.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L2_2/align/qiurihua_L2_2.rmdup.sorted.bam:/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_L3/align/qiurihua_L3.rmdup.sorted.bam -s qiurihua_All -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua -r /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/tmp -process 000100000

#将合并的bam文件按染色体拆分
for i in chr{{1..22},X,Y};do echo "
#PBS -N $i.split
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurinan/script/$i.split.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurinan/script/$i.split.err
#PBS -l nodes=1:ppn=5

/public/home/hushanshan/SPIP/software/samtools-0.1.19/samtools view -h /public1/hushanshan/20151029_gf_WGS/Sample_WGC032257D/Sample_WGC032257D/align/Sample_WGC032257D.merge.bam $i -b >/public1/hushanshan/20151029_gf_WGS/Sample_WGC032257D/Sample_WGC032257D/split/$i.bam

/public/home/hushanshan/SPIP/software/samtools-0.1.19/samtools index /public1/hushanshan/20151029_gf_WGS/Sample_WGC032257D/Sample_WGC032257D/split/$i.bam

touch /public1/hushanshan/20151029_gf_WGS/Sample_WGC032257D/Sample_WGC032257D/split/$i.finish
" > $i.split.sh
;done

#运行拆分脚本
#PBS -N chr1.split
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/script/chr1.split.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/script/chr1.split.err
#PBS -l nodes=node2:ppn=1

/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools view -h /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/align/qiurihua_All.merge.bam chr1 -b >/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/chr1.bam

#/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools view -h /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/align/qiurihua_All.merge.bam chr1 |perl /public/home/chendenghui/SPIP/bin/changeheader.pl |/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools view -b -S - >/public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/chr1.bam

/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools index /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/chr1.bam

touch /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/script/chr1.finish


#按染色体进行处理
for i in chr{{1..22},X,Y};do echo "
#PBS -N ${i}.step3
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/${i}.step3.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/script/${i}.step3.err
#PBS -l nodes=1:ppn=5

/public/home/chendenghui/SPIP/src/WGS.pl -in1 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/${i}.bam -s qiurihua_All -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/ -r /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/tmp -chr ${i} -process 000010000
" > ${i}.step3.sh;done

#每条染色体的运行代码
#PBS -N chr1.step3
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/script/chr1.step3.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/script/chr1.step3.err
#PBS -l nodes=1:ppn=5

/public/home/chendenghui/SPIP/src/WGS.pl -in1 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/split/chr1.bam -s qiurihua_All -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/ -r /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/tmp -chr chr1 -process 000010000

#step4:
#PBS -N qiurihua_L2.step4
#PBS -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/script/qiurihua_L2.step4.log
#PBS -e /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/script/qiurihua_L2.step4.err
#PBS -l nodes=node5:ppn=10

/public/home/chendenghui/SPIP/src/WGS.pl -in1 /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/qiurihua_All/gatk -s qiurihua_All -o /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua -r /public/home/chendenghui/run/process/20170216_wmb_WGS/qiurihua/tmp -process 000001100










