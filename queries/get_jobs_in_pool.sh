#!/bin/sh
source /etc/profile.d/condor.sh

# Watch number and type of jobs in CMS global pool
# Antonio Perez-Calero Yzquierdo Apr, Jun,  2016
# Feb 2017, query child collector
# May 2018, simplified and unified with other scripts

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh):9620

date_all=`date -u +%s`
echo "getting list of schedds and their status"
condor_status -pool $collector -schedd -af Name TotalRunningJobs TotalIdleJobs TotalHeldJobs CMSGWMS_Type Autoclusters RecentDaemonCoreDutyCycle | sort >$WORKDIR/status/all_jobs

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
	let total_jobs_run+=$jobs_run
	let total_jobs_idle+=$jobs_idle
	let total_jobs_held+=$jobs_held
	echo $date_all $autoclusters >>$OUTDIR/out/autoclusters_$schedd
	echo $date_all $dutycycle >>$OUTDIR/out/dutycycle_$schedd
	
done<$WORKDIR/status/all_jobs
echo $date_all $total_jobs_run $total_jobs_idle $total_jobs_held >>$OUTDIR/out/jobs_size


# By group, jobs:
cat $WORKDIR/status/all_jobs |grep prod >$WORKDIR/status/all_jobs_prod
cat $WORKDIR/status/all_jobs |grep crab >$WORKDIR/status/all_jobs_crab
cat $WORKDIR/status/all_jobs |grep tier0 >$WORKDIR/status/all_jobs_tier0
cat $WORKDIR/status/all_jobs |grep -v crab |grep -v prod |grep -v tier0 >$WORKDIR/status/all_jobs_other

cat $WORKDIR/status/all_jobs_prod |awk '{print $1}' >$WORKDIR/status/schedds_prod
cat $WORKDIR/status/all_jobs_crab |awk '{print $1}' >$WORKDIR/status/schedds_crab
cat $WORKDIR/status/all_jobs_tier0 |awk '{print $1}' >$WORKDIR/status/schedds_tier0
cat $WORKDIR/status/all_jobs_other |awk '{print $1}' >$WORKDIR/status/schedds_other
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
	done<$WORKDIR/status/all_jobs_$i
done

echo $date_all $jobs_run_prod $jobs_idle_prod $jobs_held_prod >>$OUTDIR/out/jobs_size_prod
echo $date_all $jobs_run_crab $jobs_idle_crab $jobs_held_crab >>$OUTDIR/out/jobs_size_crab
echo $date_all $jobs_run_tier0 $jobs_idle_tier0 $jobs_held_tier0 >>$OUTDIR/out/jobs_size_tier0
echo $date_all $jobs_run_other $jobs_idle_other $jobs_held_other >>$OUTDIR/out/jobs_size_other
echo $date_all $autoclusters_prod $autoclusters_crab $autoclusters_tier0 $autoclusters_other >>$OUTDIR/out/autoclusters

# By group, jobs and cores:
jobcores_run_total=0
jobcores_idle_total=0

for i in 'prod' 'crab' 'tier0' 'other'; do
	echo $i
	let jobcores_run_$i=0
        let jobcores_idle_$i=0
        for schedd in $(cat $WORKDIR/status/all_jobs_$i |awk '{print $1}'); do
		echo $schedd
                condor_q -pool $collector -name $schedd -af JobStatus RequestCPUs AutoClusterId |sort |uniq -c >$WORKDIR/status/stats_jobcores_$schedd
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
                echo $date_all $schedd_jobs_run $schedd_jobs_idle>>$OUTDIR/out/jobs_$schedd
                echo $date_all $schedd_cores_run $schedd_cores_idle>>$OUTDIR/out/jobscores_$schedd
        done
done

echo $date_all $jobcores_run_total $jobcores_idle_total >>$OUTDIR/out/jobcores_size
echo $date_all $jobcores_run_prod $jobcores_idle_prod >>$OUTDIR/out/jobcores_size_prod
echo $date_all $jobcores_run_crab $jobcores_idle_crab >>$OUTDIR/out/jobcores_size_crab
echo $date_all $jobcores_run_tier0 $jobcores_idle_tier0 >>$OUTDIR/out/jobcores_size_tier0
echo $date_all $jobcores_run_other $jobcores_idle_other >>$OUTDIR/out/jobcores_size_other

# count also number of autoclusters from queued jobs:
autoclusters_prod_queued=$(cat $OUTDIR/HTML/JobInfo/globalpool_all_queued_jobs.txt |awk '{print $9, $10}' | grep production |sort |uniq |wc -l)
autoclusters_crab_queued=$(cat $OUTDIR/HTML/JobInfo/globalpool_all_queued_jobs.txt |awk '{print $9, $10}' | grep analysis |sort |uniq |wc -l)
autoclusters_tier0_queued=$(cat $OUTDIR/HTML/JobInfo/globalpool_all_queued_jobs.txt |awk '{print $9, $10}' | grep tier0 |sort |uniq |wc -l)
echo $date_all $autoclusters_prod_queued $autoclusters_crab_queued $autoclusters_tier0_queued >>$OUTDIR/out/autoclusters_queued

