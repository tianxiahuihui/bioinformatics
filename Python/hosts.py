#!/public/home/jcli/public/bin/python3
# -*- coding: utf-8 -*-
#author: Zhang Kun
#email :tianguolangzi@gmail.com
#vesion: 1.0
#too yang too naive
#date:2016-11-2 0:30
import sys,getopt,os,gzip,platform
from collections import defaultdict
import codecs
from bs4 import BeautifulSoup
import urllib.request
def usage():
	print(
	'''usage: python %s -option  <argement> 
					--url                 <STRING>   infile
					-o                    <STRING>   outfile 
					-s                    <platform>
					-r                    <Recovery>
					-h/--help                '''%sys.argv[0])
def system_type():
	global sysstr
	sysstr = platform.system()
	#if(sysstr =="Windows"):
	#	print ("Call Windows tasks")
	#elif(sysstr == "Linux"):
	#	print ("Call Linux tasks")
	#else:
	#	print ("Other System tasks")

def option():
	global url,outfile,Platform,Recovery
	try :
		opts ,args =getopt.getopt(sys.argv[1:],"o:s:r:h",["help","url=","Recovery="])
		#opts is (('-i','infile'),('-o','outflie'),('-c','no'),('-h',''))
		#args is something else.
		#print(opts)
	except getopt.GetoptError:
		print("get option error!")
		usage()
		sys.exit(2)
	for opt ,val in opts:
		if opt in ("-h","--help"):
			usage()
			sys.exit(1)
		else:
			if opt in ("--url",):
				url=val
			if opt in ('-o',):
				outflie=val
			if opt in ('-s',):
				Platform=val
			if opt in ('-r',"--Recovery"):
				Recovery=val
	if not 'Platform' in globals():
		Platform =0
	if not 'Recovery' in globals():
		Recovery =0
	if not "url"  in globals():
		url='https://github.com/racaljk/hosts/blob/master/hosts'
	if not 'outfile' in globals():
		if sysstr == 'Windows':
			for h in ['HOSTS','hosts','HOST','host']:
				if os.path.exists('C:\\Windows\\System32\\drivers\\etc\\'+h):
					outfile='C:\\Windows\\System32\\drivers\\etc\\'+h
					break
			else:
				#print('please check wheather the host file is existed!')
				#sys.exit(1)
				outfile='C:\\Windows\\System32\\drivers\\etc\\hosts'
		elif sysstr == "Linux":
			if not Platform:
				outfile='/etc/hosts'
			else:
				#手机
				outfile="/system/etc/hosts"
def get_host(url):
	ALL_url=[]
	if os.path.isfile(url):
		for line in open(url).readlines():
			#soup = BeautifulSoup(codecs.open('test_bf.html', encoding='UTF-8'),"html.parser")
			content=urllib.request.urlopen(line.strip(),timeout=20)
			soup=BeautifulSoup(content,"html.parser") #将网页内容转化为BeautifulSoup 格式的数据
			ALL_url+=soup.find_all(name='td', class_="blob-code blob-code-inner js-file-line")
	else:
		content=urllib.request.urlopen(url,timeout=20)
		soup=BeautifulSoup(content,"html.parser") #将网页内容转化为BeautifulSoup 格式的数据
		ALL_url+=soup.find_all(name='td', class_="blob-code blob-code-inner js-file-line")

	if os.path.exists(outfile):
		os.rename(outfile,outfile+".bk")

	with open(outfile,'w') as A1:
		for ht in ALL_url:
			A1.write(ht.string+"\n")

if __name__== '__main__':
	system_type()
	option()
	if not Recovery:
		get_host(url)
		#使用代理后,查找谷歌ip
		#os.system('nslookup google.com 8.8.8.8')
	else:
		if os.path.exists(outfile+".bk"):
			os.remove(outfile)
			os.rename(outfile+".bk",outfile)
			print("请重新")
		else:
			print('恢复host失败,因为没有备份')
	if sysstr == 'Windows':
		os.system('ipconfig /flushdns')
	elif sysstr == "Linux":
		if not Platform:
			os.system('sudo rcnscd restart')
		else:
			print("或许要重启手机")
