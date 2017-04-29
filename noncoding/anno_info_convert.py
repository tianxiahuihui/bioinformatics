import sys, re, getopt, os, string

def usage():
    print("usage: python3 %s -option <argument>" %sys.argv[0])
    print("   -i     <STRING>   inputfile")
    print("   -o     <STRING>   outfile")
    print("   -h/--help                ")
	
try:
    opts, args = getopt.getopt( sys.argv[1:], "i:o:h", ["help"] )
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
			

f1 = open(input,'r')
f2 = open(output,'w')
while 1:
	line1 = f1.readline()
	if not line1:
		break
	list1 = line1.strip('\r\n').split('\t')
	list2 = list()
	list2.append(list1[0])
	list2.append(list1[1])
	for i in range(2,174):
		if 'chr' in list1[i]:
			list2.append(str(len(list1[i].split(","))))
		else:
			list2.append(list1[i])
	line2 = '\t'.join(list2)
	f2.write("%s\n" % (line2))

f1.close()
f2.close()
	
