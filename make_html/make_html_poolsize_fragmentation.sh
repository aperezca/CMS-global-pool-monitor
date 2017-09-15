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

OUT="/crabprod/CSstoragePath/aperez/HTML/"$long"global_pool_fragment_"$int"h.html"
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
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_partition_fresh|awk -v var="$ratio" 'NR % var == 0' >/home/aperez/status/input_part_fresh$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9}')
	echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_part_fresh$int
stats_fresh=$(python /home/aperez/get_averages.py /home/aperez/status/input_part_fresh$int)
rm /home/aperez/status/input_part_fresh$int

echo "      ]);
var options_fresh = {
	title: 'Cores in claimed dynamic slots by slot size for non-retiring glideins',
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

# Size of dynamic claimed slots in retiring glideins:
echo "var data_retire = new google.visualization.DataTable();    
data_retire.addColumn('datetime', 'Date');
data_retire.addColumn('number', 'slots_1_cores');
data_retire.addColumn('number', 'slots_2_cores');
data_retire.addColumn('number', 'slots_3_cores');
data_retire.addColumn('number', 'slots_4_cores');
data_retire.addColumn('number', 'slots_5_cores');
data_retire.addColumn('number', 'slots_6_cores');
data_retire.addColumn('number', 'slots_7_cores');
data_retire.addColumn('number', 'slots_8_cores');

data_retire.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_partition_drain|awk -v var="$ratio" 'NR % var == 0' >/home/aperez/status/input_part_retire$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_part_retire$int
stats_retire=$(python /home/aperez/get_averages.py /home/aperez/status/input_part_retire$int)
rm /home/aperez/status/input_part_retire$int

echo "      ]);
var options_retire = {
        title: 'Cores in claimed dynamic slots by slot size for retiring glideins',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#FF0000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0000FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_retire = new google.visualization.AreaChart(document.getElementById('chart_div_retire'));
chart_retire.draw(data_retire, options_retire);">>$OUT

#----------------------
# Size of partitionable unclaimed slots in fresh glideins:
echo "var data_fresh = new google.visualization.DataTable();    
data_fresh.addColumn('datetime', 'Date');
data_fresh.addColumn('number', 'slots_0_cores');
data_fresh.addColumn('number', 'slots_1_cores');
data_fresh.addColumn('number', 'slots_2_cores');
data_fresh.addColumn('number', 'slots_3_cores');
data_fresh.addColumn('number', 'slots_4_cores');
data_fresh.addColumn('number', 'slots_5_cores');
data_fresh.addColumn('number', 'slots_6_cores');
data_fresh.addColumn('number', 'slots_7_cores');
data_fresh.addColumn('number', 'slots_8_cores');

data_fresh.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_occupancy_fresh|awk -v var="$ratio" 'NR % var == 0' >/home/aperez/status/input_part_fresh$int

while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_part_fresh$int
stats_occ_fresh=$(python /home/aperez/get_averages.py /home/aperez/status/input_part_fresh$int)
rm /home/aperez/status/input_part_fresh$int

echo "      ]);
var options_occ_fresh = {
        title: 'Partitionable slots occupancy for non-retiring 8-core glideins',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#FF0000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0080FF', '#0000FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_occ_fresh = new google.visualization.AreaChart(document.getElementById('chart_div_occ_fresh'));
chart_occ_fresh.draw(data_fresh, options_occ_fresh);">>$OUT
#---------------------
# Size of partitionable unclaimed slots in retiring glideins:
echo "var data_retire = new google.visualization.DataTable();    
data_retire.addColumn('datetime', 'Date');
data_retire.addColumn('number', 'slots_0_cores');
data_retire.addColumn('number', 'slots_1_cores');
data_retire.addColumn('number', 'slots_2_cores');
data_retire.addColumn('number', 'slots_3_cores');
data_retire.addColumn('number', 'slots_4_cores');
data_retire.addColumn('number', 'slots_5_cores');
data_retire.addColumn('number', 'slots_6_cores');
data_retire.addColumn('number', 'slots_7_cores');
data_retire.addColumn('number', 'slots_8_cores');

data_retire.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/pool_occupancy_drain|awk -v var="$ratio" 'NR % var == 0' >/home/aperez/status/input_part_drain$int

while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_part_drain$int
stats_occ_drain=$(python /home/aperez/get_averages.py /home/aperez/status/input_part_drain$int)
rm /home/aperez/status/input_part_drain$int

echo "      ]);
var options_occ_drain = {
        title: 'Partitionable slots occupancy for retiring 8-core glideins',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#FF0000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0080FF', '#0000FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_occ_drain = new google.visualization.AreaChart(document.getElementById('chart_div_occ_drain'));
chart_occ_drain.draw(data_retire, options_occ_drain);">>$OUT
#---------------------
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
        <h2>CMS Global pool partitionable slot fragmentation and occupancy in running glideins for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_fragment_24h.html">24h</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_fragment_168h.html">1week</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_fragment_720h.html">1month</a>

	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_fresh"></div><p>'$(echo "[avg, min, max]: " $stats_fresh)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_retire"></div><p>'$(echo "[avg, min, max]: " $stats_retire)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_occ_fresh"></div><p>'$(echo "[avg, min, max]: " $stats_occ_fresh)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_occ_drain"></div><p>'$(echo "[avg, min, max]: " $stats_occ_drain)'</p><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
