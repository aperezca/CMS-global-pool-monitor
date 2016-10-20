#!/bin/sh
source /etc/profile.d/condor.sh

# Count CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr. 2016

collector=$(/home/aperez/collector.sh)

condor_status -pool $collector -const '(SlotType=?="Partitionable")' -af GLIDEIN_CMSSite SlotType TotalSlotCpus |sort |uniq -c |sort -nr >/home/aperez/status/all_partitionable_glideins.txt

condor_status -pool $collector -const '(SlotType=?="Static") && ((IOslots=?=undefined) || (IOslots != 1))' -af GLIDEIN_CMSSite SlotType TotalSlotCpus |sort |uniq -c |sort -nr >/home/aperez/status/all_static_glideins.txt

size_part_T1s=0
size_part_T2s=0
while read -r line; do
	if [[ $(echo $line |grep T1_) != "" ]]; then let size_part_T1s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep T2_) != "" ]]; then let size_part_T2s+=$(echo $line | awk '{print $1*$4}'); fi
done</home/aperez/status/all_partitionable_glideins.txt
echo $size_part_T1s $size_part_T2s

size_stat_T2s=0
size_stat_T3s=0
while read -r line; do
	if [[ $(echo $line |grep T2_) != "" ]]; then let size_stat_T2s+=$(echo $line | awk '{print $1*$4}'); fi
	if [[ $(echo $line |grep T3_) != "" ]]; then let size_stat_T3s+=$(echo $line | awk '{print $1*$4}'); fi
done</home/aperez/status/all_static_glideins.txt
echo $size_stat_T2s $size_stat_T3s

date_all=`date -u +%s`
echo $date_all $size_part_T1s $size_part_T2s $size_stat_T2s $size_stat_T3s >>/home/aperez/out/pool_size
