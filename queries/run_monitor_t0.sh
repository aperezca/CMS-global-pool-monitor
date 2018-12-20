WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

$WORKDIR/multi-core_t0_count.sh
$WORKDIR/get_cern_pool_status.sh
for i in 24 168; do # last day, last week
	#echo $i
	$OUTDIR/T0/make_html_occupancy.sh $i
	$OUTDIR/T0/make_html_usage.sh $i
done

