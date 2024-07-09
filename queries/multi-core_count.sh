#!/bin/sh

# Classify and count idle CPUs for multicore pilots at CMS T1s
# Antonio Perez-Calero Yzquierdo Aug. 2015
# Documentation about states and activities in Condor manual!
# SlotType: Partitionable, Dynamic, Static
# State: Claimed, Unclaimed, Preempting, Matched, etc
# Activity: Idle, Busy, Retiring, Killing, etc
# parent glideins: Partitionable Unclaimed Idle
# child glideins: Dynamic, Claimed Busy OR Preempting Killing OR Unclaimed Idle
# single core glideins: Static
# Major update Jan 2017

source /data/srv/aperezca/Monitoring/env.sh

# Range of sites to plot
list=$1

date_s=`date -u +%s`

n_pilots_all=0
n_cores_all=0
n_cores_tot_all=0
n_cores_busy_all=0
n_cores_idle_all=0
cores_in_child_preempting_all=0

for site in `cat "$WORKDIR/entries/"$list"_sites"`; do
	#echo $site
	n_pilots=0
	n_cores_part=0
	cores_in_parent=0
	cores_in_child_busy=0
	cores_in_child_idle=0
	cores_in_child_preempting=0

	# number of pilots
	cat $WORKDIR/status/glideins_$list| grep -w $site >$WORKDIR/status/glideins_mcore_$site
	#ls -l $WORKDIR/status/glideins_mcore_$site

	#for line in `cat $WORKDIR/status/glideins_$list| grep -w $site`; do
	while read -r line; do
		#echo $line
		n_multi=$(echo $line | awk '{print $1}')
		s_type=$(echo $line | awk '{print $3}')
		cpus=$(echo $line | awk '{print $1*$4}')
		tot_cpus=$(echo $line | awk '{print $1*$5}')
		#state=$(echo $line | awk '{print $6}')	
		activity=$(echo $line | awk '{print $7}')
		
		if [[ $s_type == "Partitionable" ]]; then 
			let n_pilots+=$n_multi
			let n_cores_part+=$tot_cpus
			let cores_in_parent+=$cpus
		else
			if [[ $activity == "Busy" ]]; then let cores_in_child_busy+=$cpus; fi
			if [[ $activity == "Idle" ]]; then let cores_in_child_idle+=$cpus; fi
			if [[ $activity == "Preempting" ]]; then let cores_in_child_preempting+=$cpus; fi
		fi
	done<$WORKDIR/status/glideins_mcore_$site
	rm $WORKDIR/status/glideins_mcore_$site

	#for i in `cat $WORKDIR/status/glideins_$list |grep -w $site |grep Dynamic |grep Busy | awk '{print $3}'`; do let cores_in_child_busy+=i; done
        #for i in `cat $WORKDIR/status/glideins_$list |grep -w $site |grep Dynamic |grep Idle | awk '{print $3}'`; do let cores_in_child_idle+=i; done
        #for i in `cat $WORKDIR/status/glideins_$list |grep -w $site |grep Dynamic |grep Preempting | awk '{print $3}'`; do let cores_in_child_preempting+=i; done

	let n_cores_idle=$cores_in_parent+$cores_in_child_idle
	let n_cores_busy=$cores_in_child_busy
	let n_cores_tot=$n_cores_busy+$n_cores_idle+$cores_in_child_preempting

	#echo $date_s $n_pilots $n_cores_part $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting 
	echo $date_s $n_pilots $n_cores_part $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting >>$OUTDIR/count_$site
	
	let n_pilots_all+=$n_pilots
	let n_cores_all+=$n_cores_part
	let n_cores_tot_all+=$n_cores_tot
	let n_cores_busy_all+=$n_cores_busy
	let n_cores_idle_all+=$n_cores_idle
	let cores_in_child_preempting_all+=$cores_in_child_preempting

	#PILOT OCCUPANCY: use max number of cores
	#part_cores=`cat $WORKDIR/status/glideins_$list| grep -w $site |grep Partitionable| awk '{print $4}'|sort |uniq|sort -nr |head -n 1`
	#if [[ $part_cores -eq 0 ]]; then let part_cores=8; fi
	#echo $part_cores
	#for idle_cores in $(seq 0 $part_cores); do
	#	let used_cores=$part_cores-$idle_cores # in use = total cores - remaining!
	#	#echo $part_cores $idle_cores $used_cores
	#	let pilot_$used_cores=$(cat $WORKDIR/status/glideins_$list| grep -w $site| grep Partitionable |awk '{print $3}' |grep $idle_cores| wc -l); 
	#done
	#string=$(for i in $(seq 0 $part_cores); do var="pilot_$i"; echo -n "${!var}" ""; done) 
	#echo $date_s $string>>$OUTDIR/occup_$site
	#echo ""
done

#echo $date_s $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all
echo $date_s $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all >>$OUTDIR/count_All_"$list"s


