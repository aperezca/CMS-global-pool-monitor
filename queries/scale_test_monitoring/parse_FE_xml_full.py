#!/usr/bin/python

# Parser for Front End status xml
import sys
import cElementTree as ElementTree

file_name=sys.argv[1]
#print file_name

#Parse FE status xml
tree = ElementTree.parse(file_name)
#tree = ElementTree.parse("/home/aperez/FE_status/FE_CERN_status.xml")
root = tree.getroot()

#Get element "factories" per FE group
groups=root.find('groups').getchildren()
my_groups=[]

# I check for the time being main and t1prod groups
for group in groups:
	my_groups.append(group)
	#if group.get('name') == 'main' or group.get('name') == 't1prod': my_groups.append(group)

fact_dict={}
for group in my_groups:
	g_name=group.get('name')
	factories=group.find('factories').getchildren()
	#print factories
	all_fact=[]
	for factory in factories:
		name=factory.get('name').split('@')[0]
		all_fact.append([name,factory])	
	fact_dict[g_name]=all_fact

t1prod_T1_mcore=0
main_T1_mcore=0
main_T2_mcore=0
main_T2_score=0
main_T3_score=0
for group in fact_dict.keys():
	#print group
	for fact in fact_dict[group]:
		#print fact
		name = fact[0]
		down=fact[1].get('Down')
		#Skip if entry in downtime:
		if down=='Down': continue
		cpus=fact[1].find('Attributes').get('GLIDEIN_CPUS')
		#print name, cpus
		if cpus==None or cpus=="auto": continue
		else: n_cpus=int(fact[1].find('Attributes').get('GLIDEIN_CPUS'))
		#Get requested idle glidens:
		n_idle=int(fact[1].find('Requested').get('Idle'))
		#Print all values:
		#print name, down, n_cpus, n_idle
		#Do the accounting:
		if 'T1_' in name:
			#if group=='t1-test': t1prod_T1_mcore+=n_cpus*n_idle
			main_T1_mcore+=n_cpus*n_idle
		if 'T2_' in name:
			if n_cpus>1: main_T2_mcore+=n_cpus*n_idle
			if n_cpus==1: main_T2_score+=n_idle
		if 'T3_' in name: main_T3_score+=n_idle

print t1prod_T1_mcore, main_T1_mcore, main_T2_mcore, main_T2_score, main_T3_score
