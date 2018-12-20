# Run queries on the collector 
WORKDIR="/home/aperez/scale_test_monitoring"
$WORKDIR/get_pool_size.sh
$WORKDIR/get_pool_negotiator.sh
$WORKDIR/get_pool_collector.sh
$WORKDIR/get_pool_schedds.sh
$WORKDIR/get_pool_frontend.sh
$WORKDIR/get_pool_idle.sh
$WORKDIR/get_itb_pool_status.sh
$WORKDIR/get_pool_mcore_idle.sh
$WORKDIR/get_jobs_in_pool.sh
$WORKDIR/get_jobs_in_pool_resource_usage.sh
