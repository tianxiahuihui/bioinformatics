import requests, sys,os,time
import json
from collections import defaultdict
from multiprocessing import Pool,Manager
import math

#python ~/pipeline/code/multimatch.py peak.bed peak.multialign.txt jobid cpu
peakFile = sys.argv[1]
outputfile = sys.argv[2]
names = sys.argv[3]
cpu = sys.argv[4]

server1 = "http://rest.ensembl.org"
begin_exp = "/alignment/region/"
target_species = "homo_sapiens/"
data_set = ":1?species_set_group=mammals;method=EPO;"
show_set = "display_species_set=homo_sapiens;display_species_set=pan_troglodytes;display_species_set=mus_musculus;display_species_set=rattus_norvegicus"

manager=Manager()
def runjson(rangelist1,nu):
	match = dict()
	outputlins = []
	for target_region in rangelist1:
		match[target_region] = dict()
		url_link = server1 + begin_exp + target_species + target_region + data_set + show_set
		if requests.get(url_link, headers={"Content-Type": "application/json"}):
			r = requests.get(url_link, headers={"Content-Type": "application/json"})
			if not r.ok:
				r.raise_for_status()
				continue
			decoded = r.json()
			res1 = decoded[0]['alignments']
			len1 = len(res1)
			for i in range(len1):
				#print(res1[i])
				if res1[i]['species'] in ['homo_sapiens','pan_troglodytes','mus_musculus','rattus_norvegicus']:
					#print([res1[i]['seq_region'],res1[i]['start'],res1[i]['end'],res1[i]['strand']])
					match[target_region][res1[i]['species']] = '_'.join([str(res1[i]['seq_region']),str(res1[i]['start']),str(res1[i]['end']),str(res1[i]['strand'])])
			if 'homo_sapiens' not in match[target_region].keys():
				match[target_region]['homo_sapiens'] = 'NA'
			if 'pan_troglodytes' not in match[target_region].keys():
				match[target_region]['pan_troglodytes'] = 'NA'
			if 'mus_musculus' not in match[target_region].keys():
				match[target_region]['mus_musculus'] = 'NA'
			if 'rattus_norvegicus' not in match[target_region].keys():
				match[target_region]['rattus_norvegicus'] = 'NA'
			lines = '\t'.join([target_region,match[target_region]['homo_sapiens'],match[target_region]['pan_troglodytes'],match[target_region]['mus_musculus'],match[target_region]['rattus_norvegicus']])
			outputlins.append(lines + "\n")
			print(lines)
	with open(names+".%d.tmp"%nu,'w') as A1:
		A1.writelines(outputlins)
	print('%d is cleaned!'%nu)
	
rangelist = list()
f1 = open(peakFile, "r")
#f1.readline()
for line in f1.readlines():
	#print(line)
	words = line.strip().split("\t")
	chrome = words[0]
	chr1 = chrome.replace("chr", "")
	start1 = words[1]
	end1 = words[2]
	#strand = words[4]
	#id = words[3]
	target_region = chr1 + ":" + str(start1)  + "-" + str(end1)
	rangelist.append(target_region)
	
f1.close()

pool = Pool(processes = int(cpu))
num=len(rangelist)
print(num)
num2=math.ceil(float(num)/int(cpu))
n=num//num2
print(n)
time.sleep(5)
for i in range(n):
    pool.apply_async(runjson, (rangelist[i*num2:(i+1)*num2],i))		
pool.apply_async(runjson, (rangelist[n*num2:num],n))
pool.close()
pool.join()
	
if os.path.exists(outputfile):
	os.system('rm '+outputfile)
os.system('cat '+names+'*tmp >' +outputfile)
#os.system('rm '+names+'*tmp')	
	
