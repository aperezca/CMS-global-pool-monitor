#!/bin/sh
source /etc/profile.d/condor.sh

# Watch RUNNING JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July  2016
# Feb 2017 query child collector
collector=$(/home/aperez/collector.sh):9620

OUTDIR="/crabprod/CSstoragePath/aperez/HTML/JobInfo"
now=$(date -u)

echo "querying condor collector for running jobs"
condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af MATCH_GLIDEIN_CMSSite WMAgent_RequestName CRAB_ReqName RequestCPUs RequestMemory JobPrio |sort |uniq -c >$OUTDIR/globalpool_running_jobs_new.txt

date_all=`date -u +%s`

echo "getting global numbers"
global_running_prod=0
global_running_crab=0
T1_prod=0
T1_crab=0
T2_prod=0
T2_crab=0
T3_crab=0
while read -r line; do
	prod_name=$(echo $line |awk '{print $3}')
	crab_name=$(echo $line |awk '{print $4}')
	if [[ $prod_name == "undefined" ]] && [[ $crab_name == "undefined" ]]; then continue; fi
	site=$(echo $line |awk '{print $2}' |awk -F"_" '{print $1}')
	if [[ $prod_name != "undefined" ]]; 
		then let global_running_prod+=$(echo $line |awk '{print $1*$5}'); 
		if [[ $site == "T1" ]]; then let T1_prod+=$(echo $line |awk '{print $1*$5}'); fi
		if [[ $site == "T2" ]]; then let T2_prod+=$(echo $line |awk '{print $1*$5}'); fi
	fi
	if [[ $crab_name != "undefined" ]]; 
		then let global_running_crab+=$(echo $line |awk '{print $1*$5}'); 
		if [[ $site == "T1" ]]; then let T1_crab+=$(echo $line |awk '{print $1*$5}'); fi
		if [[ $site == "T2" ]]; then let T2_crab+=$(echo $line |awk '{print $1*$5}'); fi
		if [[ $site == "T3" ]]; then let T3_crab+=$(echo $line |awk '{print $1*$5}'); fi
	fi
done<$OUTDIR/globalpool_running_jobs_new.txt

echo $date_all $global_running_prod $global_running_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_global
#echo $T1_prod $T1_crab $T2_prod $T2_crab
echo $date_all $T1_prod $T1_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_AllT1s
echo $date_all $T2_prod $T2_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_AllT2s
echo $date_all $T3_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_AllT3s

#----- Per site info for those running mcore
echo "getting per site numbers"
for list in T1 T2 T0; do
	#echo $list
	cat $OUTDIR/globalpool_running_jobs_new.txt |grep $(echo $list"_") >$OUTDIR/running_jobs_$list.txt
	for site in `cat "/home/aperez/entries/"$list"_sites"`; do
		#echo $site
		running_prod=0
		running_crab=0
		cat $OUTDIR/globalpool_running_jobs_new.txt |grep -w $site >$OUTDIR/running_jobs_$site.txt
		while read -r line; do
			prod_name=$(echo $line |awk '{print $3}')
			crab_name=$(echo $line |awk '{print $4}')
			if [[ $prod_name == "undefined" ]] && [[ $crab_name == "undefined" ]]; then continue; fi
			if [[ $prod_name != "undefined" ]]; then let running_prod+=$(echo $line |awk '{print $1*$5}'); fi
			if [[ $crab_name != "undefined" ]]; then let running_crab+=$(echo $line |awk '{print $1*$5}'); fi
		done<$OUTDIR/running_jobs_$site.txt
		#echo $date_all $running_prod $running_crab
		echo $date_all $running_prod $running_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_$site
	done
done

T0_prod=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_T0_CH_CERN |grep $date_all |awk '{print $2}')
T0_crab=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_T0_CH_CERN |grep $date_all |awk '{print $3}')
echo $date_all $T0_prod $T0_crab $T1_prod $T1_crab $T2_prod $T2_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_T0AndGlobalPool

#----------------------------------------
# Keep the instantaneous full list:

echo "RUNNING JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$OUTDIR/globalpool_running_jobs.txt
echo "Number_jobs :: Site :: WMAgent_RequestName :: CRAB_ReqName :: RequestCPUs :: RequestMemory :: JobPrio" >>$OUTDIR/globalpool_running_jobs.txt
echo "------------------------------------------------------------------------------------------" >>$OUTDIR/globalpool_running_jobs.txt
cat $OUTDIR/globalpool_running_jobs_new.txt >>$OUTDIR/globalpool_running_jobs.txt

