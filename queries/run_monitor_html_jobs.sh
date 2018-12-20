
WORKDIR="/crabprod/CSstoragePath/aperez"

#make HTML plots
for i in 24 168; do # last day, last week
	#echo $i
	$WORKDIR/make_html_job_sites.sh $i T0
	$WORKDIR/make_html_job_sites.sh $i T1
	$WORKDIR/make_html_job_sites.sh $i T2
done

