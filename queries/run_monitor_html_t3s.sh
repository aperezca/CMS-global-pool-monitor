source /data/srv/aperezca/Monitoring/env.sh
for i in 24; do # last day, last week
	#echo $i
	$MAKEHTMLDIR/make_html_occupancy.sh $i T3
	$MAKEHTMLDIR/make_html_usage.sh $i T3
	$MAKEHTMLDIR/make_html_efficiency.sh $i T3
	$MAKEHTMLDIR/make_html_factory.sh $i T3
	$MAKEHTMLDIR/make_html_frontend.sh $i T3
done

