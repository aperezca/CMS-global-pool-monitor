#!/bin/sh
source /etc/profile.d/condor.sh

# Check Idle, Running and Held multicore pilots at T1s to evaluate glidein pressure on each site compared to pledged slots
# Antonio Perez-Calero Yzquierdo Sep. 2015, May 2016, May 2017
# factory infos

CERN_factory=`host -t CNAME cmsgwms-factory-prod.cern.ch |awk '{print $6}'`
#CERN_factory="vocms0805.cern.ch"
UCSD_factory="gfactory-1.t2.ucsd.edu"
FNAL_factory="cmsgwms-factory.fnal.gov:8319"
GOC_factory="glidein.grid.iu.edu"

sites=$1
dir="/home/aperez/entries"

if [[ $sites == "" ]]; then echo "site input is needed"; exit; fi
#echo "sites range is" $sites
if [ $sites != "T1s" ] && [ $sites != "T2s" ]; then echo "site range is required: T1s or T2s"; exit; fi
if [[ $sites == "T1s" ]]; then sitelist="/home/aperez/entries/T1_sites"; fi
if [[ $sites == "T2s" ]]; then sitelist="/home/aperez/entries/T2_sites"; fi

date_s=`date -u +%s`
for site in `cat $sitelist`; do
	#echo $site
        idle_g=0
        running_g=0
        held_g=0
	for factory in $CERN_factory $FNAL_factory $UCSD_factory $GOC_factory; do
	#echo $factory
	#full="http://"$factory"/factory/monitor/schedd_status.xml"
	# grep by entry to pick only mcore entries!
		for entry in `cat $dir/entries_mcore_$site`; do
			#echo $entry
			iline=$(curl -s "http://"$factory"/factory/monitor/entry_"$entry"/schedd_status.xml" |grep Status|tail -1 )
			#echo $iline
			held=$(echo $iline |awk '{print $2}'|awk -F'"' '{print $2}')
			idle=$(echo $iline |awk '{print $3}'|awk -F'"' '{print $2}')
			running=$(echo $iline |awk '{print $6}'|awk -F'"' '{print $2}')
			#echo $held $idle $running
			if [[ $idle != "" ]]; then let idle_g+=$idle; fi
                	if [[ $running != "" ]]; then let running_g+=$running; fi
                	if [[ $held != "" ]]; then let held_g+=$held; fi
		done
	done
	echo $date_s $idle_g $running_g $held_g >>/crabprod/CSstoragePath/aperez/out/factories_$site
	#echo $date_s $idle_g $running_g $held_g
done
