#query collector, factories and frontend:
/home/aperez/multi-core_t1_count.sh
/home/aperez/multi-core_factories.sh T1s
/home/aperez/multi-core_frontend.sh
/home/aperez/get_pool_size.sh
/home/aperez/get_pool_idle.sh
/home/aperez/get_pool_mcore_idle.sh
/home/aperez/get_jobs_in_pool.sh
/home/aperez/get_jobs_cores_in_pool.sh

#make HTML plots
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/make_html_frontend.sh $i
	/crabprod/CSstoragePath/aperez/make_html_poolsize.sh $i
	/crabprod/CSstoragePath/aperez/make_html_jobstatus.sh $i
done
mv /crabprod/CSstoragePath/aperez/multicore_*.html /crabprod/CSstoragePath/aperez/HTML
