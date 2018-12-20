#make HTML plots
WORKDIR="/crabprod/CSstoragePath/aperez"
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	$WORKDIR/make_html_occupancy.sh $i
	$WORKDIR/make_html_usage.sh $i
	$WORKDIR/make_html_efficiency.sh $i
	$WORKDIR/make_html_factory.sh $i
	$WORKDIR/make_html_frontend.sh $i
done
