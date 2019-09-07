#PBS -N YMN-WES-010_da
#PBS -o ~/run/process//log.txt
#PBS -e ~/run/process//err.txt
#PBS -l nodes=1:ppn=12

javabin="~/SPIP/software/jdk1.7.0_45/bin/java"
GATKbin="~/SPIP/software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar"
refbin="~/SPIP/database/hg19/hg19.fa"
dbsnpbin="~/SPIP/database/dbsnp/hg19_GATK_snp137-1.vcf.gz"

cd ~/run/process/

$javabin -Xmx20g -jar $GATKbin -l INFO -R $refbin -T HaplotypeCaller -nct 12 -I /public/home/chendenghui/run/process//WGC052744U.realigned.recal.bam -I /public/home/chendenghui/run/process//WGC052741U.realigned.recal.bam -I /public/home/chendenghui/run/process//WGC052742U.realigned.recal.bam --dbsnp $dbsnpbin -o YMN-WES-010_da.raw.vcf -G Standard -A DepthPerSampleHC -A ClippingRankSumTest -A AlleleBalance -A BaseCounts -A StrandBiasBySample -A FisherStrand -A StrandOddsRatio

$javabin -Xmx20g -jar $GATKbin -T VariantRecalibrator -R $refbin -input YMN-WES-010_da.raw.vcf -resource:dbsnp,known=false,training=true,truth=true,prior=6.0 $dbsnpbin -an QD  -an MQRankSum -an ReadPosRankSum -an FS -an MQ -mode SNP -recalFile YMN-WES-010_da.raw.recal -tranchesFile YMN-WES-010_da.raw.tranches -rscriptFile YMN-WES-010_da.raw.plots.R -nt 12 --maxGaussians 6

$javabin -Xmx20g -jar $GATKbin -T ApplyRecalibration -R $refbin -input YMN-WES-010_da.raw.vcf --ts_filter_level 99.9 -tranchesFile YMN-WES-010_da.raw.tranches -recalFile YMN-WES-010_da.raw.recal -mode SNP -o YMN-WES-010_da.raw.recal.vcf -nt 12

$javabin -Xmx18g -jar $GATKbin -R $refbin -T SelectVariants --variant YMN-WES-010_da.raw.recal.vcf -o YMN-WES-010_da.snp.vcf -selectType SNP

## forestDNM
childCol=3
patCol=1
matCol=2

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

~/bin/bgzip YMN-WES-010_da.snp.vcf.filter

~/bin/tabix -p vcf YMN-WES-010_da.snp.vcf.filter.gz

~/bin/forestDNM_HPcaller/inst/scripts/forestDNM --file=E158-F_E158_E158-M.snp.vcf.filter.gz --sex=M --desc=E158-F_E158_E158-M --genome=hg19 --pat-col=$patCol --mat-col=$matCol --child-col=$childCol --cutoff=0

