import urllib.request as request
from bs4 import BeautifulSoup
import re
import time
import random

def url_open(url):
	req = request.Request(url)
	req.add_header('User-Agent','Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:36.0) Gecko/20100101 Firefox/36.0')
	try:
		response = request.urlopen(req,timeout=10)
		return response.read()
	except:
		print("连接超时,默认等待10秒")

	
def find(link):
	fhtml = url_open(link)
	if fhtml:
		fsoup = BeautifulSoup(fhtml, 'html.parser')
	else:
		return link
	dd = fsoup.find('dd', id='iftglc1')
	if dd:
		ul = dd.find('ul', class_="dd_list")
		if ul:
			res = ul.contents[1].string.strip()
			print(res)
		else:
			res = dd.string.strip()
			print(res)
	else:
		res = link
		print(res)
	time.sleep(1)
	return res
	
def has_href(tag):
    return tag.has_attr('href')
	
def getAllLinks(url):
	fhtml = url_open(url)
	if fhtml:
		fsoup = BeautifulSoup(fhtml, 'html.parser')
	else:
		return
	links = fsoup.find_all(has_href)
	res = [url+link['href'] for link in links if link['href'][-3:]=='htm']
	return res
	
def OMIM():
	with open('tmp.txt') as f:ids = [line.strip() for line in f]
	links = ['https://omim.org/entry/'+id for id in ids]
	for link in set(links):find(link)
	
if __name__ == "__main__":
	with open("new.8.bp.snp.clinvitae.txt") as f:lines = [line.strip().split('\t') for line in f]
	del lines[0]
	links = [l[-1] for l in lines]
	#sample = random.sample(list(range(len(links))),100)
	#for i in sample:find(links[i])
	result = [[l,find(l[-1])] for l in lines]
	with open("res.new.8.bp.snp.clinvitae.txt","w") as f:
		for line in result:f.write('\t'.join(line)+'\n')
