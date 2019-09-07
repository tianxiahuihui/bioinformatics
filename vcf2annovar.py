import sys, re, getopt, gzip

def usage():
    print("")
    print("usage: python %s [OPTIONS] vcf1 vcf2 ... " %sys.argv[0])
    print("       -i          <STRING>    infile")
    print("       -h/--help                     ")
    print("")

if len(sys.argv) < 2:
    usage()
    sys.exit(2)

try:
    opts, args = getopt.getopt( sys.argv[1:], "i:h", ["help", ] )
except getopt.GetoptError:
    print("get option error!")
    usage()
    sys.exit(2)

# deal with the options
# myfile = "myfile"   # default parameter
for opt, val in opts:
    if opt in ( "-h", "--help" ):
        usage()
        sys.exit(1)
    else:
        if opt in ( "-i", ):
            myfile = val

'''			
vcf文件格式
chrom   pos     id      ref     alt
1       877523  CM1511864       C       G
1       899318  CD142720        CCT     C
1       949523  CM1411641       C       T
1       949696  CI128669        C       CG
1       949739  CM128668        G       T
1       957605  CM148517        G       A
1       957693  CM148518        A       T
annovar文件格式
chrom   pos     pos     ref     alt
1       877523  877523  C       G
1       899319  899320  CT      -
1       949523  949523  C       T
1       949697  949697  -       G
1       949739  949739  G       T
1       957605  957605  G       A
1       957693  957693  A       T
1       976962  976962  C       T
1       977517  977517  -       C

	
'''
			
#try:
#    myfile, 
#except:
#    print("missing option...")
#    usage()
#    sys.exit(2)
            
# open infile and preprocessing
# for myfile in args:
	# #sample = myfile.split("/")[-1]
	# #sample = sample.split(".")[0]
	# if re.search(r'\.gz$',myfile):
		# f = gzip.open(myfile,'rt')
	# else:
f = open(myfile,'r')
while 1:
	l = f.readline()
	if not l:
		break
	#if l[:3]!="chr":
	#    continue
	l = l.rstrip()
	sample = l
	s = l.split("\t")
	chr = s[0]
	if len(s[3])==len(s[4]):
		start = end = s[1]
		ref,alt = s[3:5]
	else:
		step = min(len(s[3]),len(s[4]))
		dellen = len(s[3])-len(s[4])
		if dellen<0: 
			dellen = 1
		start = int(s[1])+step
		end = start+dellen-1
		ref = s[3][step:]
		alt = s[4][step:]
		if end<start: 
			end = start
		if ref=="": ref = "-"
		if alt=="": alt = "-"
	
	print(chr,start,end,ref,alt,sample,sep="\t")
	
f.close()

# writing to a file
#f = open(outfile,"w")
#outline = "symbol\t"
#f.write(outline)
