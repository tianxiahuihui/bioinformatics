import sys, re, getopt, os, gzip

def usage():
    print("usage: python3 %s -option <argument>" %sys.argv[0])
    print("   -i     <STRING>   inputfile")
    print("   -d     <STRING>   database")
    print("   -o     <STRING>   outfile")
    print("   -h/--help                ")
	
try:
    opts, args = getopt.getopt( sys.argv[1:], "i:d:o:h", ["help"] )
except getopt.GetoptError:
    print("get option error!")
    usage()
    sys.exit(2)

for opt, val in opts:
    if opt in ( "-h", "--help" ):
        usage()
        sys.exit(1)
    else:
        if opt in ( "-i", ):
            input = val
        if opt in ( "-o", ):
            output = val
        if opt in ( "-d", ):
            database = val
		

if re.search(r'\.gz$',input):
    f = gzip.open(input,'rt')      # read
else:
    f = open(input,'r')
	
listd = list()
fd = open(database,"r")
for l in fd:
	listd.append(l.rstrip('\n'))

fw = open(output,'w')	

pattern = "@"
while 1:
	line = f.readline()
	if not line:
		break
	if line[0] == pattern:
		list = line.rstrip('\n').split(" ")
		if list[0] in listd:
			fw.write(line)
			fw.write(f.readline());fw.write(f.readline());fw.write(f.readline());
			listd.remove(list[0])
	if len(listd) == 0:
		break
	
f.close()
fw.close()
fd.close()
