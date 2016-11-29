#!/bin/sh
source /etc/profile.d/condor.sh

# Watch resizable jobs in CMS global pool
# Antonio Perez-Calero Yzquierdo Nov  2016

collector=$(/home/aperez/collector.sh)

OUTDIR="/crabprod/CSstoragePath/aperez/HTML/JobInfo"
now=$(date -u)

condor_q -pool cmssrv221.fnal.gov -global -const '(WMCore_ResizeJob=?=true) && (JobStatus==2)' -af WMAgent_RequestName RequestCPUs JobCpus OriginalCpus MinCores MaxCores |sort |uniq -c >$OUTDIR/globalpool_resizable_jobs_new.txt

echo "RESIZABLE JOBS RUNNING IN CMS GLOBAL POOL UPDATED AT" $now                                   >$OUTDIR/globalpool_resizable_jobs.txt
echo "Number_jobs :: WMAgent_RequestName RequestCPUs JobCpus OriginalCpus MinCores MaxCores"      >>$OUTDIR/globalpool_resizable_jobs.txt
echo "------------------------------------------------------------------------------------------" >>$OUTDIR/globalpool_resizable_jobs.txt

cat $OUTDIR/globalpool_resizable_jobs_new.txt >>$OUTDIR/globalpool_resizable_jobs.txt

