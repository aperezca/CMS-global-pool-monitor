source /data/srv/aperezca/Monitoring/env.sh

$WORKDIR/get_volunteer_pool_status.sh
$WORKDIR/multi-core_volunteer_count.sh
#for i in 24 168; do # last day, last week
#	#echo $i
#	$OUTDIR/Volunteer/make_html_occupancy.sh $i
#	$OUTDIR/Volunteer/make_html_usage.sh $i
#done
