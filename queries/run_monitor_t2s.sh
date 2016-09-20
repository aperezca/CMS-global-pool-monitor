/home/aperez/multi-core_t2_count.sh
/home/aperez/multi-core_factories.sh T2s
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_frontend.sh $i
done
