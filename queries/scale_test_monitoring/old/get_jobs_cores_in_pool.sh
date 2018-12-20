#!/bin/sh
source /etc/profile.d/condor.sh

# Count CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr, Nov 2016
# Feb 2017: query from child collector

WORKDIR="/home/aperez/scale_test_monitoring"
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"

collector=$($WORKDIR/collector.sh):9620

# Info on job status: http://pages.cs.wisc.edu/~adesmet/status.html
# more info:          https://htcondor-wiki.cs.wisc.edu/index.cgi/wiki?p=MagicNumbers

total_jobcores_run=0
total_jobcores_idle=0
echo "getting list of schedds"
condor_status -pool $collector -schedd -af Name CMSGWMS_Type>$WORKDIR/status/status_allschedds

cat $WORKDIR/status/status_allschedds |grep prod >$WORKDIR/status/status_schedds_prod
cat $WORKDIR/status/status_allschedds |grep crab >$WORKDIR/status/status_schedds_crab
cat $WORKDIR/status/status_allschedds |grep -v prod |grep -v crab >$WORKDIR/status/status_schedds_other

date_all=`date -u +%s`
for i in 'prod' 'crab' 'other'; do
	#echo "Schedds:" $i
        let jobcores_run_$i=0
        let jobcores_idle_$i=0
	for schedd in $(cat $WORKDIR/status/status_schedds_$i |awk '{print $1}'); do
		#echo $schedd
		condor_q -pool $collector -name $schedd -af JobStatus RequestCPUs |sort |uniq -c >$WORKDIR/status/stats_jobcores_$schedd
		schedd_jobs_run=0
		schedd_jobs_idle=0
		schedd_cores_run=0
		schedd_cores_idle=0
		while read -r line; do
			#echo $line
			state=$(echo $line |awk '{print $2}')
			jobs=$(echo $line |awk '{print $1}')
			cores=$(echo $line |awk '{print $1*$3}')
			#echo $line '--->' $state $cores
			if [[ $state == "1" ]]; then 
				let total_jobcores_idle+=$cores;
				let jobcores_idle_$i+=$cores;
				let schedd_jobs_idle+=$jobs;
				let schedd_cores_idle+=cores;
			fi
			if [[ $state == "2" ]]; then 
				let total_jobcores_run+=$cores; 
				let jobcores_run_$i+=$cores;
				let schedd_jobs_run+=$jobs;
                                let schedd_cores_run+=cores;
			fi
		done<$WORKDIR/status/stats_jobcores_$schedd
		rm $WORKDIR/status/stats_jobcores_$schedd
		echo $date_all $schedd_jobs_run $schedd_jobs_idle>>$OUTDIR/out/jobs_$schedd
		echo $date_all $schedd_cores_run $schedd_cores_idle>>$OUTDIR/out/jobscores_$schedd
	done
done

echo $total_jobcores_run $total_jobcores_idle
echo $jobcores_run_prod $jobcores_idle_prod
echo $jobcores_run_crab $jobcores_idle_crab
echo $jobcores_run_other $jobcores_idle_other

#date_all=`date -u +%s`
echo $date_all $total_jobcores_run $total_jobcores_idle >>$OUTDIR/out/jobcores_size
echo $date_all $jobcores_run_prod $jobcores_idle_prod >>$OUTDIR/out/jobcores_size_prod
echo $date_all $jobcores_run_crab $jobcores_idle_crab >>$OUTDIR/out/jobcores_size_crab
echo $date_all $jobcores_run_other $jobcores_idle_other >>$OUTDIR/out/jobcores_size_other
