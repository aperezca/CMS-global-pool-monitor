
WORKDIR="/home/aperez"

#query collector, factories and frontend:
$WORKDIR/multi-core_count.sh T1
$WORKDIR/multi-core_count.sh T2
$WORKDIR/multi-core_factories.sh
$WORKDIR/multi-core_frontend.sh

