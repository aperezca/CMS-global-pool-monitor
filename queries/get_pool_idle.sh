#!/bin/sh
source /etc/profile.d/condor.sh

# Count idle and busy CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

collector=$(/home/aperez/collector.sh)

condor_status -pool $collector -af SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c |sort -nr >/home/aperez/status/cores_all_glideins.txt

cores_mcore_busy=0
cores_mcore_idle=0
cores_score_busy=0
cores_score_idle=0

while read -r line; do
	if [[ $(echo $line | grep Dynamic |grep Busy) != "" ]]; then let cores_mcore_busy+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line | grep Dynamic |grep Idle) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$4}'); fi
	
	if [[ $(echo $line | grep Partitionable) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$4}'); fi

	if [[ $(echo $line | grep Static |grep Busy) != "" ]]; then let cores_score_busy+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line | grep Static |grep Idle) != "" ]]; then let cores_score_idle+=$(echo $line | awk '{print $1*$4}'); fi
done</home/aperez/status/cores_all_glideins.txt

echo $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle

date_all=`date -u +%s`
echo $date_all $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle >>/home/aperez/out/pool_idle

#------------------------------------------
#Some improvement:
date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'>0)' -af  SlotType TotalSlotCPUs CPUs Memory State Activity | sort |uniq -c >/home/aperez/status/cores_fresh_glideins.txt
date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'<0)' -af  SlotType TotalSlotCPUs CPUs State Activity | sort |uniq -c >/home/aperez/status/cores_retiring_glideins.txt

now=$(date -u)
OUTDIR="/crabprod/CSstoragePath/aperez/HTML/"
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
echo "## INFO ON CMS GLOBAL POOL PILOTS UPDATED AT" $now >$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
echo "## FRESH GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs Memory State Activity" >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
cat /home/aperez/status/cores_fresh_glideins.txt >>$OUTDIR/globalpool_pilot_info.txt

echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
echo "## RETIRING GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs State Activity" >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
cat /home/aperez/status/cores_retiring_glideins.txt >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
