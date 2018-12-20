
WORKDIR="/home/aperez"

#query collector 
$WORKDIR/get_pool_size.sh
#$WORKDIR/get_pool_updates.sh
$WORKDIR/get_pool_negotiator.sh
$WORKDIR/get_pool_collector.sh
$WORKDIR/get_pool_schedds.sh 
$WORKDIR/get_pool_idle.sh
$WORKDIR/get_global_pool_status.sh
$WORKDIR/get_pool_mcore_idle.sh
$WORKDIR/get_jobs_in_pool.sh
#$WORKDIR/get_jobs_cores_in_pool.sh
