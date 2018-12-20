#!/bin/sh
source /etc/profile.d/condor.sh

# Count CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr, Nov 2016
# Feb 2017: query from child collector

collector=$(/home/aperez/collector.sh):9620

# Info on job status: http://pages.cs.wisc.edu/~adesmet/status.html
# more info:          https://htcondor-wiki.cs.wisc.edu/index.cgi/wiki?p=MagicNumbers

total_jobcores_run=0
total_jobcores_idle=0
echo "getting list of schedds"
condor_status -pool $collector -schedd -af Name CMSGWMS_Type>/home/aperez/status/status_allschedds

cat /home/aperez/status/status_allschedds |grep prod >/home/aperez/status/status_schedds_prod
cat /home/aperez/status/status_allschedds |grep crab >/home/aperez/status/status_schedds_crab
cat /home/aperez/status/status_allschedds |grep -v prod |grep -v crab >/home/aperez/status/status_schedds_other

for i in 'prod' 'crab' 'other'; do
	#echo "Schedds:" $i
        let jobcores_run_$i=0
        let jobcores_idle_$i=0
	for schedd in $(cat /home/aperez/status/status_schedds_$i |awk '{print $1}'); do
		#echo $schedd
		condor_q -pool $collector -name $schedd -af JobStatus RequestCPUs |sort |uniq -c >/home/aperez/status/stats_jobcores_$schedd
		while read -r line; do
			#echo $line
			state=$(echo $line |awk '{print $2}')
			cores=$(echo $line |awk '{print $1*$3}')
			#echo $line '--->' $state $cores
			if [[ $state == "1" ]]; then 
				let total_jobcores_idle+=$cores;
				let jobcores_idle_$i+=$cores;
			fi
			if [[ $state == "2" ]]; then 
				let total_jobcores_run+=$cores; 
				let jobcores_run_$i+=$cores;
			fi
		done</home/aperez/status/stats_jobcores_$schedd
		rm /home/aperez/status/stats_jobcores_$schedd
	done
done

#echo $total_jobcores_run $total_jobcores_idle
#echo $jobcores_run_prod $jobcores_idle_prod
#echo $jobcores_run_crab $jobcores_idle_crab
#echo $jobcores_run_other $jobcores_idle_other

date_all=`date -u +%s`
echo $date_all $total_jobcores_run $total_jobcores_idle >>/crabprod/CSstoragePath/aperez/out/jobcores_size
echo $date_all $jobcores_run_prod $jobcores_idle_prod >>/crabprod/CSstoragePath/aperez/out/jobcores_size_prod
echo $date_all $jobcores_run_crab $jobcores_idle_crab >>/crabprod/CSstoragePath/aperez/out/jobcores_size_crab
echo $date_all $jobcores_run_other $jobcores_idle_other >>/crabprod/CSstoragePath/aperez/out/jobcores_size_other
