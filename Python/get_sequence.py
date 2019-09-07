#!/public/home/jcli/public/bin/python3
# -*- coding: utf-8 -*-
#author: Zhang Kun
#vesion: 1.0
#too yang too naive
#date:2016-8-20 15:30
import getopt
import time,sys,os
try :
	opts ,args =getopt.getopt(sys.argv[1:],"h",["fa_dir=","help","canshu=","batch=","region="])
except getopt.GetoptError:
	print("get option error!")
	sys.exit(2)
for opt ,val in opts:
	if opt in ("-h","--help"):
		sys.exit(1)
	else:
		if opt in ("--fa_dir",):
			fa_dir=val
		if opt in ("--canshu",):
			canshu=val
		if opt in ("--batch",):
			batch=val
			if os.path.exists(batch):
				if not os.path.isfile(batch):
					print(batch,"is not file!")
					sys.exit(2)
			else:
				print(batch,"is not existed!")
				sys.exit(2)
		if opt in ("--region",):
			region=int(val)
if "fa_dir" not in locals():
	fa_dir= "/public/home/jcli/public/database/hg19/"
else:
	if os.path.exists(fa_dir):
		if os.path.isfile(fa_dir):
			fa_dir=os.path.dirname(fa_dir)
	else:
		fa_dir="/public/home/jcli/public/database/hg19/"
if not fa_dir.endswith("/"):fa_dir+="/"
if "canshu" not in locals() and len(args)>0:canshu=args[0]
def get_sequence(fa_dir,CHR):
	with open(fa_dir+"%s.fa"%CHR,"r") as A1:
		ll=A1.readlines()
		del ll[0]
		ll="".join([l.strip() for l in ll])
		return ll
if "canshu" in locals():
	CHR=canshu.split(":")[0]
	if "-" in canshu:
		start,end=canshu.split(":")[1].split("-")
	else:
		start=end=canshu.split(":")[1]
	start=int(start)-1
	end=int(end)-1
	seq=get_sequence(fa_dir,CHR)[start:end+1]
	print("<-%s %d-%d"%(CHR,start+1,end+1))
	print(seq)
	print("the length of sequence is %d"%len(seq))
if "batch" in locals():
	if "region" not in locals():region=1
	#默认批量跑的时候基本格式是chr start end,取区域的一段序列
	#单点格式该参数要设置成0,基本格式是chr pos,取单点的序列
	batch_CHR={}
	with open(batch,"r") as A2:
		if region:
			for line in A2.readlines():
				temp=line.strip().split()
				CHR=temp[0]
				if CHR not in batch_CHR:
					batch_CHR[CHR]=get_sequence(fa_dir,CHR)
				start,end=temp[1:3]
				start=int(start)-1
				end=int(end)-1
				seq=batch_CHR[CHR][start:end+1]
				print(line.strip()+"\t"+seq)
		else:
			for line in A2.readlines():
				temp=line.strip().split()
				CHR=temp[0]
				if CHR not in batch_CHR:
					batch_CHR[CHR]=get_sequence(fa_dir,CHR)
				#对于单点的,使用大写字母,而不是原始碱基,原始碱基有大小写之分
				print(line.strip()+"\t"+batch_CHR[CHR][int(temp[1])-1])
