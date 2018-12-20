for i in 720; do # last month
	#echo $i
	/crabprod/CSstoragePath/aperez/T0/make_html_occupancy.sh $i
        /crabprod/CSstoragePath/aperez/T0/make_html_usage.sh $i
        /crabprod/CSstoragePath/aperez/T0/make_html_factory.sh $i
done
