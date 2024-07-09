#!/bin/sh
# Negotiator metrics monitor
# Antonio Perez-Calero Yzquierdo June 2017

source /data/srv/aperezca/Monitoring/env_itb.sh

collector=$($WORKDIR/collector_itb_nego.sh)
date=`date -u +%s`

echo "Global Pool Negos:"
for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do
	if [ $neg == "NEGOTIATOR" ]; then name=$collector; fi
        if [ $neg == "NEGOTIATORT1" ]; then name="NEGOTIATORT1@"$collector; fi
        if [ $neg == "NEGOTIATORUS" ]; then name="NEGOTIATORUS@"$collector; fi
	#echo $name 
	res=$(condor_status -pool $collector -nego -const '(name=?="'$name'")' -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0 MonitorSelfCPUUsage)
	echo $name $date $res
	echo $date $res >>$OUTDIR/negotime_$neg
done

echo ""
echo ""
echo "Duty cycles for the Global, CERN and VOlunteer Negos:"
dutycycle_itb=$(condor_status -pool $collector -nego -af RecentDaemonCoreDutyCycle)

echo $date $dutycycle_itb 
echo $date $dutycycle_itb >>$OUTDIR/negos_dutycycle

