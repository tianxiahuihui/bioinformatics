import sys, re, getopt, gzip, os

def usage():
    print("Construct idx for ANNOVAR format file.")
    print("usage: python %s -option <argument>" %sys.argv[0])
    print("       -i          <STRING>    infile")
    print("       -s          <STRING>    step, default is 1000")
    print("       -h/--help                     ")

if len(sys.argv) < 2:
    usage()
    sys.exit(2)

try:
    opts, args = getopt.getopt( sys.argv[1:], "i:s:h", ["help", ] )
except getopt.GetoptError:
    print("get option error!")
    usage()
    sys.exit(2)

step = 1000
for opt, val in opts:
    if opt in ( "-h", "--help" ):
        usage()
        sys.exit(1)
    else:
        if opt in ( "-i", ):
            myfile = val
        if opt in ( "-s", ):
            step = int(val)

try:
    myfile, 
except:
    print("missing option...")
    usage()
    sys.exit(2)

# print title of idx file
filesize = os.path.getsize(myfile)
res = open("%s.idx" % myfile, 'w')
res.write("#BIN\t%d\t%d\n" %(step,filesize))

if re.search(r'\.gz$',myfile):
    f = gzip.open(myfile,'rt')
else:
    f = open(myfile,'r')
    
pos = 0
while 1:
    chunk_min = f.tell()
    
    l = f.readline()
    if not l:
        break
    l = l.rstrip()
    s = l.split("\t")
    
    # ignore title
    if not re.search(r'^\d+$',s[1]): continue
    
    # analyse
    coorS = int(s[1])
    if coorS>(pos+step):
        if 'outline' in dir():
            outline = "%s%s\n" %(outline,(chunk_min-1))
            res.write(outline)
        
        pos = int(coorS/step)*step
        outline = "%s\t%s\t%s\t" %(s[0],pos,chunk_min)
        
chunk_last = f.tell()
outline = "%s%s\n" %(outline,chunk_last)
res.write(outline)

f.close()
res.close()
