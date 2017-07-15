import sys, re, getopt, os
from pandas import *
import pandas as pd

def usage():
    print("usage: python3 %s -option <argument>" %sys.argv[0])
    print("   -i     <STRING>   inputfile")
    print("   -d     <STRING>   database")
    print("   -o     <STRING>   outfile")
    print("   -s     <STRING>   sourcefile")
    print("   -h/--help                ")
	
try:
    opts, args = getopt.getopt( sys.argv[1:], "i:d:o:s:h", ["help"] )
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
            number = int(val)
        if opt in ( "-s", ):
            srinput = val

df = pd.read_csv(input,low_memory=False)
df1 = pd.read_csv(input,header=None)

random = 10000

rrdict = dict()
list1 = df1.iloc[0,:]
for i in range(4,len(list1)-3):
	rrdict[list1[i]] = list()

for j in range(random):
	df2 = df.sample(n=number)
	for i in range(4,len(list1)-3):
		ratio1=len(df2.iloc[:,i][df2.iloc[:,i]>0])/number
		rrdict[list1[i]].append(str(ratio1))
	
srdict = dict()
df3 = pd.read_csv(srinput)
	
for i in range(4,len(list1)-3):
	ratio2=len(df3.iloc[:,i][df3.iloc[:,i]>0])/len(df3.iloc[:,0])
	srdict[list1[i]]=str(ratio2)
	
pvadict = dict()	
for i in range(4,len(list1)-3):
	k = 0
	for j in range(random):
		if float(rrdict[list1[i]][j]) > float(srdict[list1[i]]):
			k=k+1
	if(k==0):
		k=1
	pvadict[list1[i]]=k/random

fout = open(output,"w")	
for key in rrdict:
	#fout.write("%s\t%s\t%s\t%s\n" % (key,";".join(rrdict[key]),pvadict[key],srdict[key]))
	fout.write("%s\t%s\t%s\n" % (key,pvadict[key],srdict[key]))
