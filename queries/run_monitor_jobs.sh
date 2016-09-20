#query collector, factories and frontend:
/home/aperez/get_jobs_in_pool_site.sh 

#make HTML plots
for i in 24 168 720; do # 1h, 6h, 12h, last day, last week, last month
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T1
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T2
done

