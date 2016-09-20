/home/aperez/get_pool_ucsd_size.sh

#make HTML plots
for i in 24 168 720; do # 1h, 6h, 12h, last day, last week
	#echo $i
	/crabprod/CSstoragePath/aperez/make_html_ucsd_poolsize.sh $i
done
