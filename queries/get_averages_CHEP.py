#!/usr/bin/python2.6

# Get averages for data collected by monitoring scripts
import sys, commands
try:
	file_name=sys.argv[1]
except:
	print "arg 1= file, arg 2= start date, arg 3 = end date arg 4 = get daily values True or False. Dates in mm/dd/yyyy format"

# Define seach limits
try:
	date_min=sys.argv[2]
	comm="date -d "+str(date_min)+" -u +%s"
	print "from ",date_min
	date_min_s=int(commands.getoutput(comm))
except:
	#date_min_s=0
	date_min_s = int(open(file_name, 'r').readlines()[0].split('\n')[0].split(' ')[0])
	print "start since the first value", date_min_s

try:
	date_max=sys.argv[3]
	comm="date -d "+str(date_max)+" -u +%s"
        print "to ", date_max
	date_max_s=int(commands.getoutput(comm))
except:
	#date_max_s=9999999999
	date_max_s = int(open(file_name, 'r').readlines()[-1].split('\n')[0].split(' ')[0])
	print "take all values found until", date_max_s

try:
	daily=sys.arg[4]
	print "Requested daily averages:", daily
except:
	daily=False

#daily=True	
#print "from ", date_min_s, "to ", date_max_s
if not daily: print "requested single average values for the whole range"

# Get and filter entries in the time range by the first field which is timestamp

def lines_in_range( file, min_s, max_s ):
	f = open(file, 'r')
	lines=[]
	for rline in f.readlines():
		line = rline.split('\n')[0].split(' ')
		#print line
		if int(line[0])>min_s and int(line[0])<max_s: lines.append(line)
		else: continue
	print "found", len(lines), "entries"
	return lines

# Get and print averages 
def average( lines ): 
	#first transpose lines into columns:
	columns = {}
	if len(lines)>0:
		entries = len(lines)
		dim_0 = len(lines[0])
		dim_1 = len(lines[1])
		dim_2 = len(lines[2])
		dim = max([dim_0, dim_1, dim_2])
		for i in range(dim):
			columns[i]=[]
			for line in lines:
				try:
					columns[i].append(int(line[i]))
				except:
					columns[i].append(0)
	else:
		print "found no points matching that time interval"
		dim=0

	#print columns
	#print len(columns), entries, dim

	results=[]
	# Get average, min, max:
	#for i in range(dim): results.append( [float(sum(columns[i])/entries), min(columns[i]), max(columns[i])])
	# Get only average:
	for i in range(dim): results.append(float(sum(columns[i])/entries))
	return results
#---------------
if not daily:
	my_lines = lines_in_range(file_name, date_min_s, date_max_s)
	results = average(my_lines)
	#print results
	print results[2], results[4]#, float(results[4]/results[2])
else:
	start=date_min_s
	end=start+86400
	i=1
	while end<date_max_s:
        	date_start=commands.getoutput("date -d @"+str(start)+" -u +%Y-%m-%d")
		my_lines = lines_in_range(file_name, start, end)
		if len(my_lines)!=0: 
			results = average(my_lines)
			print date_start, results[2], results[4]
			start=end
                        end+=86400
                        i+=1
		else:
			start=end
			end+=86400
			i+=1
			continue

#print results[2]
#print float(results[4]/results[2])
#for i in range(dim-1): print results[i+1]

