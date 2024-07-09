source /data/srv/aperezca/Monitoring/env.sh 

# Global pool CM and schedd status:
$WORKDIR/get_pool_negotiator.sh
$WORKDIR/get_pool_collector.sh
$WORKDIR/get_pool_schedds.sh 
$WORKDIR/get_jobs_in_pool.sh
