#query collector, factories and frontend:
/home/aperez/get_jobs_in_pool_site.sh 

#make HTML plots
for i in 24 168; do # last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T0
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T1
	/crabprod/CSstoragePath/aperez/make_html_job_sites.sh $i T2
done

