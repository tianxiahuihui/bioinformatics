import sys, re, getopt, os,time
from multiprocessing import Pool,Manager
from collections import defaultdict
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

manager=Manager()
#all_data=manager.dict()

def run(lines,nu):
        cons=[]
        for line in lines:
                #print(line)
                con=line.strip()
                tmp=con.split()
                #print(tmp)
                A=int(tmp[1])
                B=int(tmp[2])
                for i in range(A,B+1):
                        cons.append(tmp[0]+"_"+str(i)+":"+"_".join(tmp)+"\n")
        with open("%d.tmp"%nu,'w') as A1:
                A1.writelines(cons)
        print('%d is cleaned!'%nu)
f1=open(database,'r')
#manager=Manager()
#all_data=manager.dict()
pool = Pool(processes = 10)
ALLlines=f1.readlines()
num=len(ALLlines)
n=num//1000
#for i in range(n+1):all_data[i]={}
#print(len(all_data))
time.sleep(2)
B={}
for i in range(n):
        pool.apply_async(run, (ALLlines[i*1000:(i+1)*1000],i))
		
pool.apply_async(run, (ALLlines[n*1000:num],i))

pool.close()
pool.join()
f1.close()
all_data=defaultdict(lambda:[])
if os.path.exists('all.tmp'):os.system('rm all.tmp')
os.system('cat *tmp >all.tmp')
with open('all.tmp','r') as A2:
        for line in A2.readlines():
                tmp=line.strip().split(":")
                all_data[tmp[0]].append(tmp[1])

fw=open(output,'w')
f=open(input,'r')
while 1:
        line = f.readline()
        if not line:
                break
        tmp = line.strip().split()
        key=tmp[0]+"_"+tmp[1]
        if len(all_data[key])>0:fw.write(line.strip()+"\t"+ "\t".join(all_data[key]) +"\n")
f.close()
fw.close()
