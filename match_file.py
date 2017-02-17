import sys, re, getopt, os

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

#将1文件生成字典，将2文件匹配字典key的其他值作为字典的key，最后将字典打印到文件中			
f1=open(database,'r')  #ASD_4582trios.noexonic.bed
datadic = dict()
for line1 in f1.readlines():
	list1 = line1.strip("\n").split("\t")
	linekey="_".join([list1[0],list1[1],list1[2],list1[3],list1[4]])
	datadic[linekey]=[]

f=open(input,'r') #ASD_funseq2V2.bed
while 1:
	line = f.readline()
	if not line:
		break
	list = line.strip("\n").split("\t")
	l = "_".join([list[0],list[1],list[2],list[3],list[4]])
	datadic[l].append(list[5])

	
fw=open(output,'w')	
for key in datadic:
	if datadic[key]:
		fw.write("%s\t%s\n" % (key,datadic[key]))

#将1文件生成列表，将2文件中区间位于1文件区间中的输出到结果文件中
f1=open(database,'r')
datalist = list()
for line1 in f1.readlines():
	list1 = line1.strip("\n")
	datalist.append(list1)

fw=open(output,'w')
f=open(input,'r')

while 1:
	line = f.readline()
	if not line:
		break
	list = line.strip("\n").split("\t")			
	for l in datalist:
		list1 = l.split("_")
		if list1[0]==list[0] and int(list1[1])<= int(list[1]) and int(list1[2]) >= int(list[1]):
			fw.write("%s\t%s\n" % (line.rstrip("\n"),l))

#将1文件中的第一列作为字典的键并生成每行的列表，将2文件中的位于1列表中区间的点作为字典的键的值，将字典的值依次加到对应1文件每行的下边
#input--gene.txt, database--ASD.denovo.WGS.txt
f1=open(input,'r')
datadic = dict()
datalist = list()
for line1 in f1.readlines():
	list1 = line1.strip("\n").split("\t")
	linekey="_".join([list1[0],list1[1],list1[2],list1[3],list1[4],list1[5]])
	datalist.append(linekey)
	datadic[list1[0]] = []
f1.seek(0)

f2=open(database,'r')
while 1:
	line = f2.readline()
	if not line:
		break
	list = line.strip("\n").split("\t")			
	for l in datalist:
		list1 = l.split("_")
		if list1[1]==list[0] and int(list1[4])<= int(list[1]) and int(list1[5]) >= int(list[1]):
			datadic[list1[0]].append(line)

fw=open(output,'w')
for line1 in f1.readlines():
	fw.write("%s" % (line1))
	list1 = line1.strip("\n").split("\t")
	for i in range(len(datadic[list1[0]])):
		fw.write("%s" % (datadic[list1[0]][i]))

		
#读取vcf文件提取单个点并匹配原有文件--开头为#的正则匹配，以及in list和not in list		
f1=open(vcffile,'r')
f2=open(annofile,'r')#
f3=open(outfile,'w+')

annolist = list()
while 1:
	line2=f2.readline()
	if not line2:
		break
	list2=line2.strip("\n").split("\t")
	annolist.append(list2[0])

while 1:
	line1=f1.readline()
	if not line1:
		break
	pattern = re.compile('^#')		
	if pattern.search(line1):
		f3.write(line1)
	else:
		list1=line1.strip("\n").split("\t")
		seq1=[list1[0],list1[1],list1[3],list1[4]]
		keyval='_'.join(seq1)
		if keyval in annolist:
			f3.write(line1)

#取出特定模式的一行，并读取它后面的三行，直接=比re模式匹配要快
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
#or
pattern = "^@"
while 1:
	line = f.readline()
	if not line:
		break
	if re.findall(pattern,line):
		list = line.rstrip('\n').split(" ")
		if list[0] in listd:
			fw.write(line)
			fw.write(f.readline());fw.write(f.readline());fw.write(f.readline());
			listd.remove(list[0])
	if len(listd) == 0:
		break


		
f.close()
f1.close()
fw.close()
