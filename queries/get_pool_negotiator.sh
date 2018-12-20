#!/bin/sh
source /etc/profile.d/condor.sh

# Negotiator metrics monitor
# Antonio Perez-Calero Yzquierdo June 2017

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh)
date=`date -u +%s`

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do
	if [ $neg == "NEGOTIATOR" ]; then name=$collector; fi
        if [ $neg == "NEGOTIATORT1" ]; then name="NEGOTIATORT1@"$collector; fi
        if [ $neg == "NEGOTIATORUS" ]; then name="NEGOTIATORUS@"$collector; fi
	echo $name 
	res=$(condor_status -pool $collector -nego -const '(name=?="'$name'")' -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0 MonitorSelfCPUUsage)
	echo $date $res
	echo $date $res >>$OUTDIR/out/negotime_$neg
done

collector_t0=$($WORKDIR/collector_t0.sh)
name=$(condor_status -pool $collector_t0 -nego -af Name); echo $name
res_T0=$(condor_status -pool $collector_t0 -nego -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0 MonitorSelfCPUUsage)

echo $date $res_T0
echo $date $res_T0 >>$OUTDIR/out/negotime_T0

collector_volunteer=$($WORKDIR/collector_volunteer.sh)
name=$(condor_status -pool $collector_volunteer -nego -af Name); echo $name
res_volunteer=$(condor_status -pool $collector_volunteer -nego -af LastNegotiationCyclePhase1Duration0 LastNegotiationCyclePhase2Duration0 LastNegotiationCyclePhase3Duration0 LastNegotiationCyclePhase4Duration0 MonitorSelfCPUUsage)

echo $date $res_volunteer
echo $date $res_volunteer >>$OUTDIR/out/negotime_volunteer


dutycycle_global=$(condor_status -pool $collector -nego -af RecentDaemonCoreDutyCycle)
dutycycle_cern=$(condor_status -pool $collector_t0 -nego -af RecentDaemonCoreDutyCycle)
dutycycle_volunteer=$(condor_status -pool $collector_volunteer -nego -af RecentDaemonCoreDutyCycle)

echo $date $dutycycle_global $dutycycle_cern $dutycycle_volunteer 
echo $date $dutycycle_global $dutycycle_cern $dutycycle_volunteer >>$OUTDIR/out/negos_dutycycle

