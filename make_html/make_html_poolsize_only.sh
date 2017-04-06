#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

OUT="/crabprod/CSstoragePath/aperez/HTML/"$long"global_pool_size_only_"$int"h.html"
echo '<html>
<head>
<title>CMS global pool running glideins monitor</title>
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
data_pool.addColumn('number', 'T1 mcore'); 
data_pool.addColumn('number', 'T2 mcore');
data_pool.addColumn('number', 'T2 score');
data_pool.addColumn('number', 'T3 score');

data_pool.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_size >/home/aperez/status/input_pool_size$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
	echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_pool_size$int
stats_size=$(python /home/aperez/get_averages.py /home/aperez/status/input_pool_size$int)
rm /home/aperez/status/input_pool_size$int

echo "      ]);
var options_pool = {
	title: 'Global pool running cores',
	isStacked: 'true',
	explorer: {},
	'height':500,
	colors: ['#0000A0', '#1569C7', '#52D017', '#B2C248'],
	hAxis: {title: 'Time'},
	vAxis: {title: 'Number of cores'}
	};

var chart_pool = new google.visualization.AreaChart(document.getElementById('chart_div_pool'));
chart_pool.draw(data_pool, options_pool);">>$OUT

#----------------------
#Pool diff:
#echo "var data_diff = new google.visualization.DataTable();
#data_diff.addColumn('datetime', 'Date');
#data_diff.addColumn('number', 'cores finishing pilots');
#data_diff.addColumn('number', 'cores starting pilots');

#echo "var data_diff = new google.visualization.DataTable();
#data_diff.addColumn('datetime', 'Date');
#data_diff.addColumn('number', 'cores starting-finishing pilots');
#
#data_diff.addRows([">>$OUT
#tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_diff_total >/home/aperez/status/input_pool_diff$int
#while read -r line; do
#        time=$(echo $line |awk '{print $1}')
#        let timemil=1000*$time
#        #content=$(echo $line |awk '{print $2", "$3}')
#	content=$(echo $line |awk '{print -$2+$3}')
#        echo "[new Date($timemil), $content], " >>$OUT
#done </home/aperez/status/input_pool_diff$int
#stats_diff=$(python /home/aperez/get_averages.py /home/aperez/status/input_pool_diff$int)
#rm /home/aperez/status/input_pool_diff$int
#
#echo "      ]);
#var options_diff = {
#        title: 'Global pool starting and finishing pilot cores',
#        isStacked: 'true',
#        explorer: {},
#        'height':500,
#        colors: ['#0000A0', '#52D017'],
#        hAxis: {title: 'Time'},
#        vAxis: {title: 'Number of cores'}
#        };
#
#var chart_diff = new google.visualization.AreaChart(document.getElementById('chart_div_diff'));
#chart_diff.draw(data_diff, options_diff);">>$OUT

#----------------------
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
        <h2>CMS GLOBAL POOL MONITOR: Global pool size and components for the last '$int' hours, updated at '$(date -u)'<br>
	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_size)'</p><br><br>'>>$OUT
#echo ' <div id="chart_div_diff"></div><p>'$(echo "[avg, min, max]: " $stats_diff)'</p><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
