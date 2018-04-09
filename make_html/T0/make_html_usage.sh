#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

OUT="/crabprod/CSstoragePath/aperez/HTML/T0/"$long"multicore_usage_t0_"$int"h.html"
echo '<html>
<head>
<title>CMS multicore pilots core usage monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for site in `echo All_T0s; cat /home/aperez/entries/T0_sites`; do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
      	data_$site.addColumn('number', 'Busy cores'); 
	data_$site.addColumn('number', 'Idle cores');
<!---        data_$site.addColumn('number', 'Preempting'); -->

	data_$site.addRows([">>$OUT
	tail -n $n_lines /crabprod/CSstoragePath/aperez/out/T0/count_$site >/home/aperez/status/input_file_use_$site$long
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time
		content=$(echo $line |awk '{print $5", "$6}')
		echo "[new Date($timemil), $content], " >>$OUT
	done </home/aperez/status/input_file_use_$site$long
	list=$(python /home/aperez/get_averages.py /home/aperez/status/input_file_use_$site$long )
        list_2=$(echo $list |awk -F"] " '{print $4"]", $5"]"}')
        declare "stats_$site=$(echo $list_2)"
	rm /home/aperez/status/input_file_use_$site$long

	echo "      ]);

        var options_$site = {
                title: '$site',
                isStacked: 'true',
		explorer: {},
                'height':500,
		colors: ['#0040FF', '#FF0000'],
                hAxis: {title: 'Time'},
                vAxis: {title: 'Number of cores'}
        };

      	var chart_$site = new google.visualization.AreaChart(document.getElementById('chart_div_$site'));
      	chart_$site.draw(data_$site, options_$site);">>$OUT
done

echo '
    }

    </script>
<style>
p {text-align: center;
   font-family: verdana;
        }
</style>
</head>

<body>
    <div id="header">
        <h2>MULTICORE PILOT USAGE OF CPU CORES AT CMS T0 for the last '$int' hours, updated at '$(date -u)'<br>
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/multicore_occupancy_t0_'$int'h.html">(OCCUPANCY)</a>
        </h2>

    </div>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/multicore_usage_t0_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/multicore_usage_t0_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T0/longmulticore_usage_t0_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in `echo All_T0s; cat /home/aperez/entries/T0_sites`; do
	var="stats_$site"
	echo ' <div id="chart_div_'$site'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
