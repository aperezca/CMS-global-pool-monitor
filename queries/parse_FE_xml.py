#!/usr/bin/python

# Parser for Front End status xml
import sys
#import cElementTree as ElementTree
import xml.etree.cElementTree as ElementTree
file_name=sys.argv[1]
site_range=sys.argv[2]

#print "Must provide (1) FE xml file and (2) site range (T1s, T2s)"

#Get sites and entries from lists:
if site_range=="T1s": f_sites = open('/data/srv/aperezca/Monitoring/queries/entries/T1_sites', 'r')
if site_range=="T2s": f_sites = open('/data/srv/aperezca/Monitoring/queries/entries/T2_sites', 'r')
if site_range=="T3s": f_sites = open('/data/srv/aperezca/Monitoring/queries/entries/T3_sites', 'r')

sites = []
for line in f_sites.readlines(): sites.append(line.split('\n')[0])

#Parse FE status xml
#print file_name
tree = ElementTree.parse(file_name)
root = tree.getroot()

#Get element "factories" per FE group
groups=root.find('groups').getchildren()
my_groups=[]

#if site_range=="T1s":
#	for group in groups:
#		if group.get('name') == 'main' or group.get('name') == 't1prod': my_groups.append(group)
#if site_range=="T2s":
# For now, just monitor "main" group
for group in groups: 
	if group.get('name') == 'main': my_groups.append(group)

#print "----- selected groups -----"
#for g in my_groups: print g.get('name')

fact_dict={}
for group in my_groups:
	g_name=group.get('name')
	#print g_name
	factories=group.find('factories').getchildren()
	#print factories
	fact=[]
	for factory in factories:
		#name=factory.get('name').split('@')[0]
		fact.append(factory)	
	#print mcore_fact
	fact_dict[g_name]=fact

#print "----- all factories -----"
#print fact_dict

for site in sites:
	#print site
	for group in fact_dict.keys():
		#print group
		ReqIdle = 0
		for fact in fact_dict[group]:
			name = fact.get('name').split('@')[0]
			#print name
			if site in name: 
				try: ReqIdle+=int(fact.find('Requested').get('Idle'))
				except: continue
		print site, group, ReqIdle


# We could also try the following to get more information and crosscheck with factory view:
# a.find('MatchedCores').items()
# a.find('MatchedGlideins').items()
# a.find('MatchedJobs').items()
# a.find('Requested').items()

