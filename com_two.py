import os,sys,time
import pandas as pd
import random
from itertools import combinations
from multiprocessing import Pool,Manager
#1.将文件内容转换为11和10格式
#2.任意两列组合生成新列，写入文件
def change1(x):
	if isinstance(x,(int,float)):
		if x == 0:
			return str(10)
		elif x >= 1 and x<=500:
			return str(11)
		else:
			return x				
	else:
		return x
		
		
caseinput = sys.argv[1]
comoutput = sys.argv[2]

df10 = pd.read_csv(caseinput, header = 0) 
df11 = df10.set_index('Unnamed: 0')
manager=Manager()

#读取列和行，判断每列的>0的长度，然后确定是否删除该行
list1 = df11.iloc[:,0]  #列
list2 = df11.iloc[0,:] #行
list5 = df11.columns.values.tolist()  #得到列名的标题

df11=df11.applymap(change1)

df1=df11
for i in range(3,len(list2)):
	if len(df11.iloc[:,i][df11.iloc[:,i]=='11'])<10:
		df1 = df1.drop(list5[i],axis=1)

list4 = df1.iloc[0,3:] #行
list3 = df1.columns.values.tolist()  #得到列名的标题

rmlist = ['chr','end','start']
for i in rmlist:
	list3.remove(i)
	
list3.sort()
twolist = list(combinations(list3, 2))

def com2(twolistfen,nu):
	df = df1.iloc[:,:3]
	for twolist1 in twolistfen:
		onelist1 = twolist1[0]
		onelist2 = twolist1[1]
		twolist2 = [onelist1,onelist2]
		twolist2.sort()
		colname = '-'.join(twolist2)
		df[colname] = (df1[onelist1]=='11') & (df1[onelist2]=='11')
		if True in df[colname].value_counts():
			if df[colname].value_counts()[True]<10:
				df.drop(colname,axis=1,inplace=True)
			else:
				df[colname].replace([True,False], ['11','10'], inplace = True)
		else:
			df.drop(colname,axis=1,inplace=True)	
	df.to_csv('com2_%s.csv' %(nu))		
			
pool = Pool(processes = 20)
num=len(twolist)
n=num//100
time.sleep(2)
for i in range(n+1):
    pool.apply_async(com2, (twolist[i*100:(i+1)*100],i))
pool.close()
pool.join()

filelist = []
for i in range(n+1):
	filename = 'com2_'+str(i)+'.csv'
	filelist.append(filename)

df1 = df1.reset_index()
for i in range(n+1):
	df2 = pd.read_csv(filelist[i], header = 0)
	df1 = pd.merge(df1, df2, on=['Unnamed: 0','chr', 'end', 'start'], how='outer')
	
df1 = df1.set_index('Unnamed: 0')
df1.to_csv(comoutput)
