#make HTML plots
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"
for i in 720; do # last day, last week, last month
	#echo $i
	$OUTDIR/make_html_poolsize.sh $i
	$OUTDIR/make_html_jobstatus.sh $i
	$OUTDIR/make_html_pool_negotime.sh $i
	$OUTDIR/make_html_pool_collector.sh $i
	$OUTDIR/make_html_poolsize_fragmentation.sh $i
	#$OUTDIR/aperez/make_html_jobstatus_resizable.sh $i
done
