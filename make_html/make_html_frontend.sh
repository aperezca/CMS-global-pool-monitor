
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
OUT=$HTMLDIR/$list"s/"$long"multicore_frontend_"$list"s_"$int"h.html"
#----------------
echo '<html>
<head>
<title>CMS multicore pilots frontend requested idle monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for site in `cat $WORKDIR/entries/"$list"_sites`; do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
      	data_$site.addColumn('number', 'CERN t1prod'); 
	data_$site.addColumn('number', 'CERN main');
<!--    data_$site.addColumn('number', 'FNAL t1prod'); -->
<!-- 	data_$site.addColumn('number', 'FNAL main'); -->

	data_$site.addRows([">>$OUT
	tail -n $n_lines $OUTDIR/frontend_$site >$WORKDIR/status/input_file_frontend_$site$int
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time
		#content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
		val=$(echo $line |awk '{print $2+$3}')
		#echo $val
		content="0, $val"
		echo "[new Date($timemil), $content], " >>$OUT
	done <$WORKDIR/status/input_file_frontend_$site$int
	declare "stats_$site=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_file_frontend_$site$int)"
	rm $WORKDIR/status/input_file_frontend_$site$int

	echo "      ]);

        var options_$site = {
                title: '$site',
                isStacked: 'true',
                explorer: {},
                'height':500,
		colors: ['#FF0000', '#FF8000'],
                hAxis: {title: 'Time'},
                vAxis: {title: 'Number of req. idle multicore pilots per FE and group'}
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
        <h2>FRONT_END REQ. IDLE STATUS OF MULTICORE PILOTS AT CMS '$list's for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="'$WEBPATH'T1s/multicore_factory_T1s_'$int'h.html">(FACTORY)</a>
	<a href="'$WEBPATH'T1s/multicore_usage_T1s_'$int'h.html">(USAGE)</a>
	<a href="'$WEBPATH'T1s/multicore_occupancy_T1s_'$int'h.html">(OCCUPANCY)</a>
	</h2>
    </div>
<a href="'$WEBPATH'T1s/multicore_frontend_T1s_24h.html">24h</a>
<a href="'$WEBPATH'T1s/multicore_frontend_T1s_168h.html">1week</a>
<a href="'$WEBPATH'T1s/longmulticore_frontend_T1s_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in `cat $WORKDIR/entries/"$list"_sites`; do
	var="stats_$site"
        echo ' <div id="chart_div_'$site'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
