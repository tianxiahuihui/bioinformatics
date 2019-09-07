#! /usr/bin/python
import sys, re, getopt, gzip

def usage():
    print ""
    print "usage: python %s vcf1 vcf2 ... " %sys.argv[0]
    print "       -a          <STRING>    sample name"
    print "       -o          <STRING>    sample name"
    print "       -h/--help                     "
    print ""

if len(sys.argv) < 2:
    usage()
    sys.exit(2)

try:
    opts, args = getopt.getopt( sys.argv[1:], "a:o:h", ["help", ] )
except getopt.GetoptError:
    print "get option error!"
    usage()
    sys.exit(2)

for opt, val in opts:
    if opt in ( "-h", "--help" ):
        usage()
        sys.exit(1)
    else:
        if opt in ( "-a", ):
            anno = val
        if opt in ( "-o", ):
            out = val			
			
f = open(anno,"r")

genelist = list()
mutation = dict()

f.readline()
while 1:
	l = f.readline()
	if not l:
		break	
	list1 = l.strip('\n').split('\t')
	if(list1[7] not in genelist):
		genelist.append(list1[7])
	
for gene in genelist:
	mutation[gene] = []
	
f.seek(0)
f.readline()
while 1:
	l = f.readline()
	if not l:
		break
	list1 = l.strip('\n').split('\t')
	mutation[list1[7]].append(list1)

f.seek(0)
line1=f.readline()	
fout = open(out,'w')
fout.write("%s" %(line1))
for gene in genelist:
	if len(mutation[gene]) >= 2:
		TFMtype = list()
		snptype = list()
		for i in range(len(mutation[gene])):
			if mutation[gene][i][74] not in TFMtype:
				TFMtype.append(mutation[gene][i][74])
			if mutation[gene][i][42] not in snptype:
				snptype.append(mutation[gene][i][42])
		if len(snptype) == 1 and '-' in snptype :
			if ('TF' in TFMtype and 'TM' in TFMtype) or ('TFM' in TFMtype and ('TF' in TFMtype or 'TM' in TFMtype)):
				for i in range(len(mutation[gene])):
					if(mutation[gene][i][74] == 'TF' or mutation[gene][i][74] == 'TM' or mutation[gene][i][74] == 'TFM'):
						line1 = '\t'.join(mutation[gene][i])
						fout.write("%s\n" %(line1))
					
f.close()
fout.close()
