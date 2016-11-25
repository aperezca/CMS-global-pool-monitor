#!/bin/sh
source /etc/profile.d/condor.sh

# Watch JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July-Aug  2016

collector=$(/home/aperez/collector.sh)

OUTDIR="/crabprod/CSstoragePath/aperez/HTML/JobInfo"
now=$(date -u)

echo "## INFO ON JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$OUTDIR/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt

echo "## RUNNING JOBS info updated at" $now >$OUTDIR/globalpool_all_running_jobs_new.txt
echo "## number_jobs RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CRAB_ReqName">>$OUTDIR/globalpool_all_running_jobs_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_all_running_jobs_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CRAB_ReqName |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_all_running_jobs_new.txt

mv $OUTDIR/globalpool_all_running_jobs_new.txt $OUTDIR/globalpool_all_running_jobs.txt
cat $OUTDIR/globalpool_all_running_jobs.txt >> $OUTDIR/globalpool_jobs_info_new.txt

echo "## QUEUED JOBS info updated at" $now >$OUTDIR/globalpool_all_queued_jobs_new.txt
echo "## number_jobs RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CRAB_ReqName">>$OUTDIR/globalpool_all_queued_jobs_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_all_queued_jobs_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 1)' -af RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CRAB_ReqName |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_all_queued_jobs_new.txt

mv $OUTDIR/globalpool_all_queued_jobs_new.txt $OUTDIR/globalpool_all_queued_jobs.txt
cat $OUTDIR/globalpool_all_queued_jobs.txt >> $OUTDIR/globalpool_jobs_info_new.txt

echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
echo "## RUNNING JOBS EXCEEDING MEMORY REQUEST:">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## number_jobs RequestCPUs RequestMemory MemoryUsage ResidentSetSize WMAgent_RequestName CRAB_ReqName">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 2) && (MemoryUsage>RequestMemory)' -af RequestCPUs RequestMemory MemoryUsage ResidentSetSize WMAgent_RequestName CRAB_ReqName |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_jobs_info_new.txt

echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
echo "## RUNNING JOBS EXCEEDING DISK REQUEST:">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## number_jobs RequestCPUs RequestDisk DiskUsage WMAgent_RequestName CRAB_ReqName">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 2) && (DiskUsage>RequestDisk)' -af RequestCPUs RequestMemory MemoryUsage ResidentSetSize RequestDisk DiskUsage WMAgent_RequestName CRAB_ReqName |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_jobs_info_new.txt

# is this the right way to calculate eff? what if jobs have been retried?
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
echo "## RUNNING JOBS EXCEEDING 100% CPU Eff after 30 min:">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## 'CPUtime/(RequestCPUs*WallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
condor_q -pool cmsgwms-collector-global.cern.ch -global -constraint '(JobStatus == 2) && (RemoteWallClockTime>1800) && (RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)>1)' -af 'RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName |sort -nr >>$OUTDIR/globalpool_jobs_info_new.txt

# Take only running jobs to avoid the list of completed or held jobs!
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
echo "## RUNNING JOBS WITH VERY LOW CPU EFF (<10%) after 30 min:">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## 'CPUtime/(RequestCPUs*WallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName">>$OUTDIR/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
condor_q -pool cmsgwms-collector-global.cern.ch -global -constraint '(JobStatus == 2) && (RemoteWallClockTime>1800) && (RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)<0.1)' -af 'RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName |sort -nr >>$OUTDIR/globalpool_jobs_info_new.txt

#HELD JOBS and COMPLETED JOBS for longer than 3 days?
#n_completed=$(date_s=`date -u +%s`; condor_q -pool cmsgwms-collector-global.cern.ch -global -constraint '(JobStatus == 4) && ('${date_s}'-EnteredCurrentStatus>259200)' -af WMAgent_RequestName CRAB_ReqName |sort |wc -l)

#n_held=$(date_s=`date -u +%s`; condor_q -pool cmsgwms-collector-global.cern.ch -global -constraint '(JobStatus == 5) && ('${date_s}'-EnteredCurrentStatus>259200)' -af WMAgent_RequestName CRAB_ReqName |sort |wc -l)

#echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt
#echo "## FOUND "$n_completed" COMPLETED JOBS IN SCHEDDS after 3 DAYS ">>$OUTDIR/globalpool_jobs_info_new.txt
#echo "## FOUND "$n_held" HELD JOBS IN SCHEDDS after 3 DAYS ">>$OUTDIR/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_jobs_info_new.txt

mv $OUTDIR/globalpool_jobs_info_new.txt $OUTDIR/globalpool_jobs_info.txt

