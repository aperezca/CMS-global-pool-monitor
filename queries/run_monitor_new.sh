#!/bin/sh
source /etc/profile.d/condor.sh

# Unified monitoring for CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

#collector="vocms099.cern.ch" # Main collector used by CMS
collector="cmsgwms-collector-global.cern.ch" # Main collector used by CMS, by alias
#collector="cmssrv221.fnal.gov" # Backup collector at FNAL

condor_status -pool $collector -af GLIDEIN_CmsSite SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c |sort -nr >/home/aperez/status/monitor_glideins.txt

#query collector, factories and frontend:
/home/aperez/multi-core_t1_count.sh
/home/aperez/multi-core_t1_factories.sh
/home/aperez/multi-core_frontend.sh
/home/aperez/get_pool_size.sh
/home/aperez/get_pool_idle.sh
/home/aperez/get_jobs_in_pool.sh
/home/aperez/get_jobs_cores_in_pool.sh

#make HTML plots
for i in 1 6 12 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/make_html_frontend.sh $i
	/crabprod/CSstoragePath/aperez/make_html_poolsize.sh $i
done
mv /crabprod/CSstoragePath/aperez/multicore_*.html /crabprod/CSstoragePath/aperez/HTML
