input="udp_10s_vocms032_24h"
#input="udp_1s_vocms032"
#input="udp_1s_vocms0807"
OUT="/crabprod/CSstoragePath/aperez/HTML/"$input".html"
echo '<html>
<head>
<title>CMS global pool udp backlog monitor monitor</title>
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
data_pool.addColumn('number', 'UDP buffer size');

data_pool.addRows([">>$OUT
#tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_size >/home/aperez/status/input_pool_size$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2}')
	if [[ $content -eq "" ]]; then let content=0; fi
	echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/udp/$input

#stats_size=$(python /home/aperez/get_averages.py /home/aperez/status/input_pool_size$int)
#rm /home/aperez/status/input_pool_size$int

echo "      ]);
var options_pool = {
	title: 'UDP backlog',
	isStacked: 'true',
	explorer: {},
	'height':500,
	colors: ['#0000A0'],
	hAxis: {title: 'Time'},
	vAxis: {title: 'Bytes'}
	};

var chart_pool = new google.visualization.AreaChart(document.getElementById('chart_div_pool'));
chart_pool.draw(data_pool, options_pool);">>$OUT

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
	UDP BACKLOG MONITOR '$input'
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
#echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_size)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_pool"></div>'>>$OUT
echo "
</body>
</html>" >>$OUT
