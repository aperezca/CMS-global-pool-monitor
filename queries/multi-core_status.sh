#!/bin/sh
source /etc/profile.d/condor.sh
sites=$1

if [[ $sites == "" ]]; then echo "site input is needed"; exit; fi
echo "sites range is" $sites

if [ $sites != "T1s" ] && [ $sites != "T2s" ]; then echo "site range is required: T1s or T2s"; exit; fi

if [[ $sites == "T1s" ]]; then sitelist="/home/aperez/entries/T1_sites"; fi
if [[ $sites == "T2s" ]]; then sitelist="/home/aperez/entries/T2_sites"; fi

collector=$(/home/aperez/collector.sh)

for site in `cat $sitelist`; do
	echo $site
	condor_status -pool $collector -const '(GLIDEIN_CMSSite=?="'$site'") && (SlotType=?="Partitionable")' -af MonitorSelfAge CPUs Memory Disk JobStarts >/home/aperez/status/partglideins_now_$site
	/crabprod/CSstoragePath/aperez/make_html_status.sh $site
done
