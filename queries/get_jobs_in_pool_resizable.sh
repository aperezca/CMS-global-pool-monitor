#!/bin/sh
source /etc/profile.d/condor.sh

# Watch resizable jobs in CMS global pool
# Antonio Perez-Calero Yzquierdo Nov  2016
# Feb 2017 query child collector

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh):9620
#collector=$($WORKDIR/collector.sh)

now=$(date -u)

condor_q -pool $collector -global -const '(WMCore_ResizeJob=?=true) && (JobStatus==2)' -af WMAgent_RequestName RequestCPUs JobCpus OriginalCpus MinCores MaxCores |sort |uniq -c >$OUTDIR/HTML/JobInfo/globalpool_resizable_jobs_new.txt

echo "## RESIZABLE JOBS RUNNING IN CMS GLOBAL POOL UPDATED AT" $now                                   >$OUTDIR/HTML/JobInfo/globalpool_resizable_jobs.txt
echo "## Number_jobs :: WMAgent_RequestName RequestCPUs JobCpus OriginalCpus MinCores MaxCores"      >>$OUTDIR/HTML/JobInfo/globalpool_resizable_jobs.txt
echo "## -------------------------------------------------------------------------------------" >>$OUTDIR/HTML/JobInfo/globalpool_resizable_jobs.txt

cat $OUTDIR/HTML/JobInfo/globalpool_resizable_jobs_new.txt >>$OUTDIR/HTML/JobInfo/globalpool_resizable_jobs.txt

date_s=`date -u +%s`
for cores in {1..10}; do 
	let jobs_$cores=0
	let jobcores_$cores=0
done
while read -r line; do
        cores=$(echo $line |awk '{print $3}')
	mincores=$(echo $line |awk '{print $6}')
	maxcores=$(echo $line |awk '{print $7}')
	let jobs_$cores+=$(echo $line |awk '{print $1}')
        let jobcores_$cores+=$(echo $line |awk '{print $1*$3}')
done<$OUTDIR/HTML/JobInfo/globalpool_resizable_jobs_new.txt

echo $date_s $jobs_1 $jobs_2 $jobs_3 $jobs_4 $jobs_5 $jobs_6 $jobs_7 $jobs_8 $jobs_9 $jobs_10>>$OUTDIR/out/resizable_3_10_jobs
echo $date_s $jobcores_1 $jobcores_2 $jobcores_3 $jobcores_4 $jobcores_5 $jobcores_6 $jobcores_7 $jobcores_8 $jobcores_9 $jobcores_10>>$OUTDIR/out/resizable_3_10_jobcores

