#!/bin/sh
# Check Idle, Running and Held multicore pilots at T1s to evaluate glidein pressure on each site compared to pledged slots
# Antonio Perez-Calero Yzquierdo Sep. 2015, May 2016, May, July 2017
# factory infos

source /data/srv/aperezca/Monitoring/env_itb.sh
#CERN_factory=`host -t CNAME cmsgwms-factory-prod.cern.ch |awk '{print $6}'`
#CERN_factory_1="vocms0805.cern.ch"
CERN_factory="vocms0204.cern.ch"

date_s=`date -u +%s`

for factory in $CERN_factory; do 
	condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot")' -af JobStatus GlideinEntryName; 
done |sort |uniq -c >$WORKDIR/status/all_pilots_factories

idle=0
running=0
held=0
while read -r line; do
	#echo i$line
	num=$(echo $line |awk '{print $1}')
	status=$(echo $line |awk '{print $2}')
	if [[ $status -eq 1 ]]; then let idle+=num; fi
	if [[ $status -eq 2 ]]; then let running+=num; fi
	if [[ $status -eq 5 ]]; then let held+=num; fi
done<$WORKDIR/status/all_pilots_factories

echo $date_s $idle $running $held >>$OUTDIR/factories_itb

