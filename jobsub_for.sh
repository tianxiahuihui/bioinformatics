for i in ER1867_ER1868 ER1869_ER1870 ER1871_ER1872 ER1873_ER1874 ER1875_ER1876 ER1877_ER1878 ER1879_ER1880 ER1881_ER1882; do for n in {1..22} X Y; do mkdir -p $i/chr$n; done; done

for i in ER1867_ER1868 ER1869_ER1870 ER1871_ER1872 ER1873_ER1874 ER1875_ER1876 ER1877_ER1878 ER1879_ER1880 ER1881_ER1882; do for n in {1..22} X Y; do echo "#PBS -N $i.$n
#PBS -o /public/home/jiangyi/work/others/20160122_wmb_methy/swDMR/output.filter10X/script/log.$i.chr$n
#PBS -e /public/home/jiangyi/work/others/20160122_wmb_methy/swDMR/output.filter10X/script/err.$i.chr$n
#PBS -l nodes=1:ppn=5
cd /public/home/jiangyi/work/others/20160122_wmb_methy/swDMR/
~/bin/swDMR-1.0.7/swDMR --samples input/split.filter10X/${i:0:6}.input.chr$n.xls,input/split.filter10X/${i:7:6}.input.chr$n.xls --name ${i:0:6},${i:7:6} --outdir output.filter10X/$i/chr$n --statistics Fisher --cytosineType CG --window 1k --stepSize 100 --length 100 --pvalue 0.01 --coverage 4 --fold 2 --fdr 0.05 --Rbin /public/software/R --chromosome 1 --position 2 --ctype 3 --methy 4 --unmethy 5 -pro 5
" > script/jobsub.$i.chr$n; done; done

for i in ER1867_ER1868  ER1869_ER1870  ER1871_ER1872  ER1873_ER1874  ER1875_ER1876  ER1877_ER1878  ER1879_ER1880  ER1881_ER1882; do cat $i/chr*/*.Extend | awk '$2<$3' > $i.dif.xls; done
for i in ER1867_ER1868  ER1869_ER1870  ER1871_ER1872  ER1873_ER1874  ER1875_ER1876  ER1877_ER1878  ER1879_ER1880  ER1881_ER1882; do 
time bedtools intersect -a $i.dif.xls -b /public/home/jiangyi/work/WGS_dataMining/hg19_annotation.txt -wo |
cut -f1-9,13|
awk '
BEGIN{FS="\t";OFS="\t"}
{
    line=$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9; 
    if(line in a){
        a[line]=a[line]"|"$10
    }else{
        a[line]=$10
    }
}
END{for(i in a){print i,a[i]}}
' | sed -e '1ichr\tstart\tend\tCG_number\tmeth_A\tmeth_B\tdepth_A\tdepth_B\tp_value\tRegion' > $i.dif2.xls & done
