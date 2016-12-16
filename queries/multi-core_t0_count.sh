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

collector="cmsgwms-collector-tier0.cern.ch" # Main T0 collector used by CMS
#collector="cmssrv239.fnal.gov" # Backup collector for T0 at FNAL

#date=`date -u +%s`
n_pilots_all=0
n_cores_all=0
n_cores_tot_all=0
n_cores_busy_all=0
n_cores_idle_all=0
cores_in_child_preempting_all=0
for site in `cat /home/aperez/entries/T0_sites`; do
	date=`date -u +%s`
	condor_status -pool $collector \
	-const '(GLIDEIN_CMSSite=?="'$site'")' \
	-format '%s ' Name \
	-format '%s ' SlotType \
	-format '%s\ ' CPUs \
	-format '%s\ ' State \
	-format '%s\n' Activity > /home/aperez/status/glideins_$site

	#PILOT and CORE counting: TODO > try to use TotalSlotCpus classad!!
	n_pilots=$(cat /home/aperez/status/glideins_$site| grep Partitionable |wc -l)
	cores_per_pilot=8;
	let n_cores=$cores_per_pilot*$n_pilots
	
	cores_in_parent=0
	for i in `cat /home/aperez/status/glideins_$site |grep Partitionable |awk '{print $3}'`; do let cores_in_parent+=i; done
	cores_in_child_busy=0
	for i in `cat /home/aperez/status/glideins_$site |grep Dynamic |grep "Claimed Busy" | awk '{print $3}'`; do let cores_in_child_busy+=i; done
	cores_in_child_idle=0
        for i in `cat /home/aperez/status/glideins_$site |grep Dynamic |grep "Unclaimed Idle" | awk '{print $3}'`; do let cores_in_child_idle+=i; done
	cores_in_child_preempting=0
        for i in `cat /home/aperez/status/glideins_$site |grep Dynamic |grep "Preempting Killing" | awk '{print $3}'`; do let cores_in_child_preempting+=i; done

	let n_cores_idle=$cores_in_parent+$cores_in_child_idle
	let n_cores_busy=$cores_in_child_busy
	let n_cores_tot=$n_cores_busy+$n_cores_idle+$cores_in_child_preempting

	echo $site 'pilots:' $n_pilots 'total cores:' $n_cores $n_cores_tot 'in parent:' $cores_in_parent 'busy:' $n_cores_busy 'idle:' $n_cores_idle 'preempting' $cores_in_child_preempting
	echo $date $n_pilots $n_cores $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting >>/crabprod/CSstoragePath/aperez/out/count_$site

	let n_pilots_all+=$n_pilots
	let n_cores_all+=$n_cores
	let n_cores_tot_all+=$n_cores_tot
	let n_cores_busy_all+=$n_cores_busy
	let n_cores_idle_all+=$n_cores_idle
	let cores_in_child_preempting_all+=$cores_in_child_preempting

	#PILOT OCCUPANCY
	for i in {0..8}; do 
		let used_cores=8-$i
		let pilot_$used_cores=$(cat /home/aperez/status/glideins_$site| grep Partitionable |awk '{print $3}' |grep $i| wc -l); 
	done
	echo $date $pilot_0 $pilot_1 $pilot_2 $pilot_3 $pilot_4 $pilot_5 $pilot_6 $pilot_7 $pilot_8 >>/crabprod/CSstoragePath/aperez/out/occup_$site
done
date_all=`date -u +%s`
echo $date_all $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all >>/crabprod/CSstoragePath/aperez/out/count_All_T0s

