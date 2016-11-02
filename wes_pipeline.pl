#PBS -N wu_F
#PBS -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/log.txt
#PBS -e /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/err.txt
#PBS -l nodes=node2:ppn=12

cd /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F

#/public/home/chendenghui/SPIP/software/trim_galore /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F_D16073191_HVM7KCCXX_L6_1.fq.gz /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F_D16073191_HVM7KCCXX_L6_2.fq.gz -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F --phred33 -q 15 -a GATCGGAAGAGCACACGTCT -a2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -e 0.1 --length 100 --stringency 1 --fastqc --paired --dont_gzip

/public/home/chendenghui/SPIP/bin/Trimgalorestat-1.3 -tr1 /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F_D16073191_HVM7KCCXX_L6_1.fq.gz_trimming_report.txt -tr2 /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F_D16073191_HVM7KCCXX_L6_2.fq.gz_trimming_report.txt -name wu_F -out /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/statistic_clean.xls

/public/home/chendenghui/SPIP/software/bwa-0.7.7/bwa mem -M -k 48 -t 10 -R "@RG\tID:Hiseq\tPL:Illumina\tSM:wu_F" /public/home/chendenghui/SPIP/database/hg19/hg19.fa /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F_D16073191_HVM7KCCXX_L6_1_val_1.fq /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F_D16073191_HVM7KCCXX_L6_2_val_2.fq |/public/home/chendenghui/SPIP/bin/SAMdeduplicate - -stat /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/rmdup_stat -p |/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools view -b -S - |/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools sort -m 500000000 - /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.rmdup.sorted

/public/home/chendenghui/SPIP/software/samtools-0.1.19/samtools index /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.rmdup.sorted.bam

/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java -Xms12g -Xmx12g -XX:+UseSerialGC -jar /public/home/chendenghui/SPIP/software/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /public/home/chendenghui/SPIP/database/hg19/hg19.fa -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.bam.list -I /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.rmdup.sorted.bam -nt 10

/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java -Xms14g -Xmx18g -XX:+UseSerialGC -Djava.io.tmpdir=/public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F -jar /public/home/chendenghui/SPIP/software/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar -I /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.rmdup.sorted.bam -R /public/home/chendenghui/SPIP/database/hg19/hg19.fa -T IndelRealigner -targetIntervals /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.bam.list -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.bam --maxReadsForRealignment 30000 --maxReadsInMemory 1000000

/public/home/chendenghui/SPIP/software/samtools-0.1.18/samtools index /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.bam

/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java -Xms10g -Xmx12g -XX:+UseSerialGC  -jar /public/home/chendenghui/SPIP/software/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar -l INFO -R /public/home/chendenghui/SPIP/database/hg19/hg19.fa -T BaseRecalibrator --knownSites:dbsnp,VCF /public/home/chendenghui/SPIP/database/dbsnp/hg19_GATK_snp137.vcf -I /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.bam -cov ReadGroupCovariate -cov QualityScoreCovariate -cov CycleCovariate -cov ContextCovariate -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.recal_data.csv --default_platform illumina

/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java -Xms10g -Xmx12g -XX:+UseSerialGC  -jar /public/home/chendenghui/SPIP/software/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar -l INFO -R /public/home/chendenghui/SPIP/database/hg19/hg19.fa -I /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.bam -T PrintReads -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.recal.bam -BQSR /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.recal_data.csv

/public/home/chendenghui/SPIP/software/samtools-0.1.18/samtools index /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.recal.bam

/public/home/chendenghui/SPIP/software/isaac_variant_caller-master.bin/bin/configureWorkflow.pl --bam /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.realigned.recal.bam --ref /public/home/chendenghui/SPIP/database/hg19/hg19.fa --config /public/home/chendenghui/SPIP/software/isaac_variant_caller-master.bin/etc/ivc_config_default.ini --output /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/issac

make -C /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/issac/

gzip -d /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/issac/results/wu_F.realigned.recal.genome.vcf.gz

grep -v LowGQX /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/issac/results/wu_F.realigned.recal.genome.vcf |grep -v "0/0" > /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.raw.recal.vcf

/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java -Xmx18g -jar /public/home/chendenghui/SPIP/software/GenomeAnalysisTK-1.4-30-gf2ef8d1/GenomeAnalysisTK.jar -R /public/home/chendenghui/SPIP/database/hg19/hg19.fa -T SelectVariants --variant /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.raw.recal.vcf -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.snp.vcf -selectType SNP

/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java -Xmx18g -jar /public/home/chendenghui/SPIP/software/GenomeAnalysisTK-1.4-30-gf2ef8d1/GenomeAnalysisTK.jar -R /public/home/chendenghui/SPIP/database/hg19/hg19.fa -T SelectVariants --variant /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.raw.recal.vcf -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.indel.vcf  -selectType INDEL

#statistic
/public/home/chendenghui/SPIP/bin/bam_dup_stat.pl -c /public/home/chendenghui/SPIP/chip/Exome -i /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.rmdup.sorted.bam -stat /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/Exome_depthCoverage.stat

/public/home/chendenghui/SPIP/bin/statistic.pl -i /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/Exome_depthCoverage.stat -ch Exome -c /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/statistic_clean.xls -d /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/rmdup_stat -n WGC052742U -o /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/statistic.xls -t normal

#annovar
/public/software/Annovar/annovar20160331/table_annovar.pl /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.snp.vcf /public/database/hg19_annovar/  -buildver hg19  -out wu_F_snp -protocol  refGene,cytoband,genomicSuperDups,clinvar_20160302,avsnp144,1000g2015aug_all,esp6500siv2_all,exac03,cg69,ljb26_all -operation g,r,r,f,f,f,f,f,f,f  -vcfinput -remove -nastring .

/public/software/Annovar/annovar20160331/table_annovar.pl /public/home/chendenghui/run/process/20160818_wu_ASD_wes/RawData/wu_F/wu_F.indel.vcf /public/database/hg19_annovar/  -buildver hg19  -out wu_F_indel -protocol  refGene,cytoband,genomicSuperDups,clinvar_20160302,avsnp144,1000g2015aug_all,esp6500siv2_all,exac03,cg69,ljb26_all -operation g,r,r,f,f,f,f,f,f,f  -vcfinput -remove -nastring .
