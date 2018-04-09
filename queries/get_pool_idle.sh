#!/bin/sh
source /etc/profile.d/condor.sh

# Count idle and busy CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May, Nov 2016

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh)

#condor_status -pool $collector -const '((IOslots=?=undefined) || (IOslots != 1))' -af SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c |sort -nr >$WORKDIR/status/cores_all_glideins.txt
# modified 11 Jan 2018 to exclude HLT!
condor_status -pool $collector -const '((IOslots=?=undefined) || (IOslots != 1))' -af SlotType GLIDEIN_CMSSite CPUs Activity |sort |uniq -c |sort -nr >$WORKDIR/status/cores_all_glideins.txt

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
done<$WORKDIR/status/cores_all_glideins.txt

# Filter HLT slots when clculating pool efficiency!
cat $WORKDIR/status/cores_all_glideins.txt |grep HLT >$WORKDIR/status/cores_HLT_glideins.txt
cores_HLT_busy=0
cores_HLT_idle=0
while read -r line; do
        if [[ $(echo $line | grep Dynamic |grep Busy) != "" ]]; then let cores_HLT_busy+=$(echo $line | awk '{print $1*$4}'); fi
        if [[ $(echo $line | grep Dynamic |grep Idle) != "" ]]; then let cores_HLT_idle+=$(echo $line | awk '{print $1*$4}'); fi
        if [[ $(echo $line | grep Partitionable) != "" ]]; then let cores_HLT_idle+=$(echo $line | awk '{print $1*$4}'); fi
done<$WORKDIR/status/cores_HLT_glideins.txt

date_all=`date -u +%s`
# modified 11 Jan 2018 to exclude HLT!
echo $date_all $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle $cores_HLT_busy $cores_HLT_idle>>$OUTDIR/out/pool_idle
echo $date_all $n_dyn_slots $n_sta_slots>>$OUTDIR/out/pool_dynslots

#------------------------------------------
#A more detailed view of currently running pilot pool:
#------------------------------------------
date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'>0) && ((IOslots=?=undefined) || (IOslots != 1))' -af  SlotType TotalSlotCPUs CPUs Memory State Activity | sort |uniq -c >$WORKDIR/status/cores_fresh_glideins.txt
date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'<0) && ((IOslots=?=undefined) || (IOslots != 1))' -af  SlotType TotalSlotCPUs CPUs Memory State Activity | sort |uniq -c >$WORKDIR/status/cores_retiring_glideins.txt

now=$(date -u)
echo "## -------------------------------------------------------------------------"  >$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## INFO ON CMS GLOBAL POOL PILOTS UPDATED AT" $now                            >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## FRESH GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs Memory State Activity" >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/globalpool_pilot_info.txt
cat $WORKDIR/status/cores_fresh_glideins.txt                                        >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## RETIRING GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs State Activity"     >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/globalpool_pilot_info.txt
cat $WORKDIR/status/cores_retiring_glideins.txt                                     >>$OUTDIR/HTML/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/globalpool_pilot_info.txt

#----------------------------------------------
# Current fragmentation of the pool: only claimed slots
# 2017-09-15 Include the constraint that these are only dynamic slots! 
# Get dynamic claimed slots (may be running or idle!)
cat $WORKDIR/status/cores_fresh_glideins.txt |grep Claimed |grep Dynamic > $WORKDIR/status/claimed_fresh_glideins.txt
cat $WORKDIR/status/cores_retiring_glideins.txt |grep Claimed |grep Dynamic > $WORKDIR/status/claimed_retiring_glideins.txt

for cores in {1..8}; do let slots_fresh_$cores=0; done
for cores in {1..8}; do let slots_drain_$cores=0; done
while read -r line; do
	cores=$(echo $line |awk '{print $3}')
	#num=$(echo $line |awk '{print $1}')
	let slots_fresh_$cores+=$(echo $line |awk '{print $1*$3}')
done<$WORKDIR/status/claimed_fresh_glideins.txt

while read -r line; do
        cores=$(echo $line |awk '{print $3}')
        #num=$(echo $line |awk '{print $1}')
        let slots_drain_$cores+=$(echo $line |awk '{print $1*$3}')
done<$WORKDIR/status/claimed_retiring_glideins.txt

echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIR/out/pool_partition_fresh
echo $date_s $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>$OUTDIR/out/pool_partition_drain

#----------------------------------------------
# 2017-09-15
# Current occupancy of the pool: only unclaimed 8-core p-slots
#----------------------------------------------
# Get Partitionable 8 core slots, always unclaimed, mostly idle (but could be benchmarking!)
cat /home/aperez/status/cores_fresh_glideins.txt |grep Unclaimed |grep "Partitionable 8"> /home/aperez/status/unclaimed_fresh_glideins.txt
cat /home/aperez/status/cores_retiring_glideins.txt |grep Unclaimed |grep "Partitionable 8"> /home/aperez/status/unclaimed_retiring_glideins.txt
part_cores=8
for cores in {0..8}; do let slots_fresh_$cores=0; done
for cores in {0..8}; do let slots_drain_$cores=0; done
while read -r line; do
        idle_cores=$(echo $line |awk '{print $4}')
	let occ_cores=$part_cores-$idle_cores
        #num=$(echo $line |awk '{print $1}')
        let slots_fresh_$occ_cores+=$(echo $line |awk '{print $1*$3}')
done</home/aperez/status/unclaimed_fresh_glideins.txt

while read -r line; do
        idle_cores=$(echo $line |awk '{print $4}')
        let occ_cores=$part_cores-$idle_cores
        #num=$(echo $line |awk '{print $1}')
        let slots_drain_$occ_cores+=$(echo $line |awk '{print $1*$3}')
done</home/aperez/status/unclaimed_retiring_glideins.txt

echo $date_s $slots_fresh_0 $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>/crabprod/CSstoragePath/aperez/out/pool_occupancy_fresh
echo $date_s $slots_drain_0 $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>/crabprod/CSstoragePath/aperez/out/pool_occupancy_drain


