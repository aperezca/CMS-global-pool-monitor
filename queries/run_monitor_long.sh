for i in 720 2160 4320 6480 8640; do # last 1, 3, 6, 9, 12 months
	#global pool
	/crabprod/CSstoragePath/aperez/make_html_global_pool.sh $i
        /crabprod/CSstoragePath/aperez/make_html_jobstatus.sh $i
	/crabprod/CSstoragePath/aperez/make_html_pool_negotime.sh $i
	/crabprod/CSstoragePath/aperez/make_html_pool_fragmentation.sh $i
	/crabprod/CSstoragePath/aperez/make_html_poolsize_only.sh $i
done
for i in 720; do # last month
	#job info per site
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T0
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T1
        /crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T2
	#T1s
	/crabprod/CSstoragePath/aperez/make_html_occupancy.sh $i
	/crabprod/CSstoragePath/aperez/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/make_html_efficiency.sh $i
	/crabprod/CSstoragePath/aperez/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/make_html_frontend.sh $i
	#T0
	/crabprod/CSstoragePath/aperez/T0/make_html_occupancy.sh $i
        /crabprod/CSstoragePath/aperez/T0/make_html_usage.sh $i
        /crabprod/CSstoragePath/aperez/T0/make_html_factory.sh $i
	#T2s
	/crabprod/CSstoragePath/aperez/T2s/make_html_occupancy.sh $i
        /crabprod/CSstoragePath/aperez/T2s/make_html_usage.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_efficiency.sh $i
        /crabprod/CSstoragePath/aperez/T2s/make_html_factory.sh $i
	/crabprod/CSstoragePath/aperez/T2s/make_html_frontend.sh $i
done

mv /crabprod/CSstoragePath/aperez/longmulticore_*.html /crabprod/CSstoragePath/aperez/HTML
