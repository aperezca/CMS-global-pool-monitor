
source /data/srv/aperezca/Monitoring/env.sh

#query collector, factories and frontend:
#$WORKDIR/multi-core_count.sh T1
#$WORKDIR/multi-core_count.sh T2
#$WORKDIR/multi-core_count.sh T3
$WORKDIR/multi-core_factories.sh
$WORKDIR/multi-core_frontend.sh

