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

OUT="$OUTDIR/HTML/"$long"global_pool_view_"$int"h.html"
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
tail -n $n_lines $OUTDIR/out/pool_size >$WORKDIR/status/input_pool_size$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
	echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_pool_size$int
stats_size=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_pool_size$int)
rm $WORKDIR/status/input_pool_size$int

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
#Pool busy and idle cores:
echo "var data_poolidle = new google.visualization.DataTable();     
data_poolidle.addColumn('datetime', 'Date');
data_poolidle.addColumn('number', 'mcore busy'); 
data_poolidle.addColumn('number', 'score busy');
data_poolidle.addColumn('number', 'mcore idle');
data_poolidle.addColumn('number', 'score idle');

data_poolidle.addRows([">>$OUT
tail -n $n_lines $OUTDIR/out/pool_idle >$WORKDIR/status/input_pool_idle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$4", "$3", "$5}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_pool_idle$int
stats_idle=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_pool_idle$int)
rm $WORKDIR/status/input_pool_idle$int

echo "      ]);
var options_poolidle = {
        title: 'Global pool busy and idle cores per type of pilot',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#0060FF', '#FF0000', '#FF3000'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_poolidle = new google.visualization.AreaChart(document.getElementById('chart_div_poolidle'));
chart_poolidle.draw(data_poolidle, options_poolidle);">>$OUT

#----------------------
#Pool usage efficiencies:
#echo "var data_pooleff = new google.visualization.DataTable();     
#data_pooleff.addColumn('datetime', 'Date');
#data_pooleff.addColumn('number', 'mcore occupation'); 
#data_pooleff.addColumn('number', 'score occupation');
#data_pooleff.addColumn('number', 'pool occupation');

#data_pooleff.addRows([">>$OUT
#tail -n $n_lines $OUTDIR/out/pool_idle >$WORKDIR/status/input_pool_idle$int
#while read -r line; do
#        time=$(echo $line |awk '{print $1}')
#        let timemil=1000*$time
#	m_b=$(echo $line |awk '{print $2}')
#	m_i=$(echo $line |awk '{print $3}')
#	s_b=$(echo $line |awk '{print $4}')
#	s_i=$(echo $line |awk '{print $5}')
#	if [[ $m_b+$m_i -ne 0 ]] && [[ $s_b+$s_i -ne 0 ]]; then
#		content=$(echo $m_b $m_i $s_b $s_i |awk '{print $1/($1+$2)", "$3/($3+$4)", "($1+$3)/($1+$2+$3+$4)}')
#		echo "[new Date($timemil), $content], " >>$OUT
#	fi
#done <$WORKDIR/status/input_pool_idle$int
#rm $WORKDIR/status/input_pool_idle$int

#echo "      ]);
#var options_pooleff = {
#        title: 'Global pool pilot occupation percentages',
#        isStacked: 'false',
#        explorer: {},
#        'height':500,
#        colors: ['#0040FF', '#0060FF', '#9090FF'],
#        hAxis: {title: 'Time'},
#        vAxis: {title: 'Occupation (%)', minValue: 0, maxValue: 1}
#        };

#var chart_pooleff = new google.visualization.AreaChart(document.getElementById('chart_div_pooleff'));
#chart_pooleff.draw(data_pooleff, options_pooleff);">>$OUT

#---------------------------
# Running jobs in pool by type 
#echo "var data_jobs = new google.visualization.DataTable();
#data_jobs.addColumn('datetime', 'Date');
#data_jobs.addColumn('number', 'Prod jobs');
#data_jobs.addColumn('number', 'Analysis jobs');
#
#data_jobs.addRows([">>$OUT
#tail -n $n_lines $OUTDIR/out/jobs_running_global >$WORKDIR/status/input_jobs_running_global$int
#while read -r line; do
#        time=$(echo $line |awk '{print $1}')
#        let timemil=1000*$time
#        content=$(echo $line |awk '{print $2", "$3}')
#        echo "[new Date($timemil), $content], " >>$OUT
#done <$WORKDIR/status/input_jobs_running_global$int
#stats_jobs=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobs_running_global$int)
#rm $WORKDIR/status/input_jobs_running_global$int
#
#echo "      ]);
#var options_jobs = {
#        title: 'Global and T0 pool running production and analysis job cores',
#        isStacked: 'true',
#        explorer: {},
#        'height':500,
#	colors: ['#1569C7', '#52D017'],
#        hAxis: {title: 'Time'},
#        vAxis: {title: 'Number of cores'}
#        };
#
#var chart_jobs = new google.visualization.AreaChart(document.getElementById('chart_div_jobs'));
#chart_jobs.draw(data_jobs, options_jobs);">>$OUT

#---------------------------
# Running jobs in pool by type and Tier 0, 1 and 2:
#echo "var data_jobstier = new google.visualization.DataTable();
#data_jobstier.addColumn('datetime', 'Date');
#data_jobstier.addColumn('number', 'T0 Prod jobs');
#data_jobstier.addColumn('number', 'T1 Prod jobs');
#data_jobstier.addColumn('number', 'T1 Analysis jobs');
#data_jobstier.addColumn('number', 'T2 Prod jobs');
#data_jobstier.addColumn('number', 'T2 Analysis jobs');
#
#data_jobstier.addRows([">>$OUT
#tail -n $n_lines $OUTDIR/out/jobs_running_T0AndGlobalPool >$WORKDIR/status/input_jobstier_running_global$int
#while read -r line; do
#        time=$(echo $line |awk '{print $1}')
#        let timemil=1000*$time
#        content=$(echo $line |awk '{print $2", "$4", "$5", "$6", "$7}')
#        echo "[new Date($timemil), $content], " >>$OUT
#done <$WORKDIR/status/input_jobstier_running_global$int
#stats_jobstier=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobstier_running_global$int)
#rm $WORKDIR/status/input_jobstier_running_global$int
#
#echo "      ]);
#var options_jobstier = {
#        title: 'Running jobs cores at T0+T1s+T2s for production and analysis',
#        isStacked: 'true',
#        explorer: {},
#        'height':500,
#        colors: ['#FACC2E', '#4060C7', '#6060C7', '#70D017', '#90D017'],
#        hAxis: {title: 'Time'},
#        vAxis: {title: 'Number of cores'}
#        };
#
#var chart_jobstier = new google.visualization.AreaChart(document.getElementById('chart_div_jobstier'));
#chart_jobstier.draw(data_jobstier, options_jobstier);">>$OUT

#----------
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
	<a href="'$WEBPATH'global_pool_size_24h.html">24h</a>
	<a href="'$WEBPATH'global_pool_size_168h.html">1week</a>
	<a href="'$WEBPATH'longglobal_pool_size_720h.html">1month</a>
	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_size)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_poolidle"></div><p>'$(echo "[avg, min, max]: " $stats_idle)'</p><br><br>'>>$OUT
#echo ' <div id="chart_div_pooleff"></div><br><br>'>>$OUT
#echo ' <div id="chart_div_jobs"></div><p>'$(echo "[avg, min, max]: " $stats_jobs)'</p><br><br>'>>$OUT
#echo ' <div id="chart_div_jobstier"></div><p>'$(echo "[avg, min, max]: " $stats_jobstier)'</p><br><br>'>>$OUT

echo "
</body>
</html>" >>$OUT
