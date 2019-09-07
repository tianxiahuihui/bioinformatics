import os,sys,time
import pandas as pd
import random
from multiprocessing import Pool,Manager
import math
import numpy as np

caseinput = sys.argv[1]
coninput = sys.argv[2]
rroutput = sys.argv[3]
poutput = sys.argv[4]
        
df1 = pd.read_csv(caseinput, header = 0,dtype=str) 
df2 = pd.read_csv(coninput, header = 0,dtype=str) 


#之前根据ASD文件生成列名 分别得到所有  得到所有列名的SNV文件

#读取列和行，判断每列的>0的长度，然后确定是否删除该行
# list1 = df1.iloc[:,0]  #列
# list2 = df1.iloc[0,:] #行
list3 = df1.columns.values.tolist()  #得到列名的标题
list4 = df2.columns.values.tolist()  #得到列名的标题
list5 = list(set(list3+list4))   #还需要移除一些list

len1 = len(df1.iloc[:,0])
len2 = len(df2.iloc[:,0])
rmlist = ['Unnamed: 0','chr','end','start']
for i in rmlist:
    list5.remove(i)
    
#遍历ASD和control QC之后的文件，判断ASD和control大于0的数目 计算OR和RR值  生成新文件  
for colname in list5:
    if colname not in list3:
        df1[colname] = str('10')
    if colname not in list4:
        df2[colname] = str('20')
    
manager=Manager()   
    
rrdict1 = manager.dict() 
rrdict2 = manager.dict() 
for rowlist1 in list5:
    rrdict1[rowlist1] = 0
    rrdict2[rowlist1] = 0

srdict1 = dict()
srdict2 = dict()
fw2 = open(rroutput,"r")
while 1:
    line1 = fw2.readline().strip("\n")
    list1 = line1.split("\t")
    if not line1:
        break
    srdict1[list1[0]] = list1[4]
    srdict2[list1[0]] = list1[5]
# print(list3)
# print(list4)
# print(list5)
#模拟10000次，合并case和control，计算RR值
randomnum = 10000

def permu(rowlists,nu,len1,len2,list3,list4):
    #print('he')
    Check_list3=0
    Check_list4=0
    #print('he')
    def getlist1(rowlist):
        list1 = np.array(df1[rowlist]).tolist()
        list2 = np.array(df2[rowlist]).tolist()
        return list1,list2
    def getlist2(rowlist):
        list1 = np.array(df1[rowlist]).tolist()
        list2 = ['20']*len2 
        return list1,list2
    def getlist3(rowlist):
        list1 = ['10']*len1
        list2 = np.array(df2[rowlist]).tolist()
        return list1,list2
    def getlist4(rowlist):
        list1=[]
        list2=[]
    Dictfunc={(1,1):getlist1,(1,0):getlist2,(0,1):getlist3,(0,0):getlist4}
    #print('he')
    k = 0	
    for rowlist in rowlists:
        #print(rowlist)
        while 1:
            if k > randomnum:
                break
            k += 1
            #print(k)
            #print(rowlist)
            
            Check_list3=1 if rowlist in list3 else 0
            Check_list4=1 if rowlist in list4 else 0
            list1,list2=Dictfunc[(Check_list3,Check_list4)](rowlist)
            
            #print(len(list1))
            rannum1 = [random.randint(0,1) for j in range(len1)]
            rannum2 = [random.randint(0,1) for j in range(len2)]
            list11 = list()
            list21 = list()
            for j in range(len1):
                if rannum1[j]==0:
                    if list1[j]=='10':
                        list11.append('20')
                    elif list1[j]=='11':
                        list11.append('21')
                elif rannum1[j]==1:
                    list11.append(list1[j])
            for j in range(len2):
                if rannum2[j]==0 :
                    if list2[j]=='20':
                        list21.append('10')
                    elif list2[j]=='21':
                        list21.append('11')
                elif rannum2[j]==1:
                    list21.append(list1[j])
            list31 = list11+list21
            #print('hello')
            #print(len(list31))
            a = {}
            for key in list(set(list31)):
                a[key] = list31.count(key)
            # print(a['11'])
            # print(a['21'])
            # print(a['20'])
            # print(a['10'])
            casepos    = a['11'] if a['11'] else 0
            controlpos  = a['21'] if a['21'] else 0
            caseneg    = a['10'] if a['10'] else 0
            controlneg = a['20'] if a['20'] else 0
            # print(casepos)
            # print(caseneg)
            # print(controlpos)
            # print(controlneg)
    
            # if casepos == 0 or controlpos == 0 or caseneg == 0 or controlneg == 0:
                # casepos += 0.5
                # caseneg += 0.5
                # controlneg += 0.5
                # controlpos += 0.5       

            #print('hello')
            RR1 = (casepos/(casepos+controlpos))/(caseneg/(caseneg+controlneg))
            RR2 = (controlpos/(casepos+controlpos))/((controlneg)/(caseneg+controlneg))
            #print(RR1)
            # print(RR2)
            if RR1<float(srdict1[rowlist]):
                rrdict1[rowlist]+=1
            if RR2<float(srdict2[rowlist]):
                rrdict2[rowlist]+=1
            #print('hello')
            #print(rrdict1[rowlist])

pool = Pool(processes = 20)
num=len(list5)
num2=math.ceil(float(num)/20)
n=num//num2
time.sleep(5)
for i in range(n+1):
    pool.apply_async(permu, (list5[i*num2:(i+1)*num2],i,len1,len2,list3,list4))
pool.close()
pool.join()

print('hello2')

#print(rrdict1)

#把p value加入文件
pvadict1 = dict()   
pvadict2 = dict()   

#print('hello3')

for rowlist2 in list5:
    # print(srdict1[rowlist2])
    # print(srdict2[rowlist2])    
    # print(rrdict1[rowlist2])
    # print(rrdict2[rowlist2])
    k1 = rrdict1[rowlist2]
    k2 = rrdict2[rowlist2]
    if(k1==0):
        k1=1
    if(k2==0):
        k2=1    
    pvadict1[rowlist2]=k1/randomnum
    pvadict2[rowlist2]=k2/randomnum
    
#print('hello4')
fw2.seek(0)
fw3 = open(poutput,"w")
while 1:
    line1 = fw2.readline().strip("\n")
    list1 = line1.split("\t")
    if not line1:
        break
    if list1[0] in pvadict1:
        fw3.write("%s\t%s\t%s\n" %(line1,pvadict1[list1[0]],pvadict2[list1[0]]))


fw2.close()
fw3.close()
    
    
