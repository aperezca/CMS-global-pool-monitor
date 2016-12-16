#!/bin/sh
source /etc/profile.d/condor.sh

# Watch resizable jobs in CMS global pool
# Antonio Perez-Calero Yzquierdo Nov  2016

collector=$(/home/aperez/collector.sh)

OUTDIR="/crabprod/CSstoragePath/aperez/HTML/JobInfo"
now=$(date -u)

condor_q -pool cmssrv221.fnal.gov -global -const '(WMCore_ResizeJob=?=true) && (JobStatus==2)' -af WMAgent_RequestName RequestCPUs JobCpus OriginalCpus MinCores MaxCores |sort |uniq -c >$OUTDIR/globalpool_resizable_jobs_new.txt

echo "## RESIZABLE JOBS RUNNING IN CMS GLOBAL POOL UPDATED AT" $now                                   >$OUTDIR/globalpool_resizable_jobs.txt
echo "## Number_jobs :: WMAgent_RequestName RequestCPUs JobCpus OriginalCpus MinCores MaxCores"      >>$OUTDIR/globalpool_resizable_jobs.txt
echo "## -------------------------------------------------------------------------------------" >>$OUTDIR/globalpool_resizable_jobs.txt

cat $OUTDIR/globalpool_resizable_jobs_new.txt >>$OUTDIR/globalpool_resizable_jobs.txt

date_s=`date -u +%s`
for cores in {1..4}; do 
	let jobs_$cores=0
	let jobcores_$cores=0
done
while read -r line; do
        cores=$(echo $line |awk '{print $3}')
	mincores=$(echo $line |awk '{print $6}')
	maxcores=$(echo $line |awk '{print $7}')
	if [[ $mincores -eq "1" ]] && [[ $maxcores -eq "4" ]]; then
		let jobs_$cores+=$(echo $line |awk '{print $1}')
        	let jobcores_$cores+=$(echo $line |awk '{print $1*$3}')
	fi
done<$OUTDIR/globalpool_resizable_jobs_new.txt

echo $date_s $jobs_1 $jobs_2 $jobs_3 $jobs_4 >>/crabprod/CSstoragePath/aperez/out/resizable_1_4_jobs
echo $date_s $jobcores_1 $jobcores_2 $jobcores_3 $jobcores_4 >>/crabprod/CSstoragePath/aperez/out/resizable_1_4_jobcores
