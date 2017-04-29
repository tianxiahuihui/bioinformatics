
gzip -dc /public1/cdh/MD-metagenome-part3-26_20161213/MD-metagenome-part3-BHVS16J03-H001-26-rawdata/HS491-BHVS16J03-H001-16R09622_S4_L007_R1_001.fastq.gz >/public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/D87_1.fq

gzip -dc /public1/cdh/MD-metagenome-part3-26_20161213/MD-metagenome-part3-BHVS16J03-H001-26-rawdata/HS491-BHVS16J03-H001-16R09622_S4_L007_R2_001.fastq.gz >/public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/D87_2.fq

/public/home/chendenghui/SPIP/software/bowtie-1.0.0/bowtie /public/home/chendenghui/SPIP/database/hg19/hg19.fa -1 /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/D87_1.fq -2 /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/D87_2.fq --un /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/align/D87.unmap --chunkmbs 200 -p 24 >/public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/align/D87.align

/public/home/chendenghui/SPIP/software/metacv_2_2_6/metacv classify /public/home/chendenghui/SPIP/software/metacv_2_2_6/db_out/metacv_db /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/align/D87_1.unmap /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/align/D87_2.unmap /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/meta/D87 --threads=24

/public/home/chendenghui/SPIP/software/metacv_2_2_6/metacv res2table /public/home/chendenghui/SPIP/software/metacv_2_2_6/db_out/metacv_db /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/meta/D87.res /public/home/chendenghui/run/process/20161215_wmb_meta/meta//D87/meta/D87
