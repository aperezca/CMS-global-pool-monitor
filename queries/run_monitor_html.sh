#make HTML plots
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/make_html_frontend.sh $i
	/crabprod/CSstoragePath/aperez/make_html_poolsize.sh $i
	/crabprod/CSstoragePath/aperez/make_html_jobstatus.sh $i
	/crabprod/CSstoragePath/aperez/make_html_poolsize_fragmentation.sh $i
done
mv /crabprod/CSstoragePath/aperez/*.html /crabprod/CSstoragePath/aperez/HTML/
