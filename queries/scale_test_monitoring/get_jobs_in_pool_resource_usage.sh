#!/bin/sh
source /etc/profile.d/condor.sh

# Watch JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July-Aug  2016
# Feb 2017, query child collector
WORKDIR="/home/aperez/scale_test_monitoring"
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring/HTML/JobInfo"

collector=$($WORKDIR/collector_itb.sh):9620

now=$(date -u)

# ---------------------------------------------------
echo "## RUNNING JOBS info updated at" $now >$OUTDIR/globalpool_all_running_jobs_new.txt
echo "## number_jobs RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AccountingGroup">>$OUTDIR/globalpool_all_running_jobs_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_all_running_jobs_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AcctGroup|sort |uniq -c |sort -nr>>$OUTDIR/globalpool_all_running_jobs_new.txt
mv $OUTDIR/globalpool_all_running_jobs_new.txt $OUTDIR/globalpool_all_running_jobs.txt

# ---------------------------------------------------
echo "## QUEUED JOBS info updated at" $now >$OUTDIR/globalpool_all_queued_jobs_new.txt
echo "## number_jobs RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AccountingGroup">>$OUTDIR/globalpool_all_queued_jobs_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_all_queued_jobs_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 1)' -af RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AcctGroup|sort |uniq -c |sort -nr>>$OUTDIR/globalpool_all_queued_jobs_new.txt
mv $OUTDIR/globalpool_all_queued_jobs_new.txt $OUTDIR/globalpool_all_queued_jobs.txt

