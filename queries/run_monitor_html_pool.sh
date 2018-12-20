#make HTML plots
WORKDIR="/crabprod/CSstoragePath/aperez"
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	$WORKDIR/make_html_global_pool.sh $i
	$WORKDIR/make_html_global_pool_collector.sh $i
	$WORKDIR/make_html_cern_pool.sh $i
	$WORKDIR/make_html_cern_pool_collector.sh $i
	$WORKDIR/make_html_volunteer_pool.sh $i
        $WORKDIR/make_html_volunteer_pool_collector.sh $i
	$WORKDIR/make_html_jobstatus.sh $i
	$WORKDIR/make_html_pool_negotime.sh $i
	$WORKDIR/make_html_pool_fragmentation.sh $i
	$WORKDIR/make_html_jobstatus_resizable.sh $i
done
