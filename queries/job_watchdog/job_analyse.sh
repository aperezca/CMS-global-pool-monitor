#!/bin/sh

# Monitor job performance over time  
# Antonio Perez-Calero Yzquierdo Nov 2017
WORKDIR="/home/aperez/status/watchdog"

# Classads:
# GlobalJobId WMAgent_RequestName WMAgent_SubTaskName CRAB_ReqName RequestCPUs RemoteWallClockTime ServerTime-JobStartDate ServerTime-EnteredCurrentStatus RemoteUserCpu RemoteSysCpu+RemoteUserCpu

# Select a file containing jobs data
file=$WORKDIR"/nfiles/monitorjobs_1516203902"

# Filter jobs according to their CPU eff
while read -r line; do
	prod_name=$(echo $line |awk '{print $2}')
	crab_name=$(echo $line |awk '{print $4}')
	job_id=$(echo $line |awk '{print $1}')
	ncpus=$(echo $line |awk '{print $5}')
	# wctime = ServerTime-EnteredCurrentStatus	
	wctime=$(echo $line |awk '{print $8}')
	# cputime = RemoteSysCpu+RemoteUserCpu
	cputime=$(echo $line |awk '{print $10}')
	
	if [[ $wctime -gt 3600 ]]; then
		#echo $wctime
		eff=$(echo print $cputime/$wctime*$ncpus | python)
		#if [[ $eff < 0.5 ]]; then
		if (( $(echo "$eff < 0.5" | bc -l) )); then
			echo $job_id $ncpus $wctime $cputime $eff
		fi
	fi
done<$file
