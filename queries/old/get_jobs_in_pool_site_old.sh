#!/bin/sh
source /etc/profile.d/condor.sh

# Watch RUNNING JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July  2016
# Feb 2017 query child collector

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"
now=$(date -u)

collector=$($WORKDIR/collector.sh):9620
#collector=$($WORKDIR/collector.sh)

date_all=`date -u +%s`
echo "querying condor collector for running jobs"
#condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af MATCH_GLIDEIN_CMSSite WMAgent_RequestName CMS_JobType CRAB_ReqName RequestCPUs RequestMemory JobPrio AcctGroup |sort |uniq -c >$OUTDIR/HTML/JobInfo/globalpool_running_jobs_$date_all.txt

for schedd in $(cat $WORKDIR/status/all_jobs | awk '{print $1}'); do
	echo $schedd 
	condor_q -pool $collector -name $schedd -constraint '(JobStatus == 2)' -af MATCH_GLIDEIN_CMSSite WMAgent_RequestName CMS_JobType CRAB_ReqName RequestCPUs RequestMemory JobPrio AcctGroup |sort |uniq -c >>$OUTDIR/HTML/JobInfo/globalpool_running_jobs_$date_all.txt 
done

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
done<$OUTDIR/HTML/JobInfo/globalpool_running_jobs_$date_all.txt

echo $date_all $global_running_prod $global_running_crab $global_running_tier0
# Old definition, kept for reference!
#echo $date_all $global_running_prod $global_running_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_global
# New format with T0 accounting group
echo $date_all $global_running_prod $global_running_crab $global_running_tier0 >>$OUTDIR/out/jobs_running_global

# ----- Per site info: 
# only includes data for those sites in the lists in /home/aperez/entries
# Confusing nomenclature ahead! Originating for historical reasons, keeping it for consistency
# T1 sites: Tier1 sites
# T2 sites: T2 and T3s in the global pool
# T0 sites: CERN pool sites, originally just T0_CH_CERN

echo "getting per site numbers"
for list in T1 T2 T2_singlecore T0; do
	#echo $list
	for site in `cat $WORKDIR"/entries/"$list"_sites"`; do
		#echo $site
		running_prod=0
		running_crab=0
		running_tier0=0
		cat $OUTDIR/HTML/JobInfo/globalpool_running_jobs_$date_all.txt |grep -w $site >$OUTDIR/HTML/JobInfo/running_jobs_$site$date_all.txt
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
		done<$OUTDIR/HTML/JobInfo/running_jobs_$site$date_all.txt
		rm $OUTDIR/HTML/JobInfo/running_jobs_$site$date_all.txt
		echo $site $running_prod $running_crab $running_tier0 >> $OUTDIR/HTML/JobInfo/running_jobs_at_$list$date_all.txt
		echo $date_all $running_prod $running_crab $running_tier0 >>$OUTDIR/out/jobs_running_$site
	done
	cat $OUTDIR/HTML/JobInfo/running_jobs_at_$list$date_all.txt
done
T1_prod=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T1$date_all.txt |awk '{sum += $2} END {print sum}')
T1_crab=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T1$date_all.txt |awk '{sum += $3} END {print sum}')
T1_tier0=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T1$date_all.txt |awk '{sum += $4} END {print sum}')

T2_prod=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T2$date_all.txt $OUTDIR/HTML/JobInfo/running_jobs_at_T2_singlecore$date_all.txt |awk '{sum += $2} END {print sum}')
T2_crab=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T2$date_all.txt $OUTDIR/HTML/JobInfo/running_jobs_at_T2_singlecore$date_all.txt|awk '{sum += $3} END {print sum}')
T2_tier0=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T2$date_all.txt $OUTDIR/HTML/JobInfo/running_jobs_at_T2_singlecore$date_all.txt|awk '{sum += $4} END {print sum}')

T0_prod=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T0$date_all.txt |awk '{sum += $2} END {print sum}')
T0_crab=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T0$date_all.txt |awk '{sum += $3} END {print sum}')
T0_tier0=$(cat $OUTDIR/HTML/JobInfo/running_jobs_at_T0$date_all.txt |awk '{sum += $4} END {print sum}')

rm $OUTDIR/HTML/JobInfo/running_jobs_at_T1$date_all.txt
rm $OUTDIR/HTML/JobInfo/running_jobs_at_T2$date_all.txt
rm $OUTDIR/HTML/JobInfo/running_jobs_at_T2_singlecore$date_all.txt
rm $OUTDIR/HTML/JobInfo/running_jobs_at_T0$date_all.txt

# Previous definition, kept for reference!!
#echo $date_all $T0_prod $T0_crab $T1_prod $T1_crab $T2_prod $T2_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_T0AndGlobalPool
# New format with T0 accounting group
echo $date_all $T0_prod $T0_crab $T0_tier0 $T1_prod $T1_crab $T1_tier0 $T2_prod $T2_crab $T2_tier0 >>$OUTDIR/out/jobs_running_T0AndGlobalPool

#echo $T0_prod $T0_crab $T0_tier0 $T1_prod $T1_crab $T1_tier0 $T2_prod $T2_crab $T2_tier0

echo $date_all $T1_prod $T1_crab $T1_tier0>>$OUTDIR/out/jobs_running_AllT1s
echo $date_all $T2_prod $T2_crab $T2_tier0>>$OUTDIR/out/jobs_running_AllT2s
echo $date_all $T0_prod $T0_crab $T0_tier0>>$OUTDIR/out/jobs_running_AllT0s

#----------------------------------------
# Keep the instantaneous full list:
echo "RUNNING JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$OUTDIR/HTML/JobInfo/globalpool_running_jobs.txt
echo "Number_jobs :: Site :: WMAgent_RequestName :: CRAB_ReqName :: RequestCPUs :: RequestMemory :: JobPrio" >>$OUTDIR/HTML/JobInfo/globalpool_running_jobs.txt
echo "------------------------------------------------------------------------------------------" >>$OUTDIR/HTML/JobInfo/globalpool_running_jobs.txt
cat $OUTDIR/HTML/JobInfo/globalpool_running_jobs_$date_all.txt >>$OUTDIR/HTML/JobInfo/globalpool_running_jobs.txt

rm $OUTDIR/HTML/JobInfo/globalpool_running_jobs_$date_all.txt

