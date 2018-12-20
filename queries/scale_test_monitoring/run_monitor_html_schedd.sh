#make HTML plots for each schedd

WORKDIR="/home/aperez/scale_test_monitoring"
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"

for i in 24 168; do # last day, last week, last month
	for schedd in $(cat $WORKDIR/status/schedds_*); do
		echo $schedd $i
		$OUTDIR/make_html_scheddstatus.sh $schedd $i
	done
done

# Make index html file 
OUT=$OUTDIR"/HTML/Schedds/schedd_status_index.html"
echo '<html>
<head>
<title>Schedd status monitor</title>
<style>
p {text-align: center;
   font-family: verdana;
        }
</style>
</head>

<body>
    <div id="header">
	<h2> Schedd status monitor index <br></h2><br>'>$OUT
for i in 'prod' 'crab'; do
	echo '<h3>'$i' schedds </h3><br>' >>$OUT
	for schedd in $(cat $WORKDIR/status/schedds_$i); do
        	echo $schedd '<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/scale_test_monitoring/HTML/Schedds/'$schedd'_status_24h.html">24h</a>
        	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/scale_test_monitoring/HTML/Schedds/'$schedd'_status_168h.html">1week</a>
		<a href="http://hcc-ganglia.unl.edu/?r=hour&cs=&ce=&c=crab-infrastructure&h='$schedd'&tab=m&vn=&hide-hf=false&m=load_report&sh=1&z=small&hc=4&host_regex=&max_graphs=0&s=by+name">ganglia</a>
	<br>'>>$OUT
	done
	echo '<br>'>>$OUT
done
echo '	</h2><br>
    </div>
<br>
</body>
</html>'>>$OUT

