import requests, sys
import json
from collections import defaultdict

#python ~/pipeline/code/multimatch.py peak.bed peak.multialign.txt
peakFile = sys.argv[1]
output = sys.argv[2]

server1 = "http://rest.ensembl.org"
begin_exp = "/alignment/region/"
target_species = "homo_sapiens/"
data_set = ":1?species_set_group=mammals;method=EPO;"
show_set = "display_species_set=homo_sapiens;display_species_set=pan_troglodytes;display_species_set=mus_musculus;display_species_set=rattus_norvegicus"

def runjson(rangelist1):
	for i in range(len(rangelist1)):
		target_region = rangelist1[i]
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
			print(match[target_region]['homo_sapiens'])

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

match = defaultdict()
for i in range(len(rangelist)):
	target_region = rangelist[i]
	match[target_region] = dict()

runjson(rangelist)
fw = open(output, "w")
for key1 in match:
	if 'homo_sapiens' not in match[key1].keys():
		match[key1]['homo_sapiens'] = 'NA'
	if 'pan_troglodytes' not in match[key1].keys():
		match[key1]['pan_troglodytes'] = 'NA'
	if 'mus_musculus' not in match[key1].keys():
		match[key1]['mus_musculus'] = 'NA'
	if 'rattus_norvegicus' not in match[key1].keys():
		match[key1]['rattus_norvegicus'] = 'NA'
	fw.write("%s\t%s\t%s\t%s\t%s\n" %(key1,match[key1]['homo_sapiens'],match[key1]['pan_troglodytes'],match[key1]['mus_musculus'],match[key1]['rattus_norvegicus']))
fw.close()


