#!/bin/sh
source /etc/profile.d/condor.sh

# Count idle and busy CPUs for multicore and single core pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May, Nov 2016

collector=$(/home/aperez/collector.sh)

condor_status -pool $collector -const '((IOslots=?=undefined) || (IOslots != 1))' -af SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c |sort -nr >/home/aperez/status/cores_all_glideins.txt

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

#echo $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle

date_all=`date -u +%s`
echo $date_all $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle >>/home/aperez/out/pool_idle

#------------------------------------------
#A more detailed view of currently running pilot pool:
date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'>0) && ((IOslots=?=undefined) || (IOslots != 1))' -af  SlotType TotalSlotCPUs CPUs Memory State Activity | sort |uniq -c >/home/aperez/status/cores_fresh_glideins.txt
date_s=`date -u +%s`
condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'<0) && ((IOslots=?=undefined) || (IOslots != 1))' -af  SlotType TotalSlotCPUs CPUs Memory State Activity | sort |uniq -c >/home/aperez/status/cores_retiring_glideins.txt

now=$(date -u)
OUTDIR="/crabprod/CSstoragePath/aperez/HTML/"
echo "## -------------------------------------------------------------------------" >$OUTDIR/globalpool_pilot_info.txt
echo "## INFO ON CMS GLOBAL POOL PILOTS UPDATED AT" $now                            >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
echo "## FRESH GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs Memory State Activity" >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
cat /home/aperez/status/cores_fresh_glideins.txt                                    >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
echo "## RETIRING GLIDEINS: #_slots SlotType TotalSlotCPUs CPUs State Activity"     >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt
cat /home/aperez/status/cores_retiring_glideins.txt                                 >>$OUTDIR/globalpool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/globalpool_pilot_info.txt

#Current fragmentation of the pool: only claimed slots
date_s=`date -u +%s`
cat /home/aperez/status/cores_fresh_glideins.txt |grep Claimed > /home/aperez/status/claimed_fresh_glideins.txt
cat /home/aperez/status/cores_retiring_glideins.txt |grep Claimed > /home/aperez/status/claimed_retiring_glideins.txt

for cores in {1..8}; do let slots_fresh_$cores=0; done
for cores in {1..8}; do let slots_drain_$cores=0; done
while read -r line; do
	cores=$(echo $line |awk '{print $3}')
	#num=$(echo $line |awk '{print $1}')
	let slots_fresh_$cores+=$(echo $line |awk '{print $1*$3}')
done</home/aperez/status/claimed_fresh_glideins.txt

while read -r line; do
        cores=$(echo $line |awk '{print $3}')
        #num=$(echo $line |awk '{print $1}')
        let slots_drain_$cores+=$(echo $line |awk '{print $1*$3}')
done</home/aperez/status/claimed_retiring_glideins.txt

echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>/home/aperez/out/pool_partition_fresh
echo $date_s $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>/home/aperez/out/pool_partition_drain

