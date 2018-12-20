#!/bin/sh
source /etc/profile.d/condor.sh

# Analyse idle CPUs for multicore pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh)

date_s=`date -u +%s`

# NOTE: HLT cores are axcluded as GLIDEIN_ToRetire is undefined for those slots!

#echo "Idle cores in mcore pilots in draining:"
condor_status -pool $collector -const '(GLIDEIN_ToRetire<'${date_s}')' -af SlotType Activity State CPUs| grep -v Static| grep Idle | sort |uniq -c >$WORKDIR/status/mcore_idle_retire.txt

#echo "Idle cores in mcore pilots with not enough memory:"
condor_status -pool $collector -const '(GLIDEIN_ToRetire>'${date_s}') && (Memory<2000)' -af SlotType Activity State CPUs| grep -v Static | grep Idle| sort |uniq -c >$WORKDIR/status/mcore_idle_memory.txt

#echo "Idle cores in mcore pilots with enough time and memory:"
condor_status -pool $collector -const '(GLIDEIN_ToRetire>'${date_s}') && (Memory>2000)' -af SlotType Activity State CPUs| grep -v Static| grep Idle| sort |uniq -c >$WORKDIR/status/mcore_idle_usable.txt

n_retire=0
n_memory=0
#n_usable=0
n_usable_unclaimed=0
n_usable_claimed=0
#echo "Idle cores in mcore pilots in draining:"
while read -r line; do
	#echo $line
	let n_retire+=$(echo $line | awk '{print $1*$5}')
done<$WORKDIR/status/mcore_idle_retire.txt
#echo $n_retire

#echo "Idle cores in mcore pilots with not enough memory:"
while read -r line; do
	#echo $line
        let n_memory+=$(echo $line | awk '{print $1*$5}')
done<$WORKDIR/status/mcore_idle_memory.txt
#echo $n_memory

#echo "Idle cores in mcore pilots with enough time and memory:"
while read -r line; do
	#echo $line
	let cores=$(echo $line | awk '{print $1*$5}')
        #let n_usable+=$cores
	state=$(echo $line | awk '{print $4}')
	if [[ $state == "Unclaimed" ]]; then let n_usable_unclaimed+=$cores; fi
	if [[ $state == "Claimed" ]]; then let n_usable_claimed+=$cores; fi	
done<$WORKDIR/status/mcore_idle_usable.txt
#echo $n_usable

#echo "Total:"
#echo $date_s $n_retire $n_memory $n_usable_unclaimed $n_usable_claimed
echo $date_s $n_retire $n_memory $n_usable_unclaimed $n_usable_claimed >>$OUTDIR/out/pool_mcoreidle

