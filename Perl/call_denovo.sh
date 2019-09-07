#PBS -N trios_E202
#PBS -o /public/home/chendenghui/run/process/20170418_ASD_quad/trios_E202/log.txt
#PBS -e /public/home/chendenghui/run/process/20170418_ASD_quad/trios_E202/err.txt
#PBS -l nodes=node6:ppn=20

cd /public/home/chendenghui/run/process/20170418_ASD_quad/trios_E202

javabin="/public/home/chendenghui/SPIP/software/jdk1.7.0_45/bin/java"
GATKbin="/public/home/chendenghui/SPIP/software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar"
refbin="/public/home/chendenghui/SPIP/database/hg19/hg19.fa"
dbsnpbin="/public/home/chendenghui/SPIP/database/dbsnp/hg19_GATK_snp137.vcf.gz"

$javabin -Xmx20g -jar $GATKbin -l INFO -R $refbin -T HaplotypeCaller -nct 20 -I /public/home/chendenghui/run/process/20170418_ASD_quad/E202F/gatk/E202F.realigned.recal.bam -I /public/home/chendenghui/run/process/20170418_ASD_quad/E202M/gatk/E202M.realigned.recal.bam -I /public/home/chendenghui/run/process/20170418_ASD_quad/E202/gatk/E202.realigned.recal.bam --dbsnp $dbsnpbin -o trios_E202.raw.vcf -G Standard -A DepthPerSampleHC -A ClippingRankSumTest -A AlleleBalance -A BaseCounts -A StrandBiasBySample -A FisherStrand -A StrandOddsRatio

$javabin -Xmx20g -jar $GATKbin -T VariantRecalibrator -R $refbin -input trios_E202.raw.vcf -resource:dbsnp,known=false,training=true,truth=true,prior=6.0 $dbsnpbin -an QD  -an MQRankSum -an ReadPosRankSum -an FS -an MQ -mode SNP -recalFile trios_E202.raw.recal -tranchesFile trios_E202.raw.tranches -rscriptFile trios_E202.raw.plots.R -nt 20 --maxGaussians 6

$javabin -Xmx20g -jar $GATKbin -T ApplyRecalibration -R $refbin -input trios_E202.raw.vcf --ts_filter_level 99.9 -tranchesFile trios_E202.raw.tranches -recalFile trios_E202.raw.recal -mode SNP -o trios_E202.raw.recal.vcf -nt 20

$javabin -Xmx18g -jar $GATKbin -R $refbin -T SelectVariants --variant trios_E202.raw.recal.vcf -o trios_E202.snp.vcf -selectType SNP

## forestDNM
childCol=3
patCol=2
matCol=1

awk '
    BEGIN{FS="\t"}
    {
        if($0~/^#/){
            print $0;
        }else{
            if($7!="LowQual"){
                if($(9+'$childCol')~/^0\/1/&&$(9+'$patCol')~/^0\/0/&&$(9+'$matCol')~/^0\/0/){
                    print $0;
                }
            }
        }
    }
' YMN-WES-010_da.snp.vcf > YMN-WES-010_da.snp.vcf.filter

/public/home/chendenghui/bin/bgzip YMN-WES-010_da.snp.vcf.filter

/public/home/chendenghui/SPIP/software/ht/bin/tabix -p vcf YMN-WES-010_da.snp.vcf.filter.gz

~/../zhangbing/software/R-3.2.5/lib64/R/library/forestDNM/scripts/forestDNM --file=E158-F_E158_E158-M.snp.vcf.filter.gz --sex=M --desc=E158-F_E158_E158-M --genome=hg19 --pat-col=$patCol --mat-col=$matCol --child-col=$childCol --cutoff=0

