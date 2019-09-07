#coding:utf-8
import sys, math, os, commands 
f1 =open("matrix.All_expDNMR.number","r")#matrix.expDNMR.number
f2 =open("matrix.All_expDNMR.gene","r")
line1 = f1.readlines()
length1 = len(line1)
line2 = f2.readlines()
#length2 = len(line2)
for i in range(1,length1):
	line1[i] = line1[i].strip("\n").split("\t")
	line2[i] = line2[i].strip("\n").split("\t")
	for j in range(2,15):
		number = int(line1[i][j])
		if number != 0:
			line2[i][j] = line2[i][j].split(";")
			gene_r = dict()
			os.environ['var2']=str(i)
			for k in range(number):
				gene = line2[i][j][k]
				os.environ['var1']=str(gene)
				#gene_dnmr = commands.getoutput('grep -w $var combine.expDNMR.xls')#调用shell命令得到结果
				gene_dnmr = commands.getoutput('awk  \'{if($1==\"\'$var1\'\")print}\' combine.All_expDNMR.txt')
				gene_dnmr = gene_dnmr.split("\t")
				gene_r[gene] = gene_dnmr[j-1]
			if j == 2:
				f3 = open("DNMR.GC-" + str(i),"w")
				for key in gene_r:
					f3.write("%s\t%s\n" %(key,gene_r[key]))
					#调用shell命令重排大小
				#os.environ['var2']=str(i)
				#os.system('sort -n -k 2 DNMR.CG-content-$var2 -o DNMR.CG-content-$var2')
				os.system('mv DNMR.GC-$var2 ./DNMR_GC')
			elif j == 3:
				f3 = open("DNMR.SC-" + str(i),"w")
				for key in gene_r:
					f3.write("%s\t%s\n" %(key,gene_r[key]))
				#os.environ['var2']=str(i)
				#os.system('sort -n -k 2 DNMR.sequ-context-$var2 -o DNMR.sequ-context-$var2')
				os.system('mv DNMR.SC-$var2 ./DNMR_SC')
			# elif j == 4:
				# f3 = open("DNMR.MF-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.multi-factor-$var2 -o DNMR.multi-factor-$var2')
				# os.system('mv DNMR.MF-$var2 ./DNMR_MF')
			elif j == 5:
				f3 = open("DNMR.DM-" + str(i),"w")
				for key in gene_r:
					f3.write("%s\t%s\n" %(key,gene_r[key]))
				#os.environ['var2']=str(i)
				#os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				os.system('mv DNMR.DM-$var2 ./DNMR_DM')
			# elif j == 6:
				# f3 = open("DNMR.SC-LoF-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.SC-LoF-$var2 ./DNMR_SC_LoF')
			# elif j == 7:
				# f3 = open("DNMR.SC-Mis-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.SC-Mis-$var2 ./DNMR_SC_Mis')
			# elif j == 8:
				# f3 = open("DNMR.SC-Syn-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.SC-Syn-$var2 ./DNMR_SC_Syn')
			# elif j == 9:
				# f3 = open("DNMR.MF-LoF-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.MF-LoF-$var2 ./DNMR_MF_LoF')
			elif j == 10:
				f3 = open("DNMR.MF-Mis-" + str(i),"w")
				for key in gene_r:
					f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				os.system('mv DNMR.MF-Mis-$var2 ./DNMR_MF_Mis')
			# elif j == 11:
				# f3 = open("DNMR.MF-Syn-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.MF-Syn-$var2 ./DNMR_MF_Syn')
			# elif j == 12:
				# f3 = open("DNMR.DM-LoF-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.DM-LoF-$var2 ./DNMR_DM_LoF')
			# elif j == 13:
				# f3 = open("DNMR.DM-Mis-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.DM-Mis-$var2 ./DNMR_DM_Mis')
			# elif j == 14:
				# f3 = open("DNMR.DM-Syn-" + str(i),"w")
				# for key in gene_r:
					# f3.write("%s\t%s\n" %(key,gene_r[key]))
				# #os.environ['var2']=str(i)
				# #os.system('sort -n -k 2 DNMR.DNA-methy-$var2 -o DNMR.DNA-methy-$var2')
				# os.system('mv DNMR.DM-Syn-$var2 ./DNMR_DM_Syn')
				
		
