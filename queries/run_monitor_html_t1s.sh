#make HTML plots
source /data/srv/aperezca/Monitoring/env.sh
for i in 24; do # 1h, 6h, 12h, last day, last week
	#echo $i
	$MAKEHTMLDIR/make_html_occupancy.sh $i T1
	$MAKEHTMLDIR/make_html_usage.sh $i T1
	$MAKEHTMLDIR/make_html_efficiency.sh $i T1
	$MAKEHTMLDIR/make_html_factory.sh $i T1
	$MAKEHTMLDIR/make_html_frontend.sh $i T1
done
