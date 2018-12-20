#make HTML plots
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"
for i in 24 168; do # last day, last week, last month
	#echo $i
	#for sch in 'vocms0810.cern.ch' 'vocms0813.cern.ch' 'vocms0814.cern.ch' 'vocms0811.cern.ch' 'vocms0812.cern.ch' 'vocms0123.cern.ch' 'vocms0125.cern.ch'; do
	for sch in 'vocms0810.cern.ch' 'vocms0813.cern.ch' 'vocms0814.cern.ch' 'vocms0811.cern.ch' 'vocms0812.cern.ch' 'vocms0817.cern.ch' 'vocms0818.cern.ch' 'vocms0123.cern.ch' 'vocms0125.cern.ch' 'vocms009.cern.ch' 'vocms040.cern.ch' 'vocms0231.cern.ch'; do
		$OUTDIR/make_html_scheddstatus.sh $sch $i
	done
done
