#!/bin/sh

# Count CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr. Dec. 2016

source /data/srv/aperezca/Monitoring/env_itb.sh 

collector=$($WORKDIR/collector_itb.sh)
echo $collector
condor_status -pool $collector -const '(SlotType=?="Partitionable")' -af GLIDEIN_CMSSite SlotType TotalSlotCpus TotalSlotMemory|sort |uniq -c >$WORKDIR/status/all_partitionable_glideins.txt

condor_status -pool $collector -const '(SlotType=?="Static") && ((IOslots=?=undefined) || (IOslots != 1))' -af GLIDEIN_CMSSite SlotType TotalSlotCpus TotalSlotMemory|sort |uniq -c >$WORKDIR/status/all_static_glideins.txt

size_part_T1s=0
size_part_T2s=0
while read -r line; do
	if [[ $(echo $line |grep -e T1_ -e T0_CH_CSCS_HPC) != "" ]]; then let size_part_T1s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep T2_) != "" ]]; then let size_part_T2s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep T3_) != "" ]]; then let size_part_T2s+=$(echo $line | awk '{print $1*$4}'); fi
done<$WORKDIR/status/all_partitionable_glideins.txt
#echo $size_part_T1s $size_part_T2s

size_stat_T2s=0
size_stat_T3s=0
while read -r line; do
	if [[ $(echo $line |grep T2_) != "" ]]; then let size_stat_T2s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep T3_) != "" ]]; then let size_stat_T3s+=$(echo $line | awk '{print $1*$4}'); fi
done<$WORKDIR/status/all_static_glideins.txt
#echo $size_stat_T2s $size_stat_T3s

date_all=`date -u +%s`
echo $date_all $size_part_T1s $size_part_T2s $size_stat_T2s $size_stat_T3s >>$OUTDIR/pool_size

# -------
