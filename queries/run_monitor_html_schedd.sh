#make HTML plots for each schedd
source /data/srv/aperezca/Monitoring/env.sh

#for i in 24 168; do # last day, last week, last month
for i in 24; do # last day, last week, last month
	for schedd in $(cat $WORKDIR/status/schedd_names_*); do
		echo $schedd $i
		$MAKEHTMLDIR/make_html_scheddstatus.sh $schedd $i
	done
done

# ------------
# Make index html file 
OUT=$HTMLDIR"/Schedds/schedd_status_index.html"
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
# Insert info on dropped schedds:
while read -r line; do
	echo $line '<br>'>>$OUT
done<$HTMLDIR/globalpool_dropped_schedds.txt
echo '<br>' >>$OUT

for i in 'prod' 'crab' 'tier0' 'other'; do
	echo '<h3>'$i' schedds </h3><br>' >>$OUT
	for schedd in $(cat $WORKDIR/status/schedd_names_$i); do
        	echo $schedd '<a href="'$WEBPATH'Schedds/'$schedd'_status_24h.html" target="blank">24h</a>
        	<a href="'$WEBPATH'Schedds/'$schedd'_status_168h.html" target="blank">1week</a>
		<a href="http://vocms0801.cern.ch/ganglia/?r=day&cs=&ce=&m=load_one&c=VOCMS&h='$schedd'&tab=m&vn=&hide-hf=false&mc=2&z=small&metric_group=ALLGROUPS" target="blank">ganglia</a>
	<br>'>>$OUT
	done
	echo '<br>'>>$OUT
done
echo '	</h2><br>
    </div>
<br>
</body>
</html>'>>$OUT

