
OUTDIR="/crabprod/CSstoragePath/aperez"

for i in 24 168; do # last day, last week
	#echo $i
	$OUTDIR/T2s/make_html_occupancy.sh $i
	$OUTDIR/T2s/make_html_usage.sh $i
	$OUTDIR/T2s/make_html_efficiency.sh $i
	$OUTDIR/T2s/make_html_factory.sh $i
	$OUTDIR/T2s/make_html_frontend.sh $i
done

