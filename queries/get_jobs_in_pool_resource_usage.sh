#!/bin/sh
# Watch JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July-Aug  2016
# Feb 2017, query child collector
# Dec 2019 improvements to lists
source /data/srv/aperezca/Monitoring/env.sh

collector=$($WORKDIR/collector.sh):9620
#collector=$($WORKDIR/collector.sh)

now=$(date -u)

# ---------------------------------------------------
echo "## RUNNING JOBS info updated at" $now >$HTMLDIR/JobInfo/globalpool_all_running_jobs_new.txt
echo "## number_jobs RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AccountingGroup">>$HTMLDIR/JobInfo/globalpool_all_running_jobs_new.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_all_running_jobs_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af RequestCPUs RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AccountingGroup CMS_SubmissionTool|sort |uniq -c |sort -nr>>$HTMLDIR/JobInfo/globalpool_all_running_jobs_new.txt
cp $HTMLDIR/JobInfo/globalpool_all_running_jobs_new.txt $HTMLDIR/JobInfo/globalpool_all_running_jobs.txt

# ---------------------------------------------------
echo "## QUEUED JOBS info updated at" $now >$HTMLDIR/JobInfo/globalpool_all_queued_jobs_new.txt
echo "## number_jobs RequestCPUs WMCore_ResizeJob RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AccountingGroup">>$HTMLDIR/JobInfo/globalpool_all_queued_jobs_new.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_all_queued_jobs_new.txt
condor_q -pool $collector -global -constraint '(JobStatus == 1)' -af RequestCPUs WMCore_ResizeJob RequestMemory RequestDisk JobPrio WMAgent_RequestName CMS_JobType CRAB_ReqName AutoClusterId AccountingGroup CMS_SubmissionTool|sort |uniq -c |sort -nr>>$HTMLDIR/JobInfo/globalpool_all_queued_jobs_new.txt
cp $HTMLDIR/JobInfo/globalpool_all_queued_jobs_new.txt $HTMLDIR/JobInfo/globalpool_all_queued_jobs.txt

# ----------------------
# PATHOLOGICAL JOBS !!
# ----------------------

# Jobs that request too much memory
echo "## INFO ON JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
echo "## RUNNING JOBS EXCEEDING 2 GB/core IN MEMORY REQUEST:">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
echo "## number_jobs RequestCPUs RequestMemory MemoryUsage Mem_use_% WMAgent_SubTaskName CRAB_ReqName AccountingGroup">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt

#----------------------

condor_q -pool $collector -global -constraint '(JobStatus == 2) && (RequestMemory>2000*RequestCPUs)' -af RequestCPUs RequestMemory MemoryUsage WMAgent_SubTaskName CRAB_ReqName AccountingGroup CMS_SubmissionTool|sort |uniq -c |awk '{print $1, $2, $3, $4, $4/$3, $5, $6, $7, $8 }' >$HTMLDIR/JobInfo/globalpool_jobs_memory_use.txt

# ALREADY BEING MEMORY-TUNED BY UNIFIED
condor_q -pool $collector -global -constraint '(JobStatus == 2) && (HasBeenMemoryTuned == True)' -af WMAgent_RequestName |sort |uniq >$HTMLDIR/JobInfo/globalpool_jobs_mem_tuned.txt

while read -r line; do
	#echo $line
	wmagent_name=$(echo $line |awk '{print $6}'| awk -F"/" '{print $2}')
	if [ -z $wmagent_name ]; then
		echo $line >>$HTMLDIR/JobInfo/globalpool_jobs_info_new_crab.txt
		continue 
	else
		#echo $wmagent_name
		check=$(cat $HTMLDIR/JobInfo/globalpool_jobs_mem_tuned.txt |grep $wmagent_name)
		#echo $check
		if [ -z $check ]; then
			#echo $wmagent_name "NOT TUNED"
			echo $line "NOT_TUNED" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new_prod_not.txt
		else
			#echo $wmagent_name "TUNED"
			echo $line "TUNED" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new_prod_tuned.txt
		fi
	fi
done<$HTMLDIR/JobInfo/globalpool_jobs_memory_use.txt

#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#cat $HTMLDIR/JobInfo/globalpool_jobs_info_new_crab.txt |sort -nr >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
cat $HTMLDIR/JobInfo/globalpool_jobs_info_new_crab.txt $HTMLDIR/JobInfo/globalpool_jobs_info_new_prod_not.txt $HTMLDIR/JobInfo/globalpool_jobs_info_new_prod_tuned.txt |sort -nr >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt

rm $HTMLDIR/JobInfo/globalpool_jobs_info_new_crab.txt
rm $HTMLDIR/JobInfo/globalpool_jobs_info_new_prod_tuned.txt
rm $HTMLDIR/JobInfo/globalpool_jobs_info_new_prod_not.txt

# ---------------------------------------------------
# Jobs that exceed memory request:
echo "## INFO ON JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt
echo "## RUNNING JOBS EXCEEDING MEMORY REQUEST:">>$HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt
echo "## number_jobs RequestCPUs RequestMemory MemoryUsage ResidentSetSize WMAgent_SubTaskName CRAB_ReqName AccountingGroup">>$HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt
condor_q -pool $collector -global -constraint '(JobStatus == 2) && (MemoryUsage>RequestMemory)' -af RequestCPUs RequestMemory MemoryUsage ResidentSetSize/1000 WMAgent_SubTaskName CRAB_ReqName AccountingGroup CMS_SubmissionTool |sort |uniq -c |sort -nr>>$HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt

# ------
# OTHER:
# ------

#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## RUNNING JOBS EXCEEDING DISK REQUEST:">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## number_jobs RequestCPUs RequestDisk DiskUsage WMAgent_RequestName CRAB_ReqName">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#condor_q -pool $collector -global -constraint '(JobStatus == 2) && (DiskUsage>RequestDisk)' -af RequestCPUs RequestDisk DiskUsage WMAgent_RequestName CRAB_ReqName |sort |uniq -c |sort -nr>>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt

# ----------------------
# LOW CPU EFFICIENCY JOBS !!
# ----------------------

# REVIEW IF THE CLASSADS ON WHICH EFF IS CALCULATED ARE THE CORRECT ONES! -> is RemoteWallClockTime summed up over all the retries of the job?? it should not, but for the current jobs trial.
# is this the right way to calculate eff? what if jobs have been retried?

#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## RUNNING JOBS EXCEEDING 100% CPU Eff after 60 min:">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## 'CPUtime/(RequestCPUs*WallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#condor_q -pool $collector -global -constraint '(JobStatus == 2) && (RemoteWallClockTime>3600) && (RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)>1)' -af 'RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName |sort -nr >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt

# To calculate CPU efficiency: 'RemoteUserCpu/(RequestCPUs*(time()-JobCurrentStartDate))'

# Take only running jobs to avoid the list of completed or held jobs!
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## RUNNING JOBS WITH VERY LOW CPU EFF (<25%) after 60 min:">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## 'CPUtime/(RequestCPUs*WallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#condor_q -pool $collector -global -constraint '(JobStatus == 2) && (RemoteWallClockTime>3600) && (RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)<0.25)' -af 'RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName |sort -nr >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## 'CPUtime/(RequestCPUs*WallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#condor_q -pool $collector -global -constraint '(JobStatus == 2) && (RemoteWallClockTime>3600) && (RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)<0.25)' -af 'RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName |sort -nr >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## 'CPUtime/(RequestCPUs*WallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#condor_q -pool $collector -global -constraint '(JobStatus == 2) && (RemoteWallClockTime>3600) && (RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)<0.25)' -af 'RemoteUserCpu/(RequestCPUs*RemoteWallClockTime)' RequestCPUs WMAgent_RequestName CRAB_ReqName |sort -nr >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt

#HELD JOBS and COMPLETED JOBS for longer than 3 days?
#n_completed=$(date_s=`date -u +%s`; condor_q -pool $collector -global -constraint '(JobStatus == 4) && ('${date_s}'-EnteredCurrentStatus>259200)' -af WMAgent_RequestName CRAB_ReqName |sort |wc -l)

#n_held=$(date_s=`date -u +%s`; condor_q -pool $collector -global -constraint '(JobStatus == 5) && ('${date_s}'-EnteredCurrentStatus>259200)' -af WMAgent_RequestName CRAB_ReqName |sort |wc -l)

#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## FOUND "$n_completed" COMPLETED JOBS IN SCHEDDS after 3 DAYS ">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## FOUND "$n_held" HELD JOBS IN SCHEDDS after 3 DAYS ">>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt
#echo "## -------------------------------------------------------------------------" >>$HTMLDIR/JobInfo/globalpool_jobs_info_new.txt

cp $HTMLDIR/JobInfo/globalpool_jobs_info_new.txt $HTMLDIR/JobInfo/globalpool_jobs_mem_info.txt
cp $HTMLDIR/JobInfo/globalpool_jobs_info_new2.txt $HTMLDIR/JobInfo/globalpool_jobs_mem_info_2.txt

