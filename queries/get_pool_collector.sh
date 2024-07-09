#!/bin/sh
# Get collector properties from CMS global pool
# Antonio Perez-Calero Yzquierdo June 2018, July 2019

source /data/srv/aperezca/Monitoring/env.sh
#echo $WORKDIR

# Pools
#collector_host=$($WORKDIR/collector_nego.sh)
collector_host_global_cern=$(A=$(host cmsgwms-collector-global.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
collector_host_global_fnal="cmssrvz02.fnal.gov" # Backup collector at FNAL

collector_host_t0=$($WORKDIR/collector_t0.sh)
collector_host_volunteer=$($WORKDIR/collector_volunteer.sh)

# Collector daemon names
#collector_global_cern="vocms0814.cern.ch@vocms0814.cern.ch"
#collector_global_cern='"COLL-GLOBAL-TOP"@vocms0814.cern.ch'
collector_global_cern='vocms4100.cern.ch'
#collector_global_cern_ccb="vocms0813.cern.ch@vocms0814.cern.ch"
collector_global_cern_ccb="vocms0813.cern.ch@vocms0813.cern.ch"
#collector_global_cern="vocms0814.cern.ch@vocms0814.cern.ch"

collector_global_fnal="global_central_manager@cmssrvz02.fnal.gov"
collector_global_fnal_ccb="global_ccb@cmssrvz03.fnal.gov"

collector_t0_cern="vocms0820.cern.ch@vocms0820.cern.ch"
collector_t0_cern_ccb="vocms0821.cern.ch@vocms0821.cern.ch"
collector_t0_fnal="frontend_service@cmssrv239.fnal.gov"
collector_t0_fnal_ccb="frontend_service@cmssrv267.fnal.gov"

collector_volunteer_cern="vocms0840.cern.ch@vocms0840.cern.ch"


echo $collector_host_global_cern
echo $collector_host_global_fnal
echo $collector_host_t0
echo $collector_host_volunteer

date_all=`date -u +%s`

# Global pool:
data_global_pool=$(condor_status -pool $collector_host_global_cern -const 'regexp("'$collector_host_global_cern'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)
data_global_pool_fnal=$(condor_status -pool $collector_host_global_fnal -const 'regexp("'$collector_global_fnal'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)
data_global_pool_ccb=$(condor_status -pool $collector_host_global_cern -const 'regexp("'$collector_global_cern_ccb'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)
data_global_pool_fnal_ccb=$(condor_status -pool $collector_host_global_fnal -const 'regexp("'$collector_global_fnal_ccb'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

# CERN pool
data_cern_pool=$(condor_status -pool $collector_host_t0 -const 'regexp("'$collector_t0_cern'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)
data_cern_pool_fnal=$(condor_status -pool $collector_host_t0 -const 'regexp("'$collector_t0_fnal'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)
data_cern_pool_ccb=$(condor_status -pool $collector_host_t0 -const 'regexp("'$collector_t0_cern_ccb'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)
data_cern_pool_fnal_ccb=$(condor_status -pool $collector_host_t0 -const 'regexp("'$collector_t0_fnal_ccb'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

# Volunteer pool
data_volunteer_pool=$(condor_status -pool $collector_host_volunteer -const 'regexp("'$collector_volunteer_cern'", Name)' -collector -af ActiveQueryWorkers PendingQueries RecentDroppedQueries RecentDaemonCoreDutyCycle RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL RecentUpdatesTotal RecentUpdatesLost SubmitterAds)

echo $date_all "Global CERN" $data_global_pool
echo $date_all "GLobal CERN CCB" $data_global_pool_ccb
echo $date_all "Global FNAL" $data_global_pool_fnal
echo $date_all "Global FNAL CCB" $data_global_pool_fnal_ccb
echo ""
echo $date_all "CERN pool CERN" $data_cern_pool 
echo $date_all "CERN pool CERN CCB" $data_cern_pool_ccb
echo $date_all "CERN pool FNAL" $data_cern_pool_fnal 
echo $date_all "CERN pool FNAL CCB" $data_cern_pool_fnal_ccb 
echo ""
echo $date_all "Volunteer pool CERN" $data_volunteer_pool 

echo $date_all $data_global_pool >>$OUTDIR/collector_global_pool
echo $date_all $data_global_pool_ccb >>$OUTDIR/collector_global_pool_ccb
echo $date_all $data_global_pool_fnal >>$OUTDIR/collector_global_pool_fnal
echo $date_all $data_global_pool_fnal_ccb >>$OUTDIR/collector_global_pool_fnal_ccb

echo $date_all $data_cern_pool >>$OUTDIR/collector_cern_pool

echo $date_all $data_volunteer_pool >>$OUTDIR/collector_volunteer_pool

