#!/bin/sh
source /etc/profile.d/condor.sh

# Count CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr. 2016

collector=$(/home/aperez/collector.sh)

# Info on job status: http://pages.cs.wisc.edu/~adesmet/status.html
# more info:          https://htcondor-wiki.cs.wisc.edu/index.cgi/wiki?p=MagicNumbers

total_jobcores_run=0
total_jobcores_idle=0
total_jobcores_held=0

for schedd in $(condor_status -pool $collector -schedd -af Name); do
	#echo $schedd
	condor_q -pool $collector -name $schedd -af JobStatus RequestCPUs |sort |uniq -c >/home/aperez/status/stats_jobcores
	while read -r line; do
		#echo $line
		state=$(echo $line |awk '{print $2}')
		cores=$(echo $line |awk '{print $1*$3}')
		#echo $line '--->' $state $cores
		if [[ $state == "1" ]]; then let total_jobcores_idle+=$cores; fi
		if [[ $state == "2" ]]; then let total_jobcores_run+=$cores; fi
		if [[ $state == "5" ]]; then let total_jobcores_held+=$cores; fi
	done</home/aperez/status/stats_jobcores
done

echo $total_jobcores_run $total_jobcores_idle $total_jobcores_held

date_all=`date -u +%s`
echo $date_all $total_jobcores_run $total_jobcores_idle $total_jobcores_held >>/home/aperez/out/jobcores_size
