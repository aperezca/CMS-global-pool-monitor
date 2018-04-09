#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
        long="long"
else
        long=""
fi

OUT="/crabprod/CSstoragePath/aperez/HTML/T0/"$long"multicore_occupancy_t0_"$int"h.html"
echo '<html>
<head>
<title>CMS multicore pilots core occupancy monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for site in `cat /home/aperez/entries/T0_sites`; do
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

	echo "data_$site.addRows([">>$OUT

	tail -n $n_lines /crabprod/CSstoragePath/aperez/out/T0/occup_$site > /home/aperez/status/input_file_occ_$site$long
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time
		content_8=$(echo $line|awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
		if [ $site == "T1_RU_JINR" ]; then
			content=$(echo $line|awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10", "$11", "$12", "$13", "$14}')
			echo "[new Date($timemil), $content], " >>$OUT
		else
			content=$(echo $line|awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
			echo "[new Date($timemil), $content], " >>$OUT
		fi
	done  </home/aperez/status/input_file_occ_$site$long
	rm /home/aperez/status/input_file_occ_$site$long

	echo "      ]);

      	var options_$site = {
		title: '$site', 
		isStacked: 'true',
		explorer: {}, 
		'height':500, ">>$OUT

	echo "colors: ['#FF0000', '#FF4000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0000FF'],">>$OUT
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
        <h2>CORE OCCUPANCY OF RUNNING MULTICORE PILOTS AT CMS T0 for the last '$int' hours, updated at '$(date -u)'<br>
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/'$long'multicore_usage_t0_'$int'h.html">(USAGE)</a>
	</h2>
    </div>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/multicore_occupancy_t0_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/multicore_occupancy_t0_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/longmulticore_occupancy_t0_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in `cat /home/aperez/entries/T0_sites`; do
	echo ' <div id="chart_div_'$site'"></div><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
