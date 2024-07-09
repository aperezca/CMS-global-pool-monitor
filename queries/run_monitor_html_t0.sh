source /data/srv/aperezca/Monitoring/env.sh
for i in 24; do # last day, last week
	#echo $i
	$MAKEHTMLDIR/T0/make_html_occupancy.sh $i
	$MAKEHTMLDIR/T0/make_html_usage.sh $i
done

