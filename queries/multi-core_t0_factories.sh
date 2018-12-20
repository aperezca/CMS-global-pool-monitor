#!/bin/sh
source /etc/profile.d/condor.sh
WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

dir="$WORKDIR/entries"
# Check Idle, Running and Held multicore pilots at T1s to evaluate glidein pressure on each site compared to pledged slots
# Antonio Perez-Calero Yzquierdo Sep. 2015
#factory infos
for site in `cat $WORKDIR/entries/T0_sites`; do
	#echo $site
	date=`date -u +%s`
        idle_g=0
        running_g=0
        held_g=0
	for factory in 'vocms0305.cern.ch' 'cmsgwms-factory.fnal.gov:8319'; do
	#echo $factory
	# grep by entry to pick only mcore entries!
		for entry in `cat $dir/entries_mcore_$site`; do
			#echo $entry
			iline=$(curl -s "http://"$factory"/factory/monitor/entry_"$entry"/schedd_status.xml" |grep Status|tail -1 )
			#echo $iline
			held=$(echo $iline |awk '{print $2}'|awk -F'"' '{print $2}')
			idle=$(echo $iline |awk '{print $3}'|awk -F'"' '{print $2}')
			running=$(echo $iline |awk '{print $6}'|awk -F'"' '{print $2}')
			#echo $held $idle $running
			let idle_g+=$idle
                	let running_g+=$running
                	let held_g+=$held
		done
	done
	echo $date $idle_g $running_g $held_g >>$OUTDIR/out/factories_$site
	#echo $date $idle_g $running_g $held_g
done
