#!/usr/bin/python

# Get averages for data collected by monitoring scripts
import sys, commands
try:
	file_name=sys.argv[1]
except:
	print "arg 1= file, arg 2 = mode, arg 3 = start date, arg 4 = end date. Dates in mm/dd/yyyy format"
#comm="date -u -d @"+str(date_min)

try:
	mode=sys.argv[2]
	#print "selected", mode, "mode"
	#if mode is not "time" and mode is not "histo": print "specify mode: histo or time series"
except:
	#print "will try as time series"
	mode="time"

if mode=="time":
	try:
		date_min=sys.argv[3]
		comm="date -d "+str(date_min)+" -u +%s"
		#print "from ",date_min
		date_min_s=int(commands.getoutput(comm))
	except:
		date_min_s=0

	try:
		date_max=sys.argv[4]
		comm="date -d "+str(date_max)+" -u +%s"
        	#print "to ", date_max
		date_max_s=int(commands.getoutput(comm))
	except:
		date_max_s=9999999999
	
#	try:
#		print "get entries from from",date_min,"to",date_max
#		print 'dates for interval in seconds:', date_min_s, date_max_s
#	except:
#		print "arg 1= file, arg 2 = mode, arg 3 = start date, arg 4 = end date. Dates in mm/dd/yyyy format"

f = open(file_name, 'r')
my_lines=[]

# Filter entries by the first field which is timestamp in time series mode
for rline in f.readlines():
	line = rline.split('\n')[0].split(' ')
	#print line
	if mode=="histo": my_lines.append(line)
	if mode=="time":
		if int(line[0])>date_min_s and int(line[0])<date_max_s: my_lines.append(line)
		else: continue

# Transpose lines into columns:
columns = {}
if len(my_lines)>0:
	entries = len(my_lines)
	dim_0 = len(my_lines[0])
	dim_1 = len(my_lines[1])
	dim_2 = len(my_lines[2])
	dim = max([dim_0, dim_1, dim_2])
	for i in range(dim):
		columns[i]=[]
		for line in my_lines:
			try:
				columns[i].append(int(line[i]))
			except:
				columns[i].append(0)
else:
	print "found no points matching that time interval"

#print columns
#print len(columns), entries, dim

results=[]
for i in range(dim): results.append( [float(sum(columns[i])/entries), min(columns[i]), max(columns[i])])
        #for i in range(dim): results.append(float(sum(columns[i])/entries))

if mode=="time": 
	for i in range(dim-1): print results[i+1]
else: 
	for i in range(dim): print results[i]

