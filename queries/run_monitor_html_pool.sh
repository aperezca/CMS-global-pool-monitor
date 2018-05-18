#make HTML plots
for i in 24 168; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_global_pool.sh $i
	/crabprod/CSstoragePath/aperez/make_html_jobstatus.sh $i
	/crabprod/CSstoragePath/aperez/make_html_pool_negotime.sh $i
	/crabprod/CSstoragePath/aperez/make_html_pool_fragmentation.sh $i
	/crabprod/CSstoragePath/aperez/make_html_jobstatus_resizable.sh $i
done
