#!/bin/sh
# Analyse idle CPUs for multicore pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

source /data/srv/aperezca/Monitoring/env.sh
collector=$($WORKDIR/collector.sh)

date_s=`date -u +%s`

# Pilot lists produced by get_global_pool_status.sh

n_retire=0
n_memory=0
n_usable_unclaimed=0
n_usable_claimed=0

#echo "Idle cores in mcore pilots in draining:"
while read -r line; do
	#echo $line
	#state=$(echo $line | awk '{print $4}')
	#memory=$(echo $line | awk '{print $6}')
	#let cores=$(echo $line | awk '{print $1*$5}')
	let n_retire+=$(echo $line | awk '{print $1*$5}')
done<$WORKDIR/status/mcore_idle_retire.txt

#echo "Idle cores in mcore pilots not in drain stage:"
while read -r line; do
	#echo $line
	state=$(echo $line | awk '{print $4}')
        memory=$(echo $line | awk '{print $6}')
	let cores=$(echo $line | awk '{print $1*$5}')
	if [[ $memory< "2000" ]]; then 
		let n_memory+=$cores; 
	else
		if [[ $state == "Unclaimed" ]]; then let n_usable_unclaimed+=$cores; fi
        	if [[ $state == "Claimed" ]]; then let n_usable_claimed+=$cores; fi 
	fi
done<$WORKDIR/status/mcore_idle_fresh.txt

#echo "Total:"
#echo $date_s $n_retire $n_memory $n_usable_unclaimed $n_usable_claimed
echo $date_s $n_retire $n_memory $n_usable_unclaimed $n_usable_claimed >>$OUTDIR/pool_mcoreidle

