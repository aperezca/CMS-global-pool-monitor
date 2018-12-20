WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

$WORKDIR/get_volunteer_pool_status.sh
#for i in 24 168; do # last day, last week
#	#echo $i
#	$OUTDIR/Volunteer/make_html_occupancy.sh $i
#	$OUTDIR/Volunteer/make_html_usage.sh $i
#done
