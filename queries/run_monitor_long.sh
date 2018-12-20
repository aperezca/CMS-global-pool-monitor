
WORKDIR="/crabprod/CSstoragePath/aperez"

for i in 720 2160 4320 6480 8640; do # last 1, 3, 6, 9, 12 months
	#global pool
	$WORKDIR/make_html_global_pool.sh $i
	$WORKDIR/make_html_global_pool_collector.sh $i
	$WORKDIR/make_html_cern_pool.sh $i
	$WORKDIR/make_html_cern_pool_collector.sh $i
        $WORKDIR/make_html_volunteer_pool.sh $i
        $WORKDIR/make_html_volunteer_pool_collector.sh $i

        $WORKDIR/make_html_jobstatus.sh $i
	$WORKDIR/make_html_pool_negotime.sh $i
	$WORKDIR/make_html_pool_fragmentation.sh $i
	$WORKDIR/make_html_poolsize_only.sh $i
done
for i in 720; do # last month
	#job info per site
	$WORKDIR/make_html_job_sites.sh $i T0
	$WORKDIR/make_html_job_sites.sh $i T1
        $WORKDIR/make_html_job_sites.sh $i T2
	#T1s
	$WORKDIR/make_html_occupancy.sh $i
	$WORKDIR/make_html_usage.sh $i
	$WORKDIR/make_html_efficiency.sh $i
	$WORKDIR/make_html_factory.sh $i
	$WORKDIR/make_html_frontend.sh $i
	#T0
	$WORKDIR/T0/make_html_occupancy.sh $i
        $WORKDIR/T0/make_html_usage.sh $i
        $WORKDIR/T0/make_html_factory.sh $i
	#T2s
	$WORKDIR/T2s/make_html_occupancy.sh $i
        $WORKDIR/T2s/make_html_usage.sh $i
	$WORKDIR/T2s/make_html_efficiency.sh $i
        $WORKDIR/T2s/make_html_factory.sh $i
	$WORKDIR/T2s/make_html_frontend.sh $i
done

mv $WORKDIR/longmulticore_*.html $WORKDIR/HTML

