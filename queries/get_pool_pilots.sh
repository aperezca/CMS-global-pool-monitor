#!/bin/sh
source /etc/profile.d/condor.sh

# Query the global pool collector for the status of all slots. Simplify code and reduce number of queries
# Antonio Perez-Calero Yzquierdo Oct. 2016

collector=$(/home/aperez/collector.sh)

condor_status -pool $collector -af GLIDEIN_CMSSite SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c |sort -nr >/home/aperez/status/all_glideins.txt

date_all=`date -u +%s`

#-------------------------------------------------------------------------------
# Pool size

size_part_T1s=0
size_part_T2s=0
size_stat_T2s=0
size_stat_T3s=0

while read -r line; do 
	if [[ $(echo $line |grep Partitionable |grep T1_) != "" ]]; then let size_part_T1s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep Partitionable |grep T2_) != "" ]]; then let size_part_T2s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep Static | grep T2_) != "" ]]; then let size_stat_T2s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep Static | grep T3_) != "" ]]; then let size_stat_T3s+=$(echo $line | awk '{print $1*$4}'); fi
done</home/aperez/status/all_glideins.txt

echo $size_part_T1s $size_part_T2s $size_stat_T2s $size_stat_T3s
#echo $date_all $size_part_T1s $size_part_T2s $size_stat_T2s $size_stat_T3s >>/home/aperez/out/pool_size

#--------------------------------------------------------------------------------
# Pool idle and busy cores
cores_mcore_busy=0
cores_mcore_idle=0
cores_score_busy=0
cores_score_idle=0

while read -r line; do
        if [[ $(echo $line | grep Dynamic |grep Busy) != "" ]]; then let cores_mcore_busy+=$(echo $line | awk '{print $1*$5}'); fi
        if [[ $(echo $line | grep Dynamic |grep Idle) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$5}'); fi

        if [[ $(echo $line | grep Partitionable) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$5}'); fi

        if [[ $(echo $line | grep Static |grep Busy) != "" ]]; then let cores_score_busy+=$(echo $line | awk '{print $1*$5}'); fi
        if [[ $(echo $line | grep Static |grep Idle) != "" ]]; then let cores_score_idle+=$(echo $line | awk '{print $1*$5}'); fi
done</home/aperez/status/all_glideins.txt

echo $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle
#echo $date_all $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle >>/home/aperez/out/pool_idle

#--------------------------------------------------------------------------------
# Pool mcore idle

#--------------------------------------------------------------------------------
# Some improvement:
date_s=`date -u +%s`
condor_status -pool $collector -af SlotType TotalSlotCPUs CPUs Memory State Activity GLIDEIN_ToRetire | sort |uniq -c >/home/aperez/status/all_glideins_retire_info.txt

while read -r line; do
	retire_t=$(echo $line|awk '{print $8}')
	if [[ $retire_t -gt $date_s ]]; then 
		echo $line >> /home/aperez/status/cores_fresh_glideins.txt
	else
		echo $line >> /home/aperez/status/cores_retiring_glideins.txt
done</home/aperez/status/all_glideins_retire_info.txt

now=$(date -u)
OUT="/crabprod/CSstoragePath/aperez/HTML/globalpool_pilot_info.txt"
echo "## -------------------------------------------------------------------------" >>$OUT
echo "## INFO ON CMS GLOBAL POOL PILOTS UPDATED AT" $now >$OUT
echo "## -------------------------------------------------------------------------" >>$OUT
echo "## FRESH GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs Memory State Activity" >>$OUT
echo "## -------------------------------------------------------------------------" >>$OUT
cat /home/aperez/status/cores_fresh_glideins.txt >>$OUT

echo "## -------------------------------------------------------------------------" >>$OUT
echo "## RETIRING GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs State Activity" >>$OUT
echo "## -------------------------------------------------------------------------" >>$OUT
cat /home/aperez/status/cores_retiring_glideins.txt >>$OUT
echo "## -------------------------------------------------------------------------" >>$OUT

#----------------------------------------------------------------------------------
