/home/aperez/multi-core_t0_count.sh
/home/aperez/get_cern_pool_status.sh
for i in 24 168; do # last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/T0/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/T0/make_html_usage.sh $i
done
