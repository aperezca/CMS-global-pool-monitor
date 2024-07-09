
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
OUT="$HTMLDIR/"$list"s/"$long"multicore_eff_"$list"s_"$int"h.html"
#---------------
echo '<html>
<head>
<title>CMS multicore pilots core usage efficiency monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for site in `echo "All_"$list"s"; cat $WORKDIR/entries/"$list"_sites`; do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
	data_$site.addColumn('number', 'occupancy');
	data_$site.addRows([">>$OUT
	tail -n $n_lines $OUTDIR/count_$site >$WORKDIR/status/input_file_eff_$site$int
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
        <h2>MULTICORE PILOT USAGE OF CPU CORES AT CMS '$list's for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="'$WEBPATH''$list's/multicore_occupancy_'$list's_'$int'h.html">(OCCUPANCY)</a>
	<a href="'$WEBPATH''$list's/multicore_factory_'$list's_'$int'h.html">(FACTORY STATUS)</a>
	<a href="'$WEBPATH''$list's/multicore_frontend_'$list's_'$int'h.html">(FRONT-END)</a>
	</h2>
    </div>
<a href="'$WEBPATH''$list's/multicore_eff_'$list's_24h.html">24h</a>
<a href="'$WEBPATH''$list's/multicore_eff_'$list's_168h.html">1week</a>
<a href="'$WEBPATH''$list's/longmulticore_eff_'$list's_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in `echo "All_"$list"s"; cat $WORKDIR/entries/"$list"_sites`; do
	var="stats_$site"
        echo ' <div id="chart_div_'$site'"></div><p></p><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
