/home/aperez/get_pool_ucsd_size.sh

#make HTML plots
for i in 24 168 720; do # last day, last week, last month
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_ucsd_poolsize.sh $i
done
