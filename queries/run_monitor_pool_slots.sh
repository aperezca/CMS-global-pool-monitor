source /data/srv/aperezca/Monitoring/env.sh 

# Global pool slot status: 
$WORKDIR/get_global_pool_status.sh
$WORKDIR/get_pool_size.sh
$WORKDIR/get_pool_idle.sh
$WORKDIR/get_pool_mcore_idle.sh
# Global pool slot status by site:
$WORKDIR/multi-core_count.sh T1
$WORKDIR/multi-core_count.sh T2
$WORKDIR/multi-core_count.sh T3
