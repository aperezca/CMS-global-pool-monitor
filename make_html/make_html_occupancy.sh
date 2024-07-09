
#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
        long="long"
else
        long=""
fi

# Range of sites to plot
list=$2
source /data/srv/aperezca/Monitoring/env.sh
OUT=$HTMLDIR/$list"s/"$long"multicore_occupancy_"$list"s_"$int"h.html"
#---------------
echo '<html>
<head>
<title>CMS multicore pilots core occupancy monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT
for site in `cat "$WORKDIR/entries/"$list"_sites"`; do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
      	data_$site.addColumn('number', 'pilot_0');
      	data_$site.addColumn('number', 'pilot_1'); 
	data_$site.addColumn('number', 'pilot_2');
        data_$site.addColumn('number', 'pilot_3');
        data_$site.addColumn('number', 'pilot_4');
        data_$site.addColumn('number', 'pilot_5');
        data_$site.addColumn('number', 'pilot_6');
        data_$site.addColumn('number', 'pilot_7');
        data_$site.addColumn('number', 'pilot_8');">>$OUT

	if [ $site == "T1_RU_JINR" ]; then echo "
	data_$site.addColumn('number', 'pilot_9');
        data_$site.addColumn('number', 'pilot_10');">>$OUT
	fi
	
	echo "data_$site.addRows([">>$OUT

	tail -n $n_lines $OUTDIR/occup_$site > $WORKDIR/status/input_file_occ_$site$int
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time
		#datetime=$(date -d @$time -u +%Y-%m-%dT%T%z)
		#content_8=$(echo $line|awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
		if [ $site == "T1_RU_JINR" ]; then
			content=$(echo $line|awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10", "$11", "$12}')
			echo "[new Date($timemil), $content], " >>$OUT
		else
			content=$(echo $line|awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
			echo "[new Date($timemil), $content], " >>$OUT
		fi
		#echo $content
	done  <$WORKDIR/status/input_file_occ_$site$int
	rm $WORKDIR/status/input_file_occ_$site$int

	echo "      ]);

      	var options_$site = {
		title: '$site', 
                explorer: {},
		isStacked: 'true', 
		'height':500, ">>$OUT

	if [ $site == "T1_RU_JINR" ]; then
	echo "colors: ['#FF0000', '#FF4000', '#FF6000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0040FF', '#0000FF'],">>$OUT
	else
	echo "colors: ['#FF0000', '#FF4000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0000FF'],">>$OUT
	fi
	echo "	hAxis: {title: 'Time'},
		vAxis: {title: 'Number of pilots by occupancy'}
	};
      	var chart_$site = new google.visualization.AreaChart(document.getElementById('chart_div_$site'));
      	chart_$site.draw(data_$site, options_$site);">>$OUT
done

echo '
    }

    </script>

</head>

<body>
    <div id="header">
        <h2>CORE OCCUPANCY OF RUNNING MULTICORE PILOTS AT CMS '$list's for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="'$WEBPATH'T1s/multicore_usage_T1s_'$int'h.html">(USAGE)</a>
	<a href="'$WEBPATH'T1s/multicore_factory_T1s_'$int'h.html">(FACTORY STATUS)</a>
	<a href="'$WEBPATH'T1s/multicore_frontend_T1s_'$int'h.html">(FRONT-END)</a>
	</h2>
    </div>
<a href="'$WEBPATH'T1s/multicore_occupancy_T1s_24h.html">24h</a>
<a href="'$WEBPATH'T1s/multicore_occupancy_T1s_168h.html">1week</a>
<a href="'$WEBPATH'T1s/longmulticore_occupancy_T1s_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in `cat "$WORKDIR/entries/"$list"_sites"`; do
	echo ' <div id="chart_div_'$site'"></div><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
