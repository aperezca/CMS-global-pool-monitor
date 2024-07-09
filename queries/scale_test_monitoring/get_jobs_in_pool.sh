#!/bin/sh
# Watch number and type of jobs in CMS global pool
# Antonio Perez-Calero Yzquierdo Apr, Jun,  2016
# Feb 2017, query child collector
# May 2018, simplified and unified with other scripts

source /data/srv/aperezca/Monitoring/env_itb.sh
collector=$($WORKDIR/collector_itb.sh)

date_all=`date -u +%s`
echo "getting list of schedds and their status"
# THIS QUERY IS SAFE!
condor_status -pool $collector -schedd -af Name TotalRunningJobs TotalIdleJobs TotalHeldJobs CMSGWMS_Type Autoclusters RecentDaemonCoreDutyCycle RecentResourceRequestsSent NumOwners RecentJobsStarted RecentJobsCompleted RecentJobsSubmitted| sort >$WORKDIR/status/schedds_status

total_jobs_run=0
total_jobs_idle=0
total_jobs_held=0

while read -r line; do
	schedd=$(echo $line |awk '{print $1}')
	jobs_run=$(echo $line |awk '{print $2}')
	jobs_idle=$(echo $line |awk '{print $3}')
	jobs_held=$(echo $line |awk '{print $4}')
	autoclusters=$(echo $line |awk '{print $6}')
	dutycycle=$(echo $line |awk '{print $7}')
	resrequest=$(echo $line |awk '{print $8}')
	owners=$(echo $line |awk '{print $9}')
	recentjobs=$(echo $line |awk '{print $10, $11, $12}')
	let total_jobs_run+=$jobs_run
	let total_jobs_idle+=$jobs_idle
	let total_jobs_held+=$jobs_held
	echo $date_all $autoclusters >>$OUTDIR/autoclusters_$schedd
	echo $date_all $dutycycle >>$OUTDIR/dutycycle_$schedd
	echo $date_all $resrequest >>$OUTDIR/resrequest_$schedd
	echo $date_all $owners >>$OUTDIR/owners_$schedd
	echo $date_all $recentjobs >>$OUTDIR/recentjobs_$schedd

done<$WORKDIR/status/schedds_status
echo $date_all $total_jobs_run $total_jobs_idle $total_jobs_held >>$OUTDIR/jobs_size


# By group, jobs:
cat $WORKDIR/status/schedds_status |grep prod >$WORKDIR/status/schedds_status_prod
cat $WORKDIR/status/schedds_status |grep crab >$WORKDIR/status/schedds_status_crab
cat $WORKDIR/status/schedds_status |grep tier0 >$WORKDIR/status/schedds_status_tier0
cat $WORKDIR/status/schedds_status |grep -v crab |grep -v prod |grep -v tier0 >$WORKDIR/status/schedds_status_other

#cat $WORKDIR/status/schedds_status_prod |awk '{print $1}' >$WORKDIR/status/schedd_names_prod
cat $WORKDIR/status/schedds_status_crab |awk '{print $1}' >$WORKDIR/status/schedd_names_crab
cat $WORKDIR/status/schedds_status_tier0 |awk '{print $1}' >$WORKDIR/status/schedd_names_tier0
cat $WORKDIR/status/schedds_status_other |awk '{print $1}' >$WORKDIR/status/schedd_names_other
echo "getting info for each group"

for i in 'prod' 'crab' 'tier0' 'other'; do
	let jobs_run_$i=0
	let jobs_idle_$i=0
	let jobs_held_$i=0
	let autoclusters_$i=0
	echo $i
	while read -r line; do
		#echo $line
		let jobs_run_$i+=$(echo $line |awk '{print $2}')
		let jobs_idle_$i+=$(echo $line |awk '{print $3}')
		let jobs_held_$i+=$(echo $line |awk '{print $4}')
		let autoclusters_$i+=$(echo $line |awk '{print $6}')
	done<$WORKDIR/status/schedds_status_$i
done

echo $date_all $jobs_run_prod $jobs_idle_prod $jobs_held_prod >>$OUTDIR/jobs_size_prod
echo $date_all $jobs_run_crab $jobs_idle_crab $jobs_held_crab >>$OUTDIR/jobs_size_crab
echo $date_all $jobs_run_tier0 $jobs_idle_tier0 $jobs_held_tier0 >>$OUTDIR/jobs_size_tier0
echo $date_all $jobs_run_other $jobs_idle_other $jobs_held_other >>$OUTDIR/jobs_size_other
echo $date_all $autoclusters_prod $autoclusters_crab $autoclusters_tier0 $autoclusters_other >>$OUTDIR/autoclusters

# By group, jobs and cores:
collector=$($WORKDIR/collector_itb.sh):9620
jobcores_run_total=0
jobcores_idle_total=0

#June 2018, added filter on (JobUniverse == 5) not to consider CRAB local or dagman jobs

for i in 'prod' 'crab' 'tier0' 'other'; do
	echo $i
	let jobcores_run_$i=0
        let jobcores_idle_$i=0
	let autoclusters_queued_$i=0
        for schedd in $(cat $WORKDIR/status/schedds_status_$i |awk '{print $1}'); do
		echo $schedd
                condor_q -pool $collector -name $schedd -const '(JobUniverse == 5)' -af JobStatus RequestCPUs AutoClusterId |sort |uniq -c >$WORKDIR/status/stats_jobcores_$schedd
		let autoclusters_queued_$i+=$(cat $WORKDIR/status/stats_jobcores_$schedd |awk '$2 == "1" {print} $4' |sort |uniq |wc -l)
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
                                let jobcores_idle_total+=$cores;
                                let jobcores_idle_$i+=$cores;
                                let schedd_jobs_idle+=$jobs;
                                let schedd_cores_idle+=$cores;
				
                        fi
                        if [[ $state == "2" ]]; then
                                let jobcores_run_total+=$cores;
                                let jobcores_run_$i+=$cores;
                                let schedd_jobs_run+=$jobs;
                                let schedd_cores_run+=$cores;
                        fi
                done<$WORKDIR/status/stats_jobcores_$schedd
                rm $WORKDIR/status/stats_jobcores_$schedd
                echo $date_all $schedd_jobs_run $schedd_jobs_idle>>$OUTDIR/jobs_$schedd
                echo $date_all $schedd_cores_run $schedd_cores_idle>>$OUTDIR/jobscores_$schedd
        done
done

echo $date_all $jobcores_run_total $jobcores_idle_total >>$OUTDIR/jobcores_size
echo $date_all $jobcores_run_prod $jobcores_idle_prod >>$OUTDIR/jobcores_size_prod
echo $date_all $jobcores_run_crab $jobcores_idle_crab >>$OUTDIR/jobcores_size_crab
echo $date_all $jobcores_run_tier0 $jobcores_idle_tier0 >>$OUTDIR/jobcores_size_tier0
echo $date_all $jobcores_run_other $jobcores_idle_other >>$OUTDIR/jobcores_size_other
echo $date_all $autoclusters_queued_prod $autoclusters_queued_crab $autoclusters_queued_tier0 $autoclusters_queued_other>>$OUTDIR/autoclusters_queued

