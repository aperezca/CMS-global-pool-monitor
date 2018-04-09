#!/bin/sh
source /etc/profile.d/condor.sh

# Negotiator metrics monitor
# Antonio Perez-Calero Yzquierdo June 2017

collector=$(/home/aperez/collector.sh)
date=`date -u +%s`

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do
	if [ $neg == "NEGOTIATOR" ]; then name=$collector; fi
        if [ $neg == "NEGOTIATORT1" ]; then name="NEGOTIATORT1@"$collector; fi
        if [ $neg == "NEGOTIATORUS" ]; then name="NEGOTIATORUS@"$collector; fi
	echo $name 
	res=$(condor_status -pool $collector -nego -const '(name=?="'$name'")' -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0)
	echo $date $res >>/crabprod/CSstoragePath/aperez/out/negotime_$neg
done

collector_t0=$(/home/aperez/collector_t0.sh)
name=$(condor_status -pool $collector_t0 -nego -af Name); echo $name
res_T0=$(condor_status -pool $collector_t0 -nego -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0)
echo $date $res_T0 >>/crabprod/CSstoragePath/aperez/out/negotime_T0
