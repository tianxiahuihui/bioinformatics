import sys, os
from subprocess import call
import pybedtools
from pybedtools import BedTool
import tabix
from pandas import *
from functools import reduce
import xlwt
import tempfile
# read the GWAVA_DIR from the environment, but default to the directory above where the script is located
GWAVA_DIR = os.getenv('GWAVA_DIR', '/public/home/chendenghui/run/work/non_soft/GWAVA')

# set the pybedtools temp directory
pybedtools.set_tempdir(GWAVA_DIR+'/tmp/')

#['ATF3', 'BATF', 'BCL11A', 'BCL3', 'BCLAF1', 'BDP1', 'BHLHE40', 'BRCA1', 'BRF1', 'BRF2', 'CCNT2', 'CEBPB', 'CHD2', 'CTBP2', 'CTCF', 'CTCFL', 'DNase', 'E2F1', 'E2F4', 'E2F6', 'EBF1', 'EGR1', 'ELF1', 'ELK4', 'EP300', 'ERALPHAA', 'ESRRA', 'ETS1', 'Eralphaa', 'FAIRE', 'FAM48A', 'FOS', 'FOSL1', 'FOSL2', 'FOXA1', 'FOXA2', 'GABPA', 'GATA1', 'GATA2', 'GATA3', 'GTF2B', 'GTF2F1', 'GTF3C2', 'H2AFZ', 'H3K27ac', 'H3K27me3', 'H3K36me3', 'H3K4me1', 'H3K4me2', 'H3K4me3', 'H3K79me2', 'H3K9ac', 'H3K9me1', 'H3K9me3', 'H4K20me1', 'HDAC2', 'HDAC8', 'HEY1', 'HMGN3', 'HNF4A', 'HNF4G', 'HSF1', 'IRF1', 'IRF3', 'IRF4', 'JUN', 'JUNB', 'JUND', 'KAT2A', 'MAFF', 'MAFK', 'MAX', 'MEF2_complex', 'MEF2A', 'MXI1', 'MYC', 'NANOG', 'NFE2', 'NFKB1', 'NFYA', 'NFYB', 'NR2C2', 'NR3C1', 'NR4A1', 'NRF1', 'PAX5', 'PBX3', 'POLR2A', 'POLR2A_elongating', 'POLR3A', 'POU2F2', 'POU5F1', 'PPARGC1A', 'PRDM1', 'RAD21', 'RDBP', 'REST', 'RFX5', 'RXRA', 'SETDB1', 'SIN3A', 'SIRT6', 'SIX5', 'SLC22A2', 'SMARCA4', 'SMARCB1', 'SMARCC1', 'SMARCC2', 'SMC3', 'SP1', 'SP2', 'SPI1', 'SREBF1', 'SREBF2', 'SRF', 'STAT1', 'STAT2', 'STAT3', 'SUZ12', 'TAF1', 'TAF7', 'TAL1', 'TBP', 'TCF12', 'TCF7L2', 'TFAP2A', 'TFAP2C', 'THAP1', 'TRIM28', 'USF1', 'USF2', 'WRNIP1', 'XRCC4', 'YY1', 'ZBTB33', 'ZBTB7A', 'ZEB1', 'ZNF143', 'ZNF263', 'ZNF274', 'ZZZ3']

def encode_feats(vf, af):
    results = {}
    cols = open(af+'.cols', 'r').readline().strip().split(',')
    #intersection = vs.intersect(feats, wb=True)#TRUE
    tempfile1 = tempfile.mktemp()
    sort_cmd1 = 'bedtools intersect -wb -a %s -b %s > %s' % (vf, af, tempfile1)
    call(sort_cmd1, shell=True)
    tempfile2 = tempfile.mktemp()
    sort_cmd2 = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$10"\t"$5"_"$6"_"$7"_"$8"_"$9"_"$10"_"$11"_"$12}\' %s > %s' % (tempfile1, tempfile2)
    call(sort_cmd2, shell=True)
    intersection = BedTool(tempfile2)
    annots = intersection.groupby(g=[1,2,3,4,5], c=6, ops='collapse')
    for entry in annots:
        #fs = entry[5].strip(',').split(',')
        #results[entry.name] = Series({e[0]: int(e[1]) for e in [f.split(':') for f in fs]})
        results[entry.name] = Series({entry[4]: entry[5]})
        df = DataFrame(results, index = cols)
    # transpose to turn feature types into columns, and turn all the NAs in to 0s
    return df.T.fillna(0)


#UTR5	STOP	CDS	UTR3	ACCEPTOR	START	EXON	INTRON	DONOR
def gene_regions(vf, af):
    v = BedTool(vf)
    feats = BedTool(af)
    
    # first establish all the columns in the annotation file
    cols = set(f[4] for f in feats)

    results = {}

    intersection = v.intersect(feats, wb=True)

    if len(intersection) > 0:
        sort_cmd1 = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$9"\t"$5"_"$6"_"$7"_"$8"_"$9}\' %s 1<>%s' % (intersection.fn, intersection.fn)
        call(sort_cmd1, shell=True)
        annots = intersection.groupby(g=[1,2,3,4,5], c=6, ops='collapse')

        for entry in annots:
            regions = {}
            regions[entry[4]] = entry[5]

            results[entry.name] = Series(regions)

    df = DataFrame(results, index = cols)

    return df.T.fillna(0)

def gerp(vf, af, name="gerp"):
    v = BedTool(vf)
    t = tabix.open(af)

    results = {}

    for var in v:
        try:
            result = 0.0
            num = 0
            for res in t.query(var.chrom, var.start, var.end):
                result += float(res[4])
                num += 1
            if num > 0:
                results[var.name] = result/num
        except:
            pass

    return Series(results, name=name)

#GC
def gc_content(vf, fa, flank=50):
    v = BedTool(vf)
    flanks = v.slop(g=pybedtools.chromsizes('hg19'), b=flank)
    nc = flanks.nucleotide_content(fi=fa)
    results = dict([ (r.name, float(r[5])) for r in nc ])
    return Series(results, name="GC") 

#avg_gerp
def average_gerp(vf, af, flank=50):
    v = BedTool(vf)
    flanks = v.slop(g=pybedtools.chromsizes('hg19'), b=flank)
    return gerp(flanks.fn, af, name="avg_gerp")

#ss_dist, tss_dist
def feat_dist(vf, af, name):
    v = BedTool(vf)
    a = BedTool(af)
    closest = v.closest(a, D="b")
    results = dict([ (r.name, int(r[len(r.fields)-1])) for r in closest ])
    return Series(results, name=name)

# pwm
def motifs(vf, af):
    v = BedTool(vf)
    cpg = BedTool(af)
    overlap = v.intersect(cpg, wb=True)
    sort_cmd1 = 'sort -k1,1 -k2,2n -k3,3n -k4,4 %s -o %s' % (overlap.fn, overlap.fn)
    call(sort_cmd1, shell=True)
    sort_cmd2 = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$5"__"$6"__"$7"__"$8"__"$9"__"$10"__"$11"__"$12"__"$13}\' %s 1<>%s' % (overlap.fn, overlap.fn)
    call(sort_cmd2, shell=True)
    annots = overlap.groupby(g=[1,2,3,4], c=5, ops='collapse')
    results = {}
    for entry in annots:
        results[entry.name] = entry[4]
    return Series(results, name="pwm")

def cpg_islands(vf, af):
    v = BedTool(vf)
    cpg = BedTool(af)
    overlap = v.intersect(cpg, wb=True)
    sort_cmd = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$5"_"$6"_"$7"_"$8}\' %s 1<>%s' % (overlap.fn, overlap.fn)
    call(sort_cmd, shell=True)	
    results = {}
    for r in overlap:
        results[r.name] = r[4]
    return Series(results, name="cpg_island")

#CTCF_REG, ENH, TSS_FLANK, REP, TRAN, TSS, WEAK_ENH
def segmentations(vf, af):
    v = BedTool(vf)
    feats = BedTool(af)
    results = {}
    intersection = v.intersect(feats, wb=True)
    if len(intersection) > 0:
        sort_cmd1 = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$8"\t"$5"_"$6"_"$7"_"$8"_"$9}\' %s 1<>%s' % (intersection.fn, intersection.fn)
        call(sort_cmd1, shell=True)
        annots = intersection.groupby(g=[1,2,3,4,5], c=6, ops='collapse')
        for entry in annots: 
            regions = {}
            regions[entry[4]] = entry[5]

            results[entry.name] = Series(regions)

    names = {
        'CTCF': 'CTCF_REG', 
        'E':    'ENH', 
        'PF':   'TSS_FLANK', 
        'R':    'REP', 
        'T':    'TRAN', 
        'TSS':  'TSS', 
        'WE':   'WEAK_ENH'
    }

    return DataFrame(results, index=names.keys()).T.rename(columns=names)   

#dnase_fps
def dnase_fps(vf, af):
    v = BedTool(vf)
    feats = BedTool(af)
    results = {}
    #intersection = feats.intersect(v, wb=True,wa=True)
    intersection = v.intersect(feats, wb=True)
    #intersection = v.intersect(feats, wb=True)
    if len(intersection) > 0:
        sort_cmd1 = 'sort -k1,1 -k2,2n -k3,3n %s -o %s' % (intersection.fn, intersection.fn)
        call(sort_cmd1, shell=True)
        sort_cmd2 = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$5"_"$6"_"$7"_"$8"_"$9}\' %s 1<>%s' % (intersection.fn, intersection.fn)
        call(sort_cmd2, shell=True)
        annots = intersection.groupby(g=[1,2,3,4], c=5, ops='collapse')
        for entry in annots:
            results[entry.name] = entry[4]

    return Series(results, name='dnase_fps')

#bound_motifs
def bound_motifs(vf, af):
    v = BedTool(vf)
    feats = BedTool(af)
    #intersection = feats.intersect(v, wb=True,wa=True)
    intersection = v.intersect(feats, wb=True)
    results = {}
    if len(intersection) > 0:
        sort_cmd1 = 'sort -k1,1 -k2,2n -k3,3n %s -o %s' % (intersection.fn, intersection.fn)
        call(sort_cmd1, shell=True)
        sort_cmd2 = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$5"__"$6"__"$7"__"$8"__"$9}\' %s 1<>%s' % (intersection.fn, intersection.fn)
        call(sort_cmd2, shell=True)
        annots = intersection.groupby(g=[1,2,3,4], c=5, ops='collapse')
        for entry in annots:
            results[entry.name] = entry[4]

    return Series(results, name='bound_motifs')

#avg_het, avg_daf
def snp_stats(vf, af, stat='avg_het', flank=500):
    v = BedTool(vf)
    feats = BedTool(af)
    flanks = v.slop(g=pybedtools.chromsizes('hg19'), b=flank)
    intersection = feats.intersect(flanks, wb=True)
    results = {}
    if len(intersection) > 0:
        sort_cmd = 'sort -k6,6 -k7,7n -k8,8n -k9,9 %s -o %s' % (intersection.fn, intersection.fn)
        call(sort_cmd, shell=True)
        annots = intersection.groupby(g=[6,7,8,9], c=5, ops='collapse')

        for entry in annots:
            rates = entry[4].split(',')
            tot = reduce(lambda x, y: x + float(y), rates, 0.)
            rate = tot / (flank * 2)
            results[entry.name] = rate
        
    return Series(results, name=stat)

#in_cpg, seq_A, seq_C, seq_G, seq_T	
def seq_context(vf, fa):
    #v = BedTool(vf)
    #flanks = v.slop(g=pybedtools.chromsizes('hg19'), b=1)
    sort_cmd2 = 'awk -F \'\t\' \'{print $1"\t"$2-1"\t"$3+1"\t"$4}\' %s > %s' % (vf, 'test.2.bed')
    call(sort_cmd2, shell=True)
    flanks = BedTool('test.2.bed')
    nc = flanks.nucleotide_content(fi=fa, seq=True, pattern="CG", C=True)
    cpg_context = Series(dict([ (r.name, float(r[14])) for r in nc ]))
    nucleotide = Series(dict([ (r.name, r[13][1].upper()) for r in nc ]))
    results = {}
    for b in 'ACGT':
        results['seq_'+b] = (nucleotide == b).apply(float)

    results['in_cpg'] = cpg_context

    return DataFrame(results) 

#repeat
def repeats(vf, af):
    v = BedTool(vf)
    feats = BedTool(af)
    intersection = v.intersect(feats, wb=True)
    results = {}
    if len(intersection) > 0:
        sort_cmd = 'awk -F \'\t\' \'{print $1"\t"$2"\t"$3"\t"$4"\t"$5"_"$6"_"$7"_"$8"_"$9"_"$10}\' %s 1<>%s' % (intersection.fn, intersection.fn)
        call(sort_cmd, shell=True)
        annots = intersection.groupby(g=[1,2,3,4], c=5, ops='collapse')
        for entry in annots:
            results[entry.name] = entry[4]

    return Series(results, name='repeat')

def coordinates(vf):
    vs = BedTool(vf)
    pos = {}
    for v in vs: 
        pos[v.name] = {'chr': v.chrom, 'start': int(v.start), 'end': int(v.stop)}
    return DataFrame(pos).T

DIR = GWAVA_DIR+'/source_data/'
CPG = DIR+'ucsc/ucsc_cpg_islands.bed.gz'
TSS = DIR+'encode/Gencodev10_TSS_May2012.gff.gz'
GERP = DIR+'gerp/gerp_whole_genome.bed.gz'
HG19 = DIR+'hg19/hg19.fa'
MOTIFS = DIR+'ensembl/MotifFeatures.gff.gz'
SEGMENTS = DIR+'ensembl/segmentation.bed.gz'
DNASE_FPS = DIR+'encode/all.footprints.bed.gz'
BOUND_MOTIFS = DIR+'encode/bound_motifs.bed.gz'
GENE_REGIONS = DIR+'ensembl/gene_regions.bed.gz'
SPLICE_SITES = DIR+'ensembl/splice_sites.bed.gz'
HET_RATES = DIR+'1kg/het_rates.bed.gz'
DAF = DIR+'1kg/daf.bed.gz'
REPEATS = DIR+'ucsc/ucsc_repeats.bed.gz'
ENCODE_FEATS = DIR+'encode/encode_megamix.bed.gz'

def annotate(vf):
  
    df = coordinates(vf)

    annots = [
        encode_feats(vf, ENCODE_FEATS),
        motifs(vf, MOTIFS),
        cpg_islands(vf, CPG),
        average_gerp(vf, GERP),
        gerp(vf, GERP),
        feat_dist(vf, TSS, name='tss_dist'),  
        gc_content(vf, HG19),
        segmentations(vf, SEGMENTS),
        dnase_fps(vf, DNASE_FPS),
        bound_motifs(vf, BOUND_MOTIFS),
        gene_regions(vf, GENE_REGIONS),
        feat_dist(vf, SPLICE_SITES, name='ss_dist'),
        snp_stats(vf, HET_RATES, stat='avg_het'),
        snp_stats(vf, DAF, stat='avg_daf'),
        #seq_context(vf, HG19),
        repeats(vf, REPEATS)
    ]

    # make sure everything is a DataFrame
    annots = [a if isinstance(a, DataFrame) else DataFrame({a.name: a}) for a in annots]
    
    # and join them all together
    df = df.join(annots)

    df = df.fillna(0)

    return df

if __name__ == "__main__":

    if len(sys.argv) < 3:
        print("Usage:",sys.argv[0]," variants.bed output.csv class")
        sys.exit(0)

    vf = sys.argv[1]
    out = sys.argv[2]

    if len(sys.argv) == 4:
        cls = sys.argv[3]
    else:
        cls = 0

    df = annotate(vf)

    df['cls'] = int(cls)

    df.to_excel(out)
   
