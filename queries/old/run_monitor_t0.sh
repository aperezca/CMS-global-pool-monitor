/home/aperez/multi-core_t0_count.sh
#/home/aperez/multi-core_t0_factories.sh
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/T0/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/T0/make_html_usage.sh $i
done
