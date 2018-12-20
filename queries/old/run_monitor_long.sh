for i in 720; do # last month
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/make_html_frontend.sh $i
	/crabprod/CSstoragePath/aperez/make_html_poolsize.sh $i
	/crabprod/CSstoragePath/aperez/make_html_jobstatus.sh $i
done
mv /crabprod/CSstoragePath/aperez/longmulticore_*.html /crabprod/CSstoragePath/aperez/HTML
