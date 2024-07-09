#!/bin/sh
# Get collector properties from CMS global pool
# Antonio Perez-Calero Yzquierdo June 2018

source /data/srv/aperezca/Monitoring/env_itb.sh

collector=$($WORKDIR/collector_itb_nego.sh)

#echo $collector

date_all=`date -u +%s`


#data_global_pool=$(condor_status -pool $collector -const 'regexp("'$collector'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

#-const 'Name=="ITB Top Level COllector at  vocms0809.cern.ch@vocms0809.cern.ch"'
data_global_pool=$(condor_status -pool $collector -const 'Name=="ITB Top Level COllector at  vocms0803.cern.ch@vocms0803.cern.ch"' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

echo $date_all $data_global_pool

echo $date_all $data_global_pool >>$OUTDIR/collector_itb_pool

