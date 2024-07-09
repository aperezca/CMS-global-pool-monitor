#!/bin/sh
# A more detailed view of currently running pilot pool:
# Antonio Perez-Calero Yzquierdo May, Nov 2016

source /data/srv/aperezca/Monitoring/env.sh

collector=$($WORKDIR/collector.sh)

date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'>0) && ((IOslots=?=undefined) || (IOslots != 1))' -af  SlotType TotalSlotCPUs CPUs Memory State Activity GLIDEIN_CMSSite CpuFamily CpuModelNumber CpuModelName | sort |uniq -c >$WORKDIR/status/cores_fresh_glideins.txt

date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'<0) && ((IOslots=?=undefined) || (IOslots != 1))' -af  SlotType TotalSlotCPUs CPUs Memory State Activity GLIDEIN_CMSSite CpuFamily CpuModelNumber CpuModelName | sort |uniq -c >$WORKDIR/status/cores_retiring_glideins.txt

condor_status -pool $collector -const 'GLIDEIN_ToRetire=?=undefined' -af SlotType TotalSlotCPUs CPUs Memory State Activity GLIDEIN_CMSSite CpuFamily CpuModelNumber CpuModelName | sort |uniq -c >$WORKDIR/status/cores_no_retire_time_glideins.txt

# Create lists for other scripts
cat $WORKDIR/status/cores_fresh_glideins.txt $WORKDIR/status/cores_retiring_glideins.txt $WORKDIR/status/cores_no_retire_time_glideins.txt |sort  >$WORKDIR/status/cores_all_glideins.txt

cat $WORKDIR/status/cores_all_glideins.txt |awk '{print $1, $2, $8, $4, $7}' >$WORKDIR/status/cores_all_glideins_for_idle.txt

cat $WORKDIR/status/cores_retiring_glideins.txt |grep -v Static| grep Idle |awk '{print $1, $2, $7, $6, $4}'  >$WORKDIR/status/mcore_idle_retire.txt
cat $WORKDIR/status/cores_fresh_glideins.txt    |grep -v Static| grep Idle |awk '{print $1, $2, $7, $6, $4, $5}' >$WORKDIR/status/mcore_idle_fresh.txt

cat $WORKDIR/status/cores_all_glideins.txt |grep Partitionable |awk '{print $1, $8, $2, $3}' >$WORKDIR/status/all_partitionable_glideins.txt
cat $WORKDIR/status/cores_all_glideins.txt |grep Partitionable |awk '{print $1, $8, $3, $9, $10, $11}' >$HTMLDIR/global_pool_partitionable_glideins.txt

cat $WORKDIR/status/cores_all_glideins.txt |grep Static |awk '{print $1, $8, $2, $3}' >$WORKDIR/status/all_static_glideins.txt

cat $WORKDIR/status/cores_all_glideins.txt |grep T1 |grep -v Static |awk '{print $1, $8, $2, $4, $3, $6, $7}' >$WORKDIR/status/glideins_T1
cat $WORKDIR/status/cores_all_glideins.txt |grep T2 |grep -v Static |awk '{print $1, $8, $2, $4, $3, $6, $7}' >$WORKDIR/status/glideins_T2
cat $WORKDIR/status/cores_all_glideins.txt |grep T3 |grep -v Static |awk '{print $1, $8, $2, $4, $3, $6, $7}' >$WORKDIR/status/glideins_T3

now=$(date -u)
echo "## -------------------------------------------------------------------------"  >$HTMLDIR/globalpool_pilot_info.txt
echo "## INFO ON CMS GLOBAL POOL PILOTS UPDATED AT" $now                            >>$HTMLDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt
echo "## FRESH GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs Memory State Activity CMSSite CpuFamily CpuModelNumber CpuModelName" >>$HTMLDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt
cat $WORKDIR/status/cores_fresh_glideins.txt                                        >>$HTMLDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt
echo "## RETIRING GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs State Activity"     >>$HTMLDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt
cat $WORKDIR/status/cores_retiring_glideins.txt                                     >>$HTMLDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt
echo "## NO RETIRE GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs State Activity"    >>$HTMLDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt
cat $WORKDIR/status/cores_no_retire_time_glideins.txt                               >>$HTMLDIR/globalpool_pilot_info.txt   
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/globalpool_pilot_info.txt


#----------------------------------------------
# Current fragmentation of the pool: only claimed slots
# 2017-09-15 Include the constraint that these are only dynamic slots! 
# Get dynamic claimed slots (may be running or idle!)
# 2018/06/23 removed the filter for Claimed/Unclaimed, keep all Dynamic!
cat $WORKDIR/status/cores_all_glideins.txt |grep Dynamic > $WORKDIR/status/claimed_glideins.txt

for cores in {1..8}; do let slots_fresh_$cores=0; done
#for cores in {1..8}; do let slots_drain_$cores=0; done
while read -r line; do
	cores=$(echo $line |awk '{print $3}')
	#num=$(echo $line |awk '{print $1}')
	let slots_fresh_$cores+=$(echo $line |awk '{print $1*$3}')
done<$WORKDIR/status/claimed_glideins.txt


echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIR/pool_partition_fresh
#echo $date_s $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>$OUTDIR/pool_partition_drain

#----------------------------------------------
# 2017-09-15
# Current occupancy of the pool: only unclaimed 8-core p-slots
#----------------------------------------------
# Get Partitionable 8 core slots, always unclaimed, mostly idle (but could be benchmarking!)
cat $WORKDIR/status/cores_all_glideins.txt |grep Unclaimed |grep "Partitionable 8"> $WORKDIR/status/unclaimed_glideins.txt

part_cores=8
for cores in {0..8}; do let slots_fresh_$cores=0; done
#for cores in {0..8}; do let slots_drain_$cores=0; done
while read -r line; do
        idle_cores=$(echo $line |awk '{print $4}')
	let occ_cores=$part_cores-$idle_cores
        #num=$(echo $line |awk '{print $1}')
        let slots_fresh_$occ_cores+=$(echo $line |awk '{print $1*$3}')
done<$WORKDIR/status/unclaimed_glideins.txt

echo $date_s $slots_fresh_0 $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIR/pool_occupancy_fresh
#echo $date_s $slots_drain_0 $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>$OUTDIR/pool_occupancy_drain


