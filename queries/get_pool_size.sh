#!/bin/sh

# Count CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr. Dec. 2016

source /data/srv/aperezca/Monitoring/env.sh 

# Pilot lists produced by get_global_pool_status.sh
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

now=$(date -u)
OUT=$HTMLDIR"/globalpool_mcore_pilots_info.txt"

# -------
echo "## ----------------------------------------------------------------------------" >>$OUT
echo "## INFO ON RUNNING PARTITIONABLE & STATIC PILOTS FOR GLOBAL POOLs UPDATED AT" $now >$OUT
echo "## ----------------------------------------------------------------------------" >>$OUT
echo "## MCORE GLIDEINS: #pilots CMS_Site SlotType TotalSlotCPUs TotalSlotMemory " >>$OUT
echo "## ----------------------------------------------------------------------------" >>$OUT
cat  $WORKDIR/status/all_partitionable_glideins.txt $WORKDIR/status/all_static_glideins.txt>>$OUT
echo "## ----------------------------------------------------------------------------" >>$OUT
