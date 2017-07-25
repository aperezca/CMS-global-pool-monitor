#!/bin/sh
source /etc/profile.d/condor.sh

# Check Idle, Running and Held multicore pilots at T1s to evaluate glidein pressure on each site compared to pledged slots
# Antonio Perez-Calero Yzquierdo Sep. 2015, May 2016, May, July 2017
# factory infos

CERN_factory=`host -t CNAME cmsgwms-factory-prod.cern.ch |awk '{print $6}'`
#CERN_factory="vocms0805.cern.ch"
UCSD_factory="gfactory-1.t2.ucsd.edu:9614"
FNAL_factory="cmsgwms-factory.fnal.gov"
GOC_factory="glidein.grid.iu.edu"

sitelist_1="/home/aperez/entries/T1_sites"
sitelist_2="/home/aperez/entries/T2_sites"

date_s=`date -u +%s`

for factory in $CERN_factory $UCSD_factory $FNAL_factory $GOC_factory; do 
	condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot")' -af JobStatus GlideinEntryName; 
done |sort |uniq -c >/home/aperez/status/all_pilots_factories

for site in `cat $sitelist_1 $sitelist_2 |sort`; do
	#echo $site
        idle=0
        running=0
        held=0
	cat /home/aperez/status/all_pilots_factories |grep $site >/home/aperez/status/all_pilots_fact_$site
	while read -r line; do
		#echo $line
		num=$(echo $line |awk '{print $1}')
		status=$(echo $line |awk '{print $2}')
		if [[ $status -eq 1 ]]; then let idle+=num; fi
		if [[ $status -eq 2 ]]; then let running+=num; fi
		if [[ $status -eq 5 ]]; then let held+=num; fi
	done</home/aperez/status/all_pilots_fact_$site
	rm /home/aperez/status/all_pilots_fact_$site
	echo $date_s $idle $running $held >>/crabprod/CSstoragePath/aperez/out/factories_$site
	#echo $date_s $idle $running $held
done

