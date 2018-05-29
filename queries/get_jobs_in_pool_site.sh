#!/bin/sh
source /etc/profile.d/condor.sh

# Watch RUNNING JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July  2016
# Feb 2017 query child collector
collector=$(/home/aperez/collector.sh):9620

OUTDIR="/crabprod/CSstoragePath/aperez/HTML/JobInfo"
now=$(date -u)

echo "querying condor collector for running jobs"
condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af MATCH_GLIDEIN_CMSSite WMAgent_RequestName CMS_JobType CRAB_ReqName RequestCPUs RequestMemory JobPrio AcctGroup |sort |uniq -c >$OUTDIR/globalpool_running_jobs_new.txt

date_all=`date -u +%s`

echo "getting global numbers"
global_running_prod=0
global_running_crab=0
global_running_tier0=0

while read -r line; do
	accgroup=$(echo $line |awk '{print $9}')
	if [[ $accgroup != "production" ]] && [[ $accgroup != "analysis" ]] && [[ $accgroup != "tier0" ]]; then
		crab_name=$(echo $line |awk '{print $5}')
		if [[ $crab_name == "undefined" ]]; then 
			continue
		else 
			accgroup="analysis"
			#echo $crab_name
		fi
	fi
	#echo $accgroup
	if [[ $accgroup == "production" ]];  then let global_running_prod+=$(echo $line |awk '{print $1*$6}'); fi
	if [[ $accgroup == "analysis" ]];  then let global_running_crab+=$(echo $line |awk '{print $1*$6}'); fi
	if [[ $accgroup == "tier0" ]];  then let global_running_tier0+=$(echo $line |awk '{print $1*$6}'); fi
done<$OUTDIR/globalpool_running_jobs_new.txt

echo $date_all $global_running_prod $global_running_crab $global_running_tier0
# Old definition, kept for reference!
#echo $date_all $global_running_prod $global_running_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_global
# New format with T0 accounting group
echo $date_all $global_running_prod $global_running_crab $global_running_tier0 >>/crabprod/CSstoragePath/aperez/out/jobs_running_global

# ----- Per site info: 
# only includes data for those sites in the lists in /home/aperez/entries
# Confusing nomenclature ahead! Originating for historical reasons, keeping it for consistency
# T1 sites: Tier1 sites
# T2 sites: T2 and T3s in the global pool
# T0 sites: CERN pool sites, originally just T0_CH_CERN

echo "getting per site numbers"
for list in T1 T2 T2_singlecore T0; do
	#echo $list
	rm $OUTDIR/running_jobs_at_$list.txt
	for site in `cat "/home/aperez/entries/"$list"_sites"`; do
		#echo $site
		running_prod=0
		running_crab=0
		running_tier0=0
		cat $OUTDIR/globalpool_running_jobs_new.txt |grep -w $site >$OUTDIR/running_jobs_$site.txt
		while read -r line; do
			accgroup=$(echo $line |awk '{print $9}')
        		if [[ $accgroup != "production" ]] && [[ $accgroup != "analysis" ]] && [[ $accgroup != "tier0" ]]; then
                		crab_name=$(echo $line |awk '{print $5}')
                		if [[ $crab_name == "undefined" ]]; then continue
               			else accgroup="analysis"; fi
        		fi
        		if [[ $accgroup == "production" ]];  then let running_prod+=$(echo $line |awk '{print $1*$6}'); fi
        		if [[ $accgroup == "analysis" ]];  then let running_crab+=$(echo $line |awk '{print $1*$6}'); fi
        		if [[ $accgroup == "tier0" ]];  then let running_tier0+=$(echo $line |awk '{print $1*$6}'); fi
		done<$OUTDIR/running_jobs_$site.txt
		echo $site $running_prod $running_crab $running_tier0 >> $OUTDIR/running_jobs_at_$list.txt
		echo $date_all $running_prod $running_crab $running_tier0 >>/crabprod/CSstoragePath/aperez/out/jobs_running_$site
	done
	cat $OUTDIR/running_jobs_at_$list.txt
done
T1_prod=$(cat $OUTDIR/running_jobs_at_T1.txt |awk '{sum += $2} END {print sum}')
T1_crab=$(cat $OUTDIR/running_jobs_at_T1.txt |awk '{sum += $3} END {print sum}')
T1_tier0=$(cat $OUTDIR/running_jobs_at_T1.txt |awk '{sum += $4} END {print sum}')

T2_prod=$(cat $OUTDIR/running_jobs_at_T2* |awk '{sum += $2} END {print sum}')
T2_crab=$(cat $OUTDIR/running_jobs_at_T2* |awk '{sum += $3} END {print sum}')
T2_tier0=$(cat $OUTDIR/running_jobs_at_T2* |awk '{sum += $4} END {print sum}')

T0_prod=$(cat $OUTDIR/running_jobs_at_T0.txt |awk '{sum += $2} END {print sum}')
T0_crab=$(cat $OUTDIR/running_jobs_at_T0.txt |awk '{sum += $3} END {print sum}')
T0_tier0=$(cat $OUTDIR/running_jobs_at_T0.txt |awk '{sum += $4} END {print sum}')

# Previous definition, kept for reference!!
#echo $date_all $T0_prod $T0_crab $T1_prod $T1_crab $T2_prod $T2_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_T0AndGlobalPool
# New format with T0 accounting group
echo $date_all $T0_prod $T0_crab $T0_tier0 $T1_prod $T1_crab $T1_tier0 $T2_prod $T2_crab $T2_tier0 >>/crabprod/CSstoragePath/aperez/out/jobs_running_T0AndGlobalPool

#echo $T0_prod $T0_crab $T0_tier0 $T1_prod $T1_crab $T1_tier0 $T2_prod $T2_crab $T2_tier0

echo $date_all $T1_prod $T1_crab $T1_tier0>>/crabprod/CSstoragePath/aperez/out/jobs_running_AllT1s
echo $date_all $T2_prod $T2_crab $T2_tier0>>/crabprod/CSstoragePath/aperez/out/jobs_running_AllT2s
echo $date_all $T0_prod $T0_crab $T0_tier0>>/crabprod/CSstoragePath/aperez/out/jobs_running_AllT0s
#----------------------------------------
# Keep the instantaneous full list:

echo "RUNNING JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$OUTDIR/globalpool_running_jobs.txt
echo "Number_jobs :: Site :: WMAgent_RequestName :: CRAB_ReqName :: RequestCPUs :: RequestMemory :: JobPrio" >>$OUTDIR/globalpool_running_jobs.txt
echo "------------------------------------------------------------------------------------------" >>$OUTDIR/globalpool_running_jobs.txt
cat $OUTDIR/globalpool_running_jobs_new.txt >>$OUTDIR/globalpool_running_jobs.txt

