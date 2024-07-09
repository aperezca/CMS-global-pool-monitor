#make HTML plots
source /data/srv/aperezca/Monitoring/env.sh
for i in 24; do # 1h, 6h, 12h, last day, last week
	#echo $i
	$MAKEHTMLDIR/make_html_global_pool.sh $i
	$MAKEHTMLDIR/make_html_global_pool_collector.sh $i
	$MAKEHTMLDIR/make_html_cern_pool.sh $i
	$MAKEHTMLDIR/make_html_cern_pool_collector.sh $i
	$MAKEHTMLDIR/make_html_volunteer_pool.sh $i
        $MAKEHTMLDIR/make_html_volunteer_pool_collector.sh $i
	$MAKEHTMLDIR/make_html_jobstatus.sh $i
	$MAKEHTMLDIR/make_html_pool_negotime.sh $i
	$MAKEHTMLDIR/make_html_pool_fragmentation.sh $i
	$MAKEHTMLDIR/make_html_jobstatus_resizable.sh $i
done
