import os,sys,time
from itertools import combinations
from subprocess import call
import commands

output = sys.argv[1]

pedlist3 = list()
#pedlist2 = ['E131','E132','E133','E134']
pedlist4 = ['E131','E132','E133','E134','E135','E136','E137','E138','E139','E140','E141','E142','E143','E144','E145','E146','E147','E148','E149','E150','E151','E152','E153','E154','E155','E156','E157','E158','E159','E160','E161','E162','E163','E164']
for ped in pedlist4:
	ped1 = ped+'M'
	ped2 = ped+'F'
	pedlist3.append(ped)
	pedlist3.append(ped1)
	pedlist3.append(ped2)

trilist0 = list(combinations(pedlist3, 2))

f3 = open(output,"w")
for trilist in trilist0:
	input1 = trilist[0]+".raresnp.txt"
	input2 = trilist[1]+".extreme.xls"

	input3 = trilist[1]+".raresnp.txt"
	input4 = trilist[0]+".extreme.xls"
	
	sort_cmd1 = 'awk -F \'\\t\' \'NR==FNR{a[$1_$2_$3_$4_$5]=1}NR>FNR{if(a[$1_$2_$3_$4_$5])print}\' %s %s |wc -l ' % (input1,input2)
	sort_cmd2 = 'awk -F \'\\t\' \'NR==FNR{a[$1_$2_$3_$4_$5]=1}NR>FNR{if(a[$1_$2_$3_$4_$5])print}\' %s %s |wc -l ' % (input3,input4)
	
	sort_cmd11 = 'wc -l %s' %(input1)
	sort_cmd12 = 'wc -l %s' %(input2)
	sort_cmd13 = 'wc -l %s' %(input3)
	sort_cmd14 = 'wc -l %s' %(input4)
	
	status1,res1=commands.getstatusoutput(sort_cmd1)
	status2,res2=commands.getstatusoutput(sort_cmd2)
	
	status11,res11=commands.getstatusoutput(sort_cmd11)
	status12,res12=commands.getstatusoutput(sort_cmd12)
	status13,res13=commands.getstatusoutput(sort_cmd13)
	status14,res14=commands.getstatusoutput(sort_cmd14)
	
	f3.write("%s\t%s\t%s\t%s\t%s\n" %(input1,input2,res1,res11,res12))
	f3.write("%s\t%s\t%s\t%s\t%s\n" %(input3,input4,res2,res13,res14))
	
f3.close()
