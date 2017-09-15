#!/bin/sh
source /etc/profile.d/condor.sh

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

#Pool to query
collector=$(/home/aperez/collector.sh)
# Range of sites to plot
list=$1

condor_status -pool $collector -af GLIDEIN_CMSSite SlotType CPUs TotalSlotCPUs State Activity |sort > /home/aperez/status/glideins_$list
date_s=`date -u +%s`

n_pilots_all=0
n_cores_all=0
n_cores_tot_all=0
n_cores_busy_all=0
n_cores_idle_all=0
cores_in_child_preempting_all=0

for site in `cat "/home/aperez/entries/"$list"_sites"`; do
	#echo $site
	# number of pilots
	n_pilots=$(cat /home/aperez/status/glideins_$list|grep -w $site |grep Partitionable |wc -l)
	# total cores in p-slots
	n_cores_part=0
	for i in `cat /home/aperez/status/glideins_$list| grep -w $site |grep Partitionable| awk '{print $4}'|sort |uniq -c |awk '{print $1*$2}'`; do let n_cores_part+=i; done
	# cores unclaimed idle in p-slots
	cores_in_parent=0
	for i in `cat /home/aperez/status/glideins_$list |grep -w $site |grep Partitionable |awk '{print $3}'|sort |uniq -c |awk '{print $1*$2}'`; do let cores_in_parent+=i; done
	# cores in dynamic slots
	cores_in_child_busy=0
	for i in `cat /home/aperez/status/glideins_$list |grep -w $site |grep Dynamic |grep Busy | awk '{print $3}'`; do let cores_in_child_busy+=i; done
	cores_in_child_idle=0
        for i in `cat /home/aperez/status/glideins_$list |grep -w $site |grep Dynamic |grep Idle | awk '{print $3}'`; do let cores_in_child_idle+=i; done
	cores_in_child_preempting=0
        for i in `cat /home/aperez/status/glideins_$list |grep -w $site |grep Dynamic |grep Preempting | awk '{print $3}'`; do let cores_in_child_preempting+=i; done

	let n_cores_idle=$cores_in_parent+$cores_in_child_idle
	let n_cores_busy=$cores_in_child_busy
	let n_cores_tot=$n_cores_busy+$n_cores_idle+$cores_in_child_preempting

	#echo $date_s $n_pilots $n_cores_part $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting 
	echo $date_s $n_pilots $n_cores_part $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting >>/crabprod/CSstoragePath/aperez/out/count_$site
	
	let n_pilots_all+=$n_pilots
	let n_cores_all+=$n_cores_part
	let n_cores_tot_all+=$n_cores_tot
	let n_cores_busy_all+=$n_cores_busy
	let n_cores_idle_all+=$n_cores_idle
	let cores_in_child_preempting_all+=$cores_in_child_preempting

	#PILOT OCCUPANCY: use max number of cores
	part_cores=`cat /home/aperez/status/glideins_$list| grep -w $site |grep Partitionable| awk '{print $4}'|sort |uniq|sort -nr |head -n 1`
	if [[ $part_cores -eq 0 ]]; then let part_cores=8; fi
	#echo $part_cores
	for idle_cores in $(seq 0 $part_cores); do
		let used_cores=$part_cores-$idle_cores # in use = total cores - remaining!
		#echo $part_cores $idle_cores $used_cores
		let pilot_$used_cores=$(cat /home/aperez/status/glideins_$list| grep -w $site| grep Partitionable |awk '{print $3}' |grep $idle_cores| wc -l); 
	done
	string=$(for i in $(seq 0 $part_cores); do var="pilot_$i"; echo -n "${!var}" ""; done) 
	echo $date_s $string>>/crabprod/CSstoragePath/aperez/out/occup_$site
	echo ""
	#echo $date_s $pilot_0 $pilot_1 $pilot_2 $pilot_3 $pilot_4 $pilot_5 $pilot_6 $pilot_7 $pilot_8 >>/crabprod/CSstoragePath/aperez/out/occup_$site
done

#echo $list
#echo $date_s $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all
echo $date_s $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all >>/crabprod/CSstoragePath/aperez/out/count_All_"$list"s


