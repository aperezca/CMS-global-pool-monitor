#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

OUT="/crabprod/CSstoragePath/aperez/HTML/"$long"ucsd_pool_size_"$int"h.html"
echo '<html>
<head>
<title>CMS UCSD pool monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

#----------------------
#Pool size:
echo "var data_pool = new google.visualization.DataTable();	
data_pool.addColumn('datetime', 'Date');
data_pool.addColumn('number', 'pilot cores'); 
data_pool.addColumn('number', 'job cores');

data_pool.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/ucsd_pool_size >/home/aperez/status/input_ucsd_pool_size
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3}')
	echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_ucsd_pool_size
stats_pool=$(python /home/aperez/get_averages.py /home/aperez/status/input_ucsd_pool_size)
rm /home/aperez/status/input_ucsd_pool_size

echo "      ]);
var options_pool = {
	title: 'UCSD pool cores in running pilots and jobs',
	isStacked: 'false',
	explorer: {},
	'height':500,
	colors: ['#0000A0', '#B2C248'],
	hAxis: {title: 'Time'},
	vAxis: {title: 'Number of cores', 
		minValue: 0}
	};

var chart_pool = new google.visualization.AreaChart(document.getElementById('chart_div_pool'));
chart_pool.draw(data_pool, options_pool);">>$OUT
#--------------------
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
        <h2>UCSD POOL MONITOR size for the last '$int' hours<br>
	</h2><br>
    </div>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/ucsd_pool_size_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/ucsd_pool_size_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longucsd_pool_size_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_pool)'</p><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
