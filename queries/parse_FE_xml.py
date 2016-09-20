#!/usr/bin/python

# Parser for Front End status xml
import sys
import cElementTree as ElementTree
file_name=sys.argv[1]
site_range=sys.argv[2]

#print "Must provide (1) FE xml file and (2) site range (T1s, T2s)"

#Get sites and entries from lists:
if site_range=="T1s":
	f_entries = open('/home/aperez/entries/entries_all_T1s', 'r')
	f_sites = open('/home/aperez/entries/T1_sites', 'r')
if site_range=="T2s":
        f_entries = open('/home/aperez/entries/entries_all_T2s', 'r')
        f_sites = open('/home/aperez/entries/T2_sites', 'r')


sites = []
for line in f_sites.readlines(): sites.append(line.split('\n')[0])
all_entries=[]
for line in f_entries.readlines(): all_entries.append(line.split('\n')[0])

#print "------ Sites: ------"
#print sites
#print "------ Entries: ------"
#print all_entries

#Parse FE status xml
#print file_name
tree = ElementTree.parse(file_name)
root = tree.getroot()

#Get element "factories" per FE group
groups=root.find('groups').getchildren()
my_groups=[]

if site_range=="T1s":
	for group in groups:
		if group.get('name') == 'main' or group.get('name') == 't1prod': my_groups.append(group)
if site_range=="T2s":
        for group in groups:
		if group.get('name') == 'main': my_groups.append(group)

#print "----- selected groups -----"
#for g in my_groups: print g.get('name')
	

mcore_fact_dict={}
for group in my_groups:
	g_name=group.get('name')
	factories=group.find('factories').getchildren()
	#print factories
	mcore_fact=[]
	for factory in factories:
		name=factory.get('name').split('@')[0]
		if name in all_entries:
			#print name
			mcore_fact.append(factory)	
		else: continue
	#print mcore_fact
	mcore_fact_dict[g_name]=mcore_fact

#print "----- all factories -----"
#print mcore_fact_dict

for site in sites:
	for group in mcore_fact_dict.keys():
		ReqIdle = 0
		for fact in mcore_fact_dict[group]:
			name = fact.get('name')
			n=int(fact.find('Requested').get('Idle'))
			#print name, n
			if site in name: ReqIdle+=n
		print site, group, ReqIdle


# We could also try the following to get more information and crosscheck with factory view:
# a.find('MatchedCores').items()
# a.find('MatchedGlideins').items()
# a.find('MatchedJobs').items()
# a.find('Requested').items()

