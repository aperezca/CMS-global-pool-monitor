#!/bin/sh
source /etc/profile.d/condor.sh

# Negotiator metrics monitor
# Antonio Perez-Calero Yzquierdo June 2017

WORKDIR="/home/aperez/scale_test_monitoring"
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"

collector=$($WORKDIR/collector.sh)

date=`date -u +%s`

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do
	if [ $neg == "NEGOTIATOR" ]; then name="vocms0809.cern.ch"; fi
	if [ $neg == "NEGOTIATORT1" ]; then name="NEGOTIATORT1@vocms0809.cern.ch"; fi
	if [ $neg == "NEGOTIATORUS" ]; then name="NEGOTIATORUS@vocms0809.cern.ch"; fi
	res=$(condor_status -pool $collector -nego -const '(name=?="'$name'")' -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0)
	echo $date $res >>$OUTDIR/out/negotime_$neg
done
