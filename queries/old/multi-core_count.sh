#!/bin/sh
source /etc/profile.d/condor.sh

# Classify and count idle CPUs for multicore pilots at CMS T1s
# Antonio Perez-Calero Yzquierdo Aug. 2015, May 2016
# Documentation about states and activities in Condor manual!
# SlotType: Partitionable, Dynamic, Static
# State: Claimed, Unclaimed, Preempting, Matched, etc
# Activity: Idle, Busy, Retiring, Killing, etc
# parent glideins: Partitionable Unclaimed Idle
# child glideins: Dynamic, Claimed Busy OR Preempting Killing OR Unclaimed Idle
# single core glideins: Static

sites=$1

if [[ $sites == "" ]]; then echo "site input is needed"; exit; fi
echo "sites range is" $sites

if [ $sites != "T1s" ] && [ $sites != "T2s" ]; then echo "site range is required: T1s or T2s"; exit; fi

if [[ $sites == "T1s" ]]; then sitelist="/home/aperez/entries/T1_sites"; fi
if [[ $sites == "T2s" ]]; then sitelist="/home/aperez/entries/T2_sites"; fi

collector=$(/home/aperez/collector.sh)

date_s=`date -u +%s`
n_pilots_all=0
n_cores_all=0
n_cores_tot_all=0
n_cores_busy_all=0
n_cores_idle_all=0
cores_in_child_preempting_all=0

condor_status -pool $collector -af GLIDEIN_CMSSite SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c >/home/aperez/status/info_all_sites

for site in `cat $sitelist`; do
	echo $site
	cat /home/aperez/status/info_all_sites |grep $site > /home/aperez/status/glideins_at_$site

	#PILOT and CORE counting: TODO > try to use TotalSlotCpus classad!!
	if [ $site == "T1_RU_JINR" ]; then cores_per_pilot=10;
	else cores_per_pilot=8;
	fi

	n_pilots=0
	cores_in_parent=0
	cores_in_child_busy=0
	cores_in_child_idle=0
	cores_in_child_preempting=0
	while read -r line; do
	echo $line
	#for i in `cat /home/aperez/status/glideins_$site |grep Partitionable |awk '{print $3}'`; do let cores_in_parent+=i; done
	#for i in `cat /home/aperez/status/glideins_$site |grep Dynamic |grep "Claimed Busy" | awk '{print $3}'`; do let cores_in_child_busy+=i; done
        #for i in `cat /home/aperez/status/glideins_$site |grep Dynamic |grep "Unclaimed Idle" | awk '{print $3}'`; do let cores_in_child_idle+=i; done
        #for i in `cat /home/aperez/status/glideins_$site |grep Dynamic |grep "Preempting Killing" | awk '{print $3}'`; do let cores_in_child_preempting+=i; done
	done</home/aperez/status/glideins_at_$site
	
	let n_cores=$cores_per_pilot*$n_pilots
	let n_cores_idle=$cores_in_parent+$cores_in_child_idle
	let n_cores_busy=$cores_in_child_busy
	let n_cores_tot=$n_cores_busy+$n_cores_idle+$cores_in_child_preempting

	echo $date_s $n_pilots $n_cores $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting
	#echo $date_s $n_pilots $n_cores $n_cores_tot $n_cores_busy $n_cores_idle $cores_in_child_preempting >>/home/aperez/out/count_$site

	let n_pilots_all+=$n_pilots
	let n_cores_all+=$n_cores
	let n_cores_tot_all+=$n_cores_tot
	let n_cores_busy_all+=$n_cores_busy
	let n_cores_idle_all+=$n_cores_idle
	let cores_in_child_preempting_all+=$cores_in_child_preempting

	#PILOT OCCUPANCY
#	if [ $site == "T1_RU_JINR" ]; then
#		for i in {0..10}; do
#		line='Partitionable'$i'Unclaimed' 
#		let used_cores=10-$i
#		num=$(cat /home/aperez/status/glideins_$site| grep Partitionable |awk '{print $2 $3 $4}' |grep $line| wc -l);
#		let pilot_$used_cores=$num; done
#		#let pilot_$i=$(cat glideins_$site| grep Partitionable |awk '{print $3}' |grep $used_cores| wc -l); done
#	        echo $date_s $pilot_0 $pilot_1 $pilot_2 $pilot_3 $pilot_4 $pilot_5 $pilot_6 $pilot_7 $pilot_8 $pilot_9 $pilot_10 >>/home/aperez/out/occup_$site
#	else	
#		for i in {0..8}; do 
#		let used_cores=8-$i
#		let pilot_$used_cores=$(cat /home/aperez/status/glideins_$site| grep Partitionable |awk '{print $3}' |grep $i| wc -l); done
#		echo $date_s $pilot_0 $pilot_1 $pilot_2 $pilot_3 $pilot_4 $pilot_5 $pilot_6 $pilot_7 $pilot_8 >>/home/aperez/out/occup_$site
#	fi

#	rm /home/aperez/status/glideins_at_$site 
done

# Report global values for T1s and T2s groups:
echo $date_s $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all
#echo $date_s $n_pilots_all $n_cores_all $n_cores_tot_all $n_cores_busy_all $n_cores_idle_all $cores_in_child_preempting_all >>/home/aperez/out/count_All_$sites

