#!/bin/sh
source /etc/profile.d/condor.sh

# Get collector properties from CMS global pool
# Antonio Perez-Calero Yzquierdo June 2018
WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh)
collector_t0=$($WORKDIR/collector_t0.sh)
collector_volunteer=$($WORKDIR/collector_volunteer.sh)

#echo $collector
#echo $collector_t0
#echo $collector_volunteer

date_all=`date -u +%s`


data_global_pool=$(condor_status -pool $collector -const 'regexp("'$collector'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

data_cern_pool=$(condor_status -pool $collector_t0 -const 'regexp("'$collector_t0'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

data_volunteer_pool=$(condor_status -pool $collector_volunteer -const 'regexp("'$collector_volunteer'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

echo $date_all $data_global_pool
echo $date_all $data_cern_pool 
echo $date_all $data_volunteer_pool 

echo $date_all $data_global_pool >>$OUTDIR/out/collector_global_pool
echo $date_all $data_cern_pool >>$OUTDIR/out/collector_cern_pool
echo $date_all $data_volunteer_pool >>$OUTDIR/out/collector_volunteer_pool

