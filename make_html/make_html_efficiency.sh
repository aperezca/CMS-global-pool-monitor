WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

OUT="$OUTDIR/HTML/T1s/"$long"multicore_eff_t1s_"$int"h.html"
echo '<html>
<head>
<title>CMS multicore pilots core usage efficiency monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for site in `echo "All_T1s"; cat $WORKDIR/entries/T1_sites`; do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
	data_$site.addColumn('number', 'occupancy');
	data_$site.addRows([">>$OUT
	tail -n $n_lines $OUTDIR/out/count_$site >$WORKDIR/status/input_file_eff_$site$int
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time
		busy=$(echo $line |awk '{print $5}')
		idle=$(echo $line |awk '{print $6}')
		if [[ $busy+$idle -ne 0 ]]; then
                	content=$(echo $busy $idle |awk '{print $1/($1+$2)}')
                        echo "[new Date($timemil), $content], " >>$OUT
                fi
	done <$WORKDIR/status/input_file_eff_$site$int
	rm $WORKDIR/status/input_file_eff_$site$int

	echo "      ]);

        var options_$site = {
                title: '$site',
                isStacked: 'true',
        	explorer: {},
                'height':500,
		colors: ['#0040FF', '#FF0000'],
                hAxis: {title: 'Time'},
                vAxis: {title: 'Percentage of busy cores'}
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
        <h2>MULTICORE PILOT USAGE OF CPU CORES AT CMS T1s for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/multicore_occupancy_t1s_'$int'h.html">(OCCUPANCY)</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/multicore_factory_t1s_'$int'h.html">(FACTORY STATUS)</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/multicore_frontend_t1s_'$int'h.html">(FRONT-END)</a>
	</h2>
    </div>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/multicore_eff_t1s_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/multicore_eff_t1s_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/longmulticore_eff_t1s_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in `echo "All_T1s"; cat $WORKDIR/entries/T1_sites`; do
	var="stats_$site"
        echo ' <div id="chart_div_'$site'"></div><p></p><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
