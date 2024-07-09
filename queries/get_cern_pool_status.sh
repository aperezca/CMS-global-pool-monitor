#!/bin/sh
# A more detailed view of currently running pilot pool:
# Antonio Perez-Calero Yzquierdo May, Nov 2016
# Adapted for the new CERN pool, May 2018

source /data/srv/aperezca/Monitoring/env.sh
collector=$($WORKDIR/collector_t0.sh)

date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'>0)' -af GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity | sort |uniq -c >$WORKDIR/status/CERN_pool/cores_fresh_glideins.txt

date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'<0)' -af GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity | sort |uniq -c >$WORKDIR/status/CERN_pool/cores_retiring_glideins.txt

now=$(date -u)
echo "## -------------------------------------------------------------------------"  >$HTMLDIR/cern_pool_pilot_info.txt
echo "## INFO ON CMS CERN POOL PILOTS UPDATED AT" $now                              >>$HTMLDIR/cern_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/cern_pool_pilot_info.txt
echo "## FRESH GLIDEINS: #_slots GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity">>$HTMLDIR/cern_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/cern_pool_pilot_info.txt
cat $WORKDIR/status/CERN_pool/cores_fresh_glideins.txt                              >>$HTMLDIR/cern_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/cern_pool_pilot_info.txt
echo "## RETIRING GLIDEINS: #_slots GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity" >>$HTMLDIR/cern_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/cern_pool_pilot_info.txt
cat $WORKDIR/status/CERN_pool/cores_retiring_glideins.txt                                     >>$HTMLDIR/cern_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$HTMLDIR/cern_pool_pilot_info.txt

#----------------------------------------------
# Current fragmentation of the pool: only claimed slots
# Get dynamic claimed slots (may be running or idle!)
cat $WORKDIR/status/CERN_pool/cores_fresh_glideins.txt |grep Dynamic > $WORKDIR/status/CERN_pool/claimed_glideins.txt
cat $WORKDIR/status/CERN_pool/cores_retiring_glideins.txt |grep Dynamic >> $WORKDIR/status/CERN_pool/claimed_glideins.txt

dyn_slots=0
for cores in {1..8}; do let slots_fresh_$cores=0; done
while read -r line; do
	let dyn_slots+=$(echo $line |awk '{print $1}')
	cores=$(echo $line |awk '{print $5}')
	let slots_fresh_$cores+=$(echo $line |awk '{print $1*$5}')
done<$WORKDIR/status/CERN_pool/claimed_glideins.txt

#echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8
echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIRT0/pool_partition_fresh

# Count number of dyn slots in the pool
echo $date_s $dyn_slots >>$OUTDIRT0/pool_dynslots

#----------------------------------------------
# Get Partitionable slots for pool size and composition

cat $WORKDIR/status/CERN_pool/cores_fresh_glideins.txt $WORKDIR/status/CERN_pool/cores_retiring_glideins.txt |grep Partitionable > $WORKDIR/status/CERN_pool/partitionable_glideins.txt

cat $WORKDIR/status/CERN_pool/partitionable_glideins.txt |grep cet0 > $WORKDIR/status/CERN_pool/partitionable_glideins_dedicated.txt
cat $WORKDIR/status/CERN_pool/partitionable_glideins.txt |grep ce |grep -v cet0 > $WORKDIR/status/CERN_pool/partitionable_glideins_shared.txt

cores_dedicated=0
cored_shared=0
while read -r line; do
	let cores_dedicated+=$(echo $line |awk '{print $1*($5-$7)}')
done<$WORKDIR/status/CERN_pool/partitionable_glideins_dedicated.txt
while read -r line; do
        let cores_shared+=$(echo $line |awk '{print $1*($5-$7)}')
done<$WORKDIR/status/CERN_pool/partitionable_glideins_shared.txt

#echo $date_s $cores_dedicated $cores_shared
echo $date_s $cores_dedicated $cores_shared >>$OUTDIRT0/pool_composition
