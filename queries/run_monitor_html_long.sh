source /data/srv/aperezca/Monitoring/env.sh
for i in 168 720 2160 4320 6480 8640; do # last 1, 3, 6, 9, 12 months
	#global pool
	$MAKEHTMLDIR/make_html_global_pool.sh $i
	$MAKEHTMLDIR/make_html_global_pool_collector.sh $i
	$MAKEHTMLDIR/make_html_cern_pool.sh $i
	$MAKEHTMLDIR/make_html_cern_pool_collector.sh $i
        $MAKEHTMLDIR/make_html_volunteer_pool.sh $i
        $MAKEHTMLDIR/make_html_volunteer_pool_collector.sh $i

        $MAKEHTMLDIR/make_html_jobstatus.sh $i
	$MAKEHTMLDIR/make_html_pool_negotime.sh $i
	$MAKEHTMLDIR/make_html_pool_fragmentation.sh $i
	#$MAKEHTMLDIR/make_html_poolsize_only.sh $i
done
for i in 168 720 2160; do # last month
	#job info per site
	$MAKEHTMLDIR/make_html_job_sites.sh $i T0
	$MAKEHTMLDIR/make_html_job_sites.sh $i T1
        $MAKEHTMLDIR/make_html_job_sites.sh $i T2
	$MAKEHTMLDIR/make_html_job_sites.sh $i T3
	#T1s
	$MAKEHTMLDIR/make_html_occupancy.sh $i T1
	$MAKEHTMLDIR/make_html_usage.sh $i T1
	$MAKEHTMLDIR/make_html_efficiency.sh $i T1
	$MAKEHTMLDIR/make_html_factory.sh $i T1
	$MAKEHTMLDIR/make_html_frontend.sh $i T1
	#T0
	$MAKEHTMLDIR/T0/make_html_occupancy.sh $i
        $MAKEHTMLDIR/T0/make_html_usage.sh $i
        $MAKEHTMLDIR/T0/make_html_factory.sh $i
	#T2s
	$MAKEHTMLDIR/make_html_occupancy.sh $i T2
        $MAKEHTMLDIR/make_html_usage.sh $i T2
	$MAKEHTMLDIR/make_html_efficiency.sh $i T2
        $MAKEHTMLDIR/make_html_factory.sh $i T2
	$MAKEHTMLDIR/make_html_frontend.sh $i T2
	#T3s
	$MAKEHTMLDIR/make_html_occupancy.sh $i T3
        $MAKEHTMLDIR/make_html_usage.sh $i T3
        $MAKEHTMLDIR/make_html_efficiency.sh $i T3
        $MAKEHTMLDIR/make_html_factory.sh $i T3
        $MAKEHTMLDIR/make_html_frontend.sh $i T3
done

