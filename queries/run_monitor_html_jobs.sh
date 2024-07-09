#make HTML plots
source /data/srv/aperezca/Monitoring/env.sh
for i in 24; do # last day, last week
	#echo $i
	$MAKEHTMLDIR/make_html_job_sites.sh $i T0
	$MAKEHTMLDIR/make_html_job_sites.sh $i T1
	$MAKEHTMLDIR/make_html_job_sites.sh $i T2
	$MAKEHTMLDIR/make_html_job_sites.sh $i T3
done

