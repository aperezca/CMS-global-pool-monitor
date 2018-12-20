#!/bin/sh
source /etc/profile.d/condor.sh

# Get collector properties from CMS global pool
# Antonio Perez-Calero Yzquierdo June 2018
WORKDIR="/home/aperez/scale_test_monitoring"
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"

collector_itb=$($WORKDIR/collector_itb.sh)

date_all=`date -u +%s`

data_itb_pool=$(condor_status -pool $collector_itb -const 'regexp("vocms0809", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

echo $date_all $data_itb_pool

echo $date_all $data_itb_pool >>$OUTDIR/out/collector_itb_pool

