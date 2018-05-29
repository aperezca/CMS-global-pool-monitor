#!/bin/sh
source /etc/profile.d/condor.sh

# A more detailed view of currently running pilot pool:
# Antonio Perez-Calero Yzquierdo May, Nov 2016

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh)

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
cat $WORKDIR/status/cores_fresh_glideins.txt |grep Claimed |grep Dynamic > $WORKDIR/status/claimed_glideins.txt
cat $WORKDIR/status/cores_retiring_glideins.txt |grep Claimed |grep Dynamic >> $WORKDIR/status/claimed_glideins.txt

for cores in {1..8}; do let slots_fresh_$cores=0; done
#for cores in {1..8}; do let slots_drain_$cores=0; done
while read -r line; do
	cores=$(echo $line |awk '{print $3}')
	#num=$(echo $line |awk '{print $1}')
	let slots_fresh_$cores+=$(echo $line |awk '{print $1*$3}')
done<$WORKDIR/status/claimed_glideins.txt


echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIR/out/pool_partition_fresh
#echo $date_s $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>$OUTDIR/out/pool_partition_drain

#----------------------------------------------
# 2017-09-15
# Current occupancy of the pool: only unclaimed 8-core p-slots
#----------------------------------------------
# Get Partitionable 8 core slots, always unclaimed, mostly idle (but could be benchmarking!)
cat $WORKDIR/status/cores_fresh_glideins.txt |grep Unclaimed |grep "Partitionable 8"> $WORKDIR/status/unclaimed_glideins.txt
cat $WORKDIR/status/cores_retiring_glideins.txt |grep Unclaimed |grep "Partitionable 8">> $WORKDIR/status/unclaimed_glideins.txt
part_cores=8
for cores in {0..8}; do let slots_fresh_$cores=0; done
#for cores in {0..8}; do let slots_drain_$cores=0; done
while read -r line; do
        idle_cores=$(echo $line |awk '{print $4}')
	let occ_cores=$part_cores-$idle_cores
        #num=$(echo $line |awk '{print $1}')
        let slots_fresh_$occ_cores+=$(echo $line |awk '{print $1*$3}')
done</home/aperez/status/unclaimed_glideins.txt

echo $date_s $slots_fresh_0 $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>/crabprod/CSstoragePath/aperez/out/pool_occupancy_fresh
#echo $date_s $slots_drain_0 $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>/crabprod/CSstoragePath/aperez/out/pool_occupancy_drain

