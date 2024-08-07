#!/bin/sh
# Count idle and busy CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May, Nov 2016

source /data/srv/aperezca/Monitoring/env.sh
collector=$($WORKDIR/collector.sh)

# Pilot list generated by get_global_pool_status.sh

cores_mcore_busy=0
cores_mcore_idle=0
cores_score_busy=0
cores_score_idle=0
#Added 2017/11/29
n_dyn_slots=0
n_sta_slots=0

while read -r line; do
	if [[ $(echo $line | grep Dynamic |grep Busy) != "" ]]; then let cores_mcore_busy+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line | grep Dynamic |grep Idle) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$4}'); fi
	
	if [[ $(echo $line | grep Partitionable) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$4}'); fi

	if [[ $(echo $line | grep Static |grep Busy) != "" ]]; then let cores_score_busy+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line | grep Static |grep Idle) != "" ]]; then let cores_score_idle+=$(echo $line | awk '{print $1*$4}'); fi

	if [[ $(echo $line | grep Dynamic) != "" ]]; then let n_dyn_slots+=$(echo $line | awk '{print $1}'); fi
	if [[ $(echo $line | grep Static) != "" ]]; then let n_sta_slots+=$(echo $line | awk '{print $1}'); fi
done<$WORKDIR/status/cores_all_glideins_for_idle.txt

# Filter HLT slots when clculating pool efficiency!
cat $WORKDIR/status/cores_all_glideins_for_idle.txt |grep HLT >$WORKDIR/status/cores_HLT_glideins.txt
cores_HLT_busy=0
cores_HLT_idle=0
while read -r line; do
        if [[ $(echo $line | grep Dynamic |grep Busy) != "" ]]; then let cores_HLT_busy+=$(echo $line | awk '{print $1*$4}'); fi
        if [[ $(echo $line | grep Dynamic |grep Idle) != "" ]]; then let cores_HLT_idle+=$(echo $line | awk '{print $1*$4}'); fi
        if [[ $(echo $line | grep Partitionable) != "" ]]; then let cores_HLT_idle+=$(echo $line | awk '{print $1*$4}'); fi
done<$WORKDIR/status/cores_HLT_glideins.txt

date_all=`date -u +%s`
# modified 11 Jan 2018 to exclude HLT!
# later, modified to include HLT separately

echo $date_all $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle $cores_HLT_busy $cores_HLT_idle>>$OUTDIR/pool_idle
echo $date_all $n_dyn_slots $n_sta_slots>>$OUTDIR/pool_dynslots

