#make HTML plots
source /data/srv/aperezca/Monitoring/env_itb.sh
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	$MAKEHTMLDIR/make_html_global_pool.sh $i
	$MAKEHTMLDIR/make_html_itb_pool_collector.sh $i
	$MAKEHTMLDIR/make_html_jobstatus.sh $i
	$MAKEHTMLDIR/make_html_pool_negotime.sh $i
	$MAKEHTMLDIR/make_html_pool_fragmentation.sh $i
done
