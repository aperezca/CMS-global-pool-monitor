#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

ratio=1
if [[ $int -gt "720" ]]; then ratio=2; fi # more than 1 month
if [[ $int -gt "1440" ]]; then ratio=3; fi # more than 2 months
if [[ $int -gt "2880" ]]; then ratio=4; fi # more than 4 months
if [[ $int -gt "4320" ]]; then ratio=6; fi # more than 6 months

source /data/srv/aperezca/Monitoring/env.sh
OUT=$HTMLDIR/$long"global_pool_fragment_"$int"h.html"

#-------------------
echo '<html>
<head>
<title>CMS global pool monitor on running glideins fragmentation</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

#----------------------
#Size of dynamic claimed slots in fresh glideins:
echo "var data_fresh = new google.visualization.DataTable();	
data_fresh.addColumn('datetime', 'Date');
data_fresh.addColumn('number', 'slots_1_cores');
data_fresh.addColumn('number', 'slots_2_cores');
data_fresh.addColumn('number', 'slots_3_cores');
data_fresh.addColumn('number', 'slots_4_cores');
data_fresh.addColumn('number', 'slots_5_cores');
data_fresh.addColumn('number', 'slots_6_cores');
data_fresh.addColumn('number', 'slots_7_cores');
data_fresh.addColumn('number', 'slots_8_cores');

data_fresh.addRows([">>$OUT
tail -n $n_lines $OUTDIR/pool_partition_fresh| awk -v var="$ratio" 'NR % var == 0' >$WORKDIR/status/input_part_fresh$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9}')
	echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_part_fresh$int
stats_fresh=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_part_fresh$int)
rm $WORKDIR/status/input_part_fresh$int

echo "      ]);
var options_fresh = {
	title: 'Cores in claimed dynamic slots by slot size for Global Pool glideins',
	isStacked: 'true',
	explorer: {},
	'height':500,
	colors: ['#FF0000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0000FF'],
	hAxis: {title: 'Time'},
	vAxis: {title: 'Number of cores'}
	};

var chart_fresh = new google.visualization.AreaChart(document.getElementById('chart_div_fresh'));
chart_fresh.draw(data_fresh, options_fresh);">>$OUT

#----------------------
# Total number of dynamic slots in the pool:
echo "var data_dyn = new google.visualization.DataTable();    
data_dyn.addColumn('datetime', 'Date');
data_dyn.addColumn('number', 'n_dyn_slots');
data_dyn.addColumn('number', 'n_sta_slots');

data_dyn.addRows([">>$OUT
tail -n $n_lines $OUTDIR/pool_dynslots|awk -v var="$ratio" 'NR % var == 0' >$WORKDIR/status/input_dynslots$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_dynslots$int
stats_dyn=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_dynslots$int)
rm $WORKDIR/status/input_dynslots$int

echo "      ]);
var options_dyn = {
        title: 'Number of dynamic and static slots in the Global Pool',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0000FF', '#00BBFF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of slots'}
        };

var chart_dyn = new google.visualization.AreaChart(document.getElementById('chart_div_dyn'));
chart_dyn.draw(data_dyn, options_dyn);">>$OUT

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
        <h2>CMS Pools partitionable slot fragmentation in running glideins for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="'$WEBPATH'global_pool_fragment_24h.html">24h</a>
	<a href="'$WEBPATH'global_pool_fragment_168h.html">1week</a>
	<a href="'$WEBPATH'longglobal_pool_fragment_720h.html">1month</a>

	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_fresh"></div><p>'$(echo "[avg, min, max]: " $stats_fresh)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_dyn"></div><p>'$(echo "[avg, min, max]: " $stats_dyn)'</p><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
