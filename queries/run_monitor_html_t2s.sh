for i in 24 168; do # last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_efficiency.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_frontend.sh $i
done
