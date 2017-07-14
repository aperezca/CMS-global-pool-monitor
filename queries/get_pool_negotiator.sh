#!/bin/sh
source /etc/profile.d/condor.sh

# Negotiator metrics monitor
# Antonio Perez-Calero Yzquierdo June 2017

collector=$(/home/aperez/collector.sh)
date=`date -u +%s`

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do 
	res=$(condor_status -pool $collector -nego -const '(name=?="'$neg'")' -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0)
	echo $date $res >>/crabprod/CSstoragePath/aperez/out/negotime_$neg
done
