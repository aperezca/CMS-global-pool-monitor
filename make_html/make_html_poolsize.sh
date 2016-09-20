#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

OUT="/crabprod/CSstoragePath/aperez/HTML/"$long"global_pool_size_"$int"h.html"
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
tail -n $n_lines /home/aperez/out/pool_size >/home/aperez/status/input_pool_size$int
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
#Pool busy and idle cores:
echo "var data_poolidle = new google.visualization.DataTable();     
data_poolidle.addColumn('datetime', 'Date');
data_poolidle.addColumn('number', 'mcore busy'); 
data_poolidle.addColumn('number', 'score busy');
data_poolidle.addColumn('number', 'mcore idle');
data_poolidle.addColumn('number', 'score idle');

data_poolidle.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/pool_idle >/home/aperez/status/input_pool_idle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$4", "$3", "$5}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_pool_idle$int
stats_idle=$(python /home/aperez/get_averages.py /home/aperez/status/input_pool_idle$int)
rm /home/aperez/status/input_pool_idle$int

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
#Idle cores in mcore pilots:
echo "var data_mcoreidle = new google.visualization.DataTable();
data_mcoreidle.addColumn('datetime', 'Date');
data_mcoreidle.addColumn('number', 'mcore retire');
data_mcoreidle.addColumn('number', 'mcore memory');
data_mcoreidle.addColumn('number', 'mcore usable');

data_mcoreidle.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/pool_mcoreidle >/home/aperez/status/input_pool_mcoreidle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_pool_mcoreidle$int
stats_mcoreidle=$(python /home/aperez/get_averages.py /home/aperez/status/input_pool_mcoreidle$int)
rm /home/aperez/status/input_pool_mcoreidle$int

echo "      ]);
var options_mcoreidle = {
        title: 'Global pool idle cores in multicore pilots: past retire time, not enough memory, usable',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#FF4000', '#FF8000', '#FF0000'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_mcoreidle = new google.visualization.AreaChart(document.getElementById('chart_div_mcoreidle'));
chart_mcoreidle.draw(data_mcoreidle, options_mcoreidle);">>$OUT

#---------------------------
#FrontEnd pressure on the pool (new requested idle):
echo "var data_FE = new google.visualization.DataTable();     
data_FE.addColumn('datetime', 'Date');
data_FE.addColumn('number', 'T1_t1prod');
data_FE.addColumn('number', 'T1_main');
data_FE.addColumn('number', 'T2_main_mcore');
data_FE.addColumn('number', 'T2_main_score');
data_FE.addColumn('number', 'T3_main_score');

data_FE.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/frontend_full >/home/aperez/status/input_FE_full$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	if [[ $(echo $line |awk '{print $2}') != "" ]] && [[ $(echo $line |awk '{print $3}') != "" ]]; then
        	content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6}')
	else
		content="0, 0, 0, 0, 0"
	fi
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_FE_full$int
stats_FE=$(python /home/aperez/get_averages.py /home/aperez/status/input_FE_full$int)
rm /home/aperez/status/input_FE_full$int

echo "      ]);
var options_FE = {
        title: 'Global pool FE pressure in N_requested_idle_glideins X N_cores per FE group and site',
        isStacked: 'true',
        explorer: {},
        'height':500,
	colors: ['#0000A0', '#6060A0', '#1569C7', '#52D017', '#B2C248'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_FE = new google.visualization.AreaChart(document.getElementById('chart_div_FE'));
chart_FE.draw(data_FE, options_FE);">>$OUT

#---------------------------
# Running jobs in pool by type:
echo "var data_jobs = new google.visualization.DataTable();
data_jobs.addColumn('datetime', 'Date');
data_jobs.addColumn('number', 'Prod jobs');
data_jobs.addColumn('number', 'Analysis jobs');

data_jobs.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/jobs_running_global >/home/aperez/status/input_jobs_running_global$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobs_running_global$int
stats_jobs=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobs_running_global$int)
rm /home/aperez/status/input_jobs_running_global$int

echo "      ]);
var options_jobs = {
        title: 'Global pool running job cores',
        isStacked: 'true',
        explorer: {},
        'height':500,
	colors: ['#1569C7', '#52D017'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_jobs = new google.visualization.AreaChart(document.getElementById('chart_div_jobs'));
chart_jobs.draw(data_jobs, options_jobs);">>$OUT

#-----------------------------
# Jobs x cores in pool
echo "var data_jobcores = new google.visualization.DataTable();
data_jobcores.addColumn('datetime', 'Date');
data_jobcores.addColumn('number', 'Cores runing jobs');
data_jobcores.addColumn('number', 'Cores idle jobs');

data_jobcores.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/jobcores_size >/home/aperez/status/input_jobcores_size$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobcores_size$int
stats_jobcores=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobcores_size$int)
rm /home/aperez/status/input_jobcores_size$int

echo "      ]);
var options_jobcores = {
        title: 'Global pool total job x cores numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_jobcores = new google.visualization.AreaChart(document.getElementById('chart_div_jobcores'));
chart_jobcores.draw(data_jobcores, options_jobcores);">>$OUT

#-------------------------------
# Autoclusters in pool
echo "var data_clusters = new google.visualization.DataTable();
data_clusters.addColumn('datetime', 'Date');
data_clusters.addColumn('number', 'Autoclusters prod');
data_clusters.addColumn('number', 'Autoclusters crab');
data_clusters.addColumn('number', 'Autoclusters other');

data_clusters.addRows([">>$OUT
tail -n $n_lines /home/aperez/out/autoclusters >/home/aperez/status/input_autoclusters$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_autoclusters$int
stats_autoclusters=$(python /home/aperez/get_averages.py /home/aperez/status/input_autoclusters$int)
rm /home/aperez/status/input_autoclusters$int

echo "      ]);
var options_clusters = {
        title: 'Global pool job autoclusters',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0000FF', '#0060FF', '#6000FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of job clusters in pool schedds'}
        };

var chart_clusters = new google.visualization.AreaChart(document.getElementById('chart_div_clusters'));
chart_clusters.draw(data_clusters, options_clusters);">>$OUT

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
        <h2>CMS GLOBAL POOL MONITOR: Global pool size and components for the last '$int' hours<br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_size_24h.html">24h</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_size_168h.html">1week</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_size_720h.html">1month</a>
	<br><br>
        
	See also:
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/jobstatus_'$int'h.html" target="blank">jobs in the global pool</a>

	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/Monitor/latest-new.txt" target="blank">summary tables for the global pool</a>, 
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/globalpool_jobs_info.txt" target="blank">full list of jobs in pool</a>, 
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/globalpool_running_jobs.txt" target="blank">with site info</a> and 
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/globalpool_pilot_info.txt" target="blank">pilots</a>

        <br><a href="http://hcc-ganglia.unl.edu/graph_all_periods.php?c=crab-infrastructure&h=vocms032.cern.ch&r=hour&z=small&jr=&js=&st=1461321500&event=hide&ts=0&v=239&m=LastNegotiationCycleDuration0&vl=seconds&z=large" target="blank">negotiation time</a> and 
	<a href="http://hcc-ganglia.unl.edu/graph_all_periods.php?c=crab-infrastructure&h=vocms032.cern.ch&r=hour&z=small&jr=&js=&st=1461321500&event=hide&ts=0&v=8806&m=AutoClusters%20in%20Pool&vl=autoclusters&z=large" target="blank">autoclusters</a>

	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/multicore_usage_t1s_24h.html" target="blank">T1 mcore pilots</a> and
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobstatus_T1_24h.html" target="blank"> jobs</a>

	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/T2s/multicore_usage_t2s_24h.html" target="blank">T2 mcore pilots</a> and
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobstatus_T2_24h.html" target="blank"> jobs</a>

	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_size)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_poolidle"></div><p>'$(echo "[avg, min, max]: " $stats_idle)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_mcoreidle"></div><p>'$(echo "[avg, min, max]: " $stats_mcoreidle)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_FE"></div><p>'$(echo "[avg, min, max]: " $stats_FE)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobs"></div><p>'$(echo "[avg, min, max]: " $stats_jobs)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobcores"></div><p>'$(echo "[avg, min, max]: " $stats_jobcores)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_clusters"></div><p>'$(echo "[avg, min, max]: " $stats_autoclusters)'</p><br><br>'>>$OUT

echo "
</body>
</html>" >>$OUT
