for i in 720; do # last month
	#echo $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_occupancy.sh $i
        /crabprod/CSstoragePath/aperez/T2s/make_html_usage.sh $i
        /crabprod/CSstoragePath/aperez/T2s/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_frontend.sh $i
done
