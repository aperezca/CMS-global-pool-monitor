#!/bin/sh
source /etc/profile.d/condor.sh

# Watch RUNNING JOBS in CMS global pool
# Antonio Perez-Calero Yzquierdo July  2016

collector=$(/home/aperez/collector.sh)

OUTDIR="/crabprod/CSstoragePath/aperez/HTML/JobInfo"
now=$(date -u)

echo "RUNNING JOBS IN CMS GLOBAL POOL UPDATED AT" $now >$OUTDIR/globalpool_running_jobs.txt
echo "Number_jobs :: Site :: WMAgent_RequestName :: CRAB_ReqName :: RequestCPUs" >>$OUTDIR/globalpool_running_jobs.txt
echo "-------------------------------------------------------------------------" >>$OUTDIR/globalpool_running_jobs.txt

condor_q -pool $collector -global -constraint '(JobStatus == 2)' -af MATCH_GLIDEIN_CMSSite WMAgent_RequestName CRAB_ReqName RequestCPUs |sort |uniq -c >>$OUTDIR/globalpool_running_jobs.txt

date_all=`date -u +%s`

global_running_prod=0
global_running_crab=0
while read -r line; do
	prod_name=$(echo $line |awk '{print $3}')
	crab_name=$(echo $line |awk '{print $4}')
	if [[ $prod_name == "undefined" ]] && [[ $crab_name == "undefined" ]]; then continue; fi
	if [[ $prod_name != "undefined" ]]; then let global_running_prod+=$(echo $line |awk '{print $1*$5}'); fi
	if [[ $crab_name != "undefined" ]]; then let global_running_crab+=$(echo $line |awk '{print $1*$5}'); fi
done<$OUTDIR/globalpool_running_jobs.txt

echo $date_all $global_running_prod $global_running_crab >>/home/aperez/out/jobs_running_global

#----- Per site info for those running mcore
for list in T1 T2 T0; do
	#echo $list
	cat $OUTDIR/globalpool_running_jobs.txt |grep $(echo $list"_") >$OUTDIR/running_jobs_$list.txt
	for site in `cat "/home/aperez/entries/"$list"_sites"`; do
		#echo $site
		running_prod=0
		running_crab=0
		cat $OUTDIR/globalpool_running_jobs.txt |grep -w $site >$OUTDIR/running_jobs_$site.txt
		while read -r line; do
			prod_name=$(echo $line |awk '{print $3}')
			crab_name=$(echo $line |awk '{print $4}')
			if [[ $prod_name == "undefined" ]] && [[ $crab_name == "undefined" ]]; then continue; fi
			if [[ $prod_name != "undefined" ]]; then let running_prod+=$(echo $line |awk '{print $1*$5}'); fi
			if [[ $crab_name != "undefined" ]]; then let running_crab+=$(echo $line |awk '{print $1*$5}'); fi
		done<$OUTDIR/running_jobs_$site.txt
		#echo $date_all $running_prod $running_crab
		echo $date_all $running_prod $running_crab >>/home/aperez/out/jobs_running_$site
	done
done

