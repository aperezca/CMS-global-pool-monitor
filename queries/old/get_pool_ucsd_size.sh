#!/bin/sh
source /etc/profile.d/condor.sh

job_cores=0
for i in `condor_q -pool glidein-collector.t2.ucsd.edu -global -constraint '(JobStatus == 2)' -af MATCH_EXP_JOB_GLIDEIN_Entry_Name RequestCpus |grep CMS |awk '{print $2}'`; 
	do let job_cores+=$i; 
done 

pilot_cores=0 
#for i in `condor_status -pool glidein-collector.t2.ucsd.edu -af SlotType TotalSlotCpus |grep -v Dynamic |sort |uniq -c |awk '{print $1*$3}'`; 
for i in `condor_status -pool glidein-collector.t2.ucsd.edu -af SlotType GLIDEIN_Entry_Name TotalSlotCpus |grep -v Dynamic | grep CMS |sort |uniq -c |awk '{print $1*$4}'`;
	do let pilot_cores+=$i; 
done

echo $pilot_cores $job_cores

date_all=`date -u +%s`
echo $date_all $pilot_cores $job_cores  >>/crabprod/CSstoragePath/aperez/out/ucsd_pool_size
