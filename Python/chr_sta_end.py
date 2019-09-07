import sys, math, re

# function

print("## Start ...")

refFile=open("hg19.fa","r")
refIndex=open("hg19.fa.fai", "r")
indexDict = dict()
lengthRef = dict()
for line in refIndex:
    line_s = line.split("\t")
    indexDict[line_s[0]] = int(line_s[2])
    lengthRef[line_s[0]] = int(line_s[1])
refIndex.close()

def bed2fasta(chr,start,end):
    start = int(start)
    end = int(end)
    
    if end>lengthRef[chr]:
        sys.stderr.write("!! Warn: Window out of range on %s:%s-%s, the output sequence will be %s:%s-%s.\n"%(chr,start,end,chr,start,lengthRef[chr]))
        end = lengthRef[chr]
    
    if start<1:
        sys.stderr.write("!! Warn: Window out of range on %s:%s-%s, the output sequence will be %s:%s-%s.\n"%(chr,start,end,chr,1,end))
        start = 1
        
    index = start+int((start-1)/50)+indexDict[chr]-1
    refFile.seek(index)
    
    seq = ""
    for i in range(int((end-start)/50)+2):
        seq += refFile.readline().rstrip("\n")
    
    mySeq = seq[:end-start+1]
    
    return mySeq

# main
f = open("input.txt","r")
res = open("output.txt","w")
while 1:
    line = f.readline().rstrip()
    if not line:
        break
    s = re.split('\s+',line)
    pos = int(s[1])
    ch,st,en = s[0],pos-500,pos+500
    myseq = bed2fasta(ch,st,en)
    length = len(myseq)
    lines = math.ceil(length/50)
    res.write(">%s\n"%(re.sub('\s+',':',line)))
    for i in range(lines-1):
        res.write("%s\n"%(myseq[i*50:(i+1)*50]))
    res.write("%s\n"%(myseq[(lines-1)*50:]))

f.close()
res.close()

print("## Outfile was writed in \"output.txt\".")
print("## Done!")
print("## Press ENTER to exit.")
input()

