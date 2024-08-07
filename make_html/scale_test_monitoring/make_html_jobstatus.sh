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

source /data/srv/aperezca/Monitoring/env_itb.sh
OUT=$HTMLDIR/$long"jobstatus_"$int"h.html"

echo '<html>
<head>
<title>CMS global pool job status monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

#--------------------------
# All jobs in pool:
echo "var data_jobs = new google.visualization.DataTable();
data_jobs.addColumn('datetime', 'Date');
data_jobs.addColumn('number', 'Running jobs');
data_jobs.addColumn('number', 'Queued jobs');

data_jobs.addRows([">>$OUT
tail -n $n_lines $OUTDIR/jobs_size|awk -v var="$ratio" 'NR % var == 0' |awk '{print $1, $2, $3}' |sort >$WORKDIR/status/input_jobs_size$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_jobs_size$int
stats_jobs=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobs_size$int)
rm $WORKDIR/status/input_jobs_size$int

echo "      ]);
var options_jobs = {
        title: 'Global pool total job numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
	colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of jobs'}
        };

var chart_jobs = new google.visualization.AreaChart(document.getElementById('chart_div_jobs'));
chart_jobs.draw(data_jobs, options_jobs);">>$OUT

#--------------------------
# Jobs x cores in pool
echo "var data_jobcores = new google.visualization.DataTable();
data_jobcores.addColumn('datetime', 'Date');
data_jobcores.addColumn('number', 'Cores running jobs');
data_jobcores.addColumn('number', 'Cores queued jobs');

data_jobcores.addRows([">>$OUT
tail -n $n_lines $OUTDIR/jobcores_size|awk -v var="$ratio" 'NR % var == 0' |sort >$WORKDIR/status/input_jobcores_size$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_jobcores_size$int
stats_jobcores=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobcores_size$int)
rm $WORKDIR/status/input_jobcores_size$int

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

#--------------------------
# Autoclusters in pool
echo "var data_clusters = new google.visualization.DataTable();
data_clusters.addColumn('datetime', 'Date');
data_clusters.addColumn('number', 'Autoclusters prod');
data_clusters.addColumn('number', 'Autoclusters crab');
data_clusters.addColumn('number', 'Autoclusters tier0');
data_clusters.addColumn('number', 'Autoclusters other');

data_clusters.addRows([">>$OUT
tail -n $n_lines $OUTDIR/autoclusters|awk -v var="$ratio" 'NR % var == 0' |sort >$WORKDIR/status/input_autoclusters$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	if [[ $(echo $line |awk '{print $5}') != "" ]]; then
        	content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
	else
		content=$(echo $line |awk '{print $2", "$3", 0, "$4}')
	fi
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_autoclusters$int
stats_clusters=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_autoclusters$int)
rm $WORKDIR/status/input_autoclusters$int

echo "      ]);
var options_clusters = {
        title: 'Global pool job autoclusters',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0000FF', '#0060FF', '#6000FF', '#6060FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of job clusters in pool schedds'}
        };

var chart_clusters = new google.visualization.AreaChart(document.getElementById('chart_div_clusters'));
chart_clusters.draw(data_clusters, options_clusters);">>$OUT

#----------
# Autoclusters in queued jobs in pool
echo "var data_clusters_q = new google.visualization.DataTable();
data_clusters_q.addColumn('datetime', 'Date');
data_clusters_q.addColumn('number', 'Autoclusters prod');
data_clusters_q.addColumn('number', 'Autoclusters crab');
data_clusters_q.addColumn('number', 'Autoclusters tier0');
data_clusters_q.addRows([">>$OUT
tail -n $n_lines $OUTDIR/autoclusters_queued|awk -v var="$ratio" 'NR % var == 0'|sort >$WORKDIR/status/input_autoclusters_q$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	if [[ $(echo $line |awk '{print $4}') != "" ]]; then
        	content=$(echo $line |awk '{print $2", "$3", "$4}')
	else
		content=$(echo $line |awk '{print $2", "$3", 0"}')
	fi
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_autoclusters_q$int
stats_clusters_q=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_autoclusters_q$int)
rm $WORKDIR/status/input_autoclusters_q$int

echo "      ]);
var options_clusters_q = {
        title: 'Global pool idle job autoclusters',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0000FF', '#0060FF', '#6000FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of job clusters in pool schedds'}
        };

var chart_clusters_q = new google.visualization.AreaChart(document.getElementById('chart_div_clusters_q'));
chart_clusters_q.draw(data_clusters_q, options_clusters_q);">>$OUT

#---------------------
#---------------

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
        <h2>CMS GLOBAL POOL JOB STATUS MONITOR: jobs in the global pool for the last '$int' hours, updated at '$(date -u)'<br>
	</h2><br>
    </div>
<a href="'$WEBPATH'jobstatus_24h.html">24h</a>
<a href="'$WEBPATH'jobstatus_168h.html">1week</a>
<a href="'$WEBPATH'longjobstatus_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

#echo $stats_jobs
#echo $stats_jobcores
echo ' <div id="chart_div_jobs"></div><p>'$(echo "[avg, min, max]: " $stats_jobs)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobcores"></div><p>'$(echo "[avg, min, max]: " $stats_jobcores)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_clusters"></div><p>'$(echo "[avg, min, max]: " $stats_clusters)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_clusters_q"></div><p>'$(echo "[avg, min, max]: " $stats_clusters_q)'</p><br><br>'>>$OUT

echo "
</body>
</html>" >>$OUT
