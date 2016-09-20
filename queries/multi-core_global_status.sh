#!/bin/sh
# Global pool status monitor
# Antonio Perez-Calero Yzquierdo, May 2016
source /etc/profile.d/condor.sh

collector=$(/home/aperez/collector.sh)

date_s=`date -u +%s`
condor_status -pool $collector -const '(SlotType=?="Partitionable")' -af GLIDEIN_CMSSite MonitorSelfAge GLIDEIN_ToRetire-$date_s CPUs Memory Disk JobStarts | grep -v HLT |sort >/home/aperez/status/partglideins_now_global

# add autoclusters?
# condor_status -pool cmsgwms-collector-global.cern.ch -schedd -af Name CMSGWMS_Type Autoclusters

#echo "Site Age Remaining-time-to-retire CPUs Memory Disk Jobs"
cat status/partglideins_now_global |awk '{print $2, $3, $4, $5, $6, $7}' >status/partglideins_now_global_nosite
/crabprod/CSstoragePath/aperez/make_html_globalstatus.sh
