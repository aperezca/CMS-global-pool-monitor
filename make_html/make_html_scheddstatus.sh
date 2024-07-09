# Print status for each of the schedds
#Interval to plot in hours
schedd=$1
int=$2

let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long_"
else
	long=""
fi

ratio=1
if [[ $int -gt "720" ]]; then ratio=2; fi # more than 1 month
if [[ $int -gt "1440" ]]; then ratio=3; fi # more than 2 months
if [[ $int -gt "2880" ]]; then ratio=4; fi # more than 4 months
if [[ $int -gt "4320" ]]; then ratio=6; fi # more than 6 months

source /data/srv/aperezca/Monitoring/env.sh
OUT=$HTMLDIR"/Schedds/"$long$schedd"_status_"$int"h.html"
echo '<html>
<head>
<title>Schedd status monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

#--------------------------
# jobs in schedd:
echo "var data_jobs = new google.visualization.DataTable();
data_jobs.addColumn('datetime', 'Date');
data_jobs.addColumn('number', 'Running jobs');
data_jobs.addColumn('number', 'Queued jobs');

data_jobs.addRows([">>$OUT
tail -n $n_lines $OUTDIR/jobs_$schedd|awk -v var="$ratio" 'NR % var == 0' |sort >$WORKDIR/status/input_jobs_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_jobs_$schedd$int
stats_jobs=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobs_$schedd$int)
rm $WORKDIR/status/input_jobs_$schedd$int

echo "      ]);
var options_jobs = {
        title: '$schedd total job numbers',
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
# job rates in schedd:
echo "var data_jobrate = new google.visualization.DataTable();
data_jobrate.addColumn('datetime', 'Date');
data_jobrate.addColumn('number', 'JobsStarted');
data_jobrate.addColumn('number', 'JobsCompleted');
data_jobrate.addColumn('number', 'JobsSubmitted');

data_jobrate.addRows([">>$OUT
tail -n $n_lines $OUTDIR/recentjobs_$schedd|awk -v var="$ratio" 'NR % var == 0' |sort >$WORKDIR/status/recentjobs_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/recentjobs_$schedd$int
stats_jobrate=$(python $WORKDIR/get_averages.py $WORKDIR/status/recentjobs_$schedd$int)
rm $WORKDIR/status/recentjobs_$schedd$int

echo "      ]);
var options_jobrate = {
        title: '$schedd job rates ',
        isStacked: 'false',
        explorer: {},
        'height':500,
	lineWidth: 6,
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of jobs'}
        };

var chart_jobrate = new google.visualization.LineChart(document.getElementById('chart_div_jobrate'));
chart_jobrate.draw(data_jobrate, options_jobrate);">>$OUT

#--------------------------

# Jobs x cores in schedd
echo "var data_jobcores = new google.visualization.DataTable();
data_jobcores.addColumn('datetime', 'Date');
data_jobcores.addColumn('number', 'Cores running jobs');
data_jobcores.addColumn('number', 'Cores queued jobs');

data_jobcores.addRows([">>$OUT
tail -n $n_lines $OUTDIR/jobscores_$schedd|awk -v var="$ratio" 'NR % var == 0' |sort >$WORKDIR/status/input_jobscores_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_jobscores_$schedd$int
stats_jobcores=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobscores_$schedd$int)
rm $WORKDIR/status/input_jobscores_$schedd$int

echo "      ]);
var options_jobcores = {
        title: '$schedd total job x cores numbers',
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
# Autoclusters in schedd
echo "var data_clusters = new google.visualization.DataTable();
data_clusters.addColumn('datetime', 'Date');
data_clusters.addColumn('number', 'Autoclusters');

data_clusters.addRows([">>$OUT
tail -n $n_lines $OUTDIR/autoclusters_$schedd|awk -v var="$ratio" 'NR % var == 0' >$WORKDIR/status/input_clusters_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_clusters_$schedd$int
stats_clusters=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_clusters_$schedd$int)
rm $WORKDIR/status/input_clusters_$schedd$int

echo "      ]);
var options_clusters = {
        title: '$schedd number of autoclusters',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of autoclusters'}
        };

var chart_clusters = new google.visualization.AreaChart(document.getElementById('chart_div_clusters'));
chart_clusters.draw(data_clusters, options_clusters);">>$OUT

#----------------------
# CoreDutyCycle in schedd
echo "var data_dutycycle = new google.visualization.DataTable();
data_dutycycle.addColumn('datetime', 'Date');
data_dutycycle.addColumn('number', 'RecentCoreDutyCycle');

data_dutycycle.addRows([">>$OUT
tail -n $n_lines $OUTDIR/dutycycle_$schedd|awk -v var="$ratio" 'NR % var == 0' >$WORKDIR/status/input_dutycycle_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_dutycycle_$schedd$int
stats_dutycycle=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_dutycycle_$schedd$int)
rm $WORKDIR/status/input_dutycycle_$schedd$int

echo "      ]);
var options_dutycycle = {
        title: '$schedd RecentCoreDutyCycle',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'dutycycle'}
        };

var chart_dutycycle = new google.visualization.AreaChart(document.getElementById('chart_div_dutycycle'));
chart_dutycycle.draw(data_dutycycle, options_dutycycle);">>$OUT

#----------------------
# RecentResourceRequestsSent in schedd
echo "var data_resrequest = new google.visualization.DataTable();
data_resrequest.addColumn('datetime', 'Date');
data_resrequest.addColumn('number', 'RecentResRequestsSent');

data_resrequest.addRows([">>$OUT
tail -n $n_lines $OUTDIR/resrequest_$schedd|awk -v var="$ratio" 'NR % var == 0' >$WORKDIR/status/input_resrequest_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_resrequest_$schedd$int
stats_resrequest=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_resrequest_$schedd$int)
rm $WORKDIR/status/input_resrequest_$schedd$int

echo "      ]);
var options_resrequest = {
        title: '$schedd RecentResRequestsSent',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'resrequest'}
        };

var chart_resrequest = new google.visualization.AreaChart(document.getElementById('chart_div_resrequest'));
chart_resrequest.draw(data_resrequest, options_resrequest);">>$OUT

#----------------------
# NumOwners in schedd
echo "var data_owners = new google.visualization.DataTable();
data_owners.addColumn('datetime', 'Date');
data_owners.addColumn('number', 'NumOwners');

data_owners.addRows([">>$OUT
tail -n $n_lines $OUTDIR/owners_$schedd|awk -v var="$ratio" 'NR % var == 0' >$WORKDIR/status/input_owners_$schedd$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_owners_$schedd$int
stats_owners=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_owners_$schedd$int)
rm $WORKDIR/status/input_owners_$schedd$int

echo "      ]);
var options_owners = {
        title: '$schedd NumOwners',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'owners'}
        };

var chart_owners = new google.visualization.AreaChart(document.getElementById('chart_div_owners'));
chart_owners.draw(data_owners, options_owners);">>$OUT
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
        <h2>'$schedd' STATUS MONITOR for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="'$WEBPATH'Schedds/'$schedd'_status_24h.html">24h</a>
	<a href="'$WEBPATH'Schedds/'$schedd'_status_168h.html">1week</a>
	</h2><br>
    </div>
<br>
 <!--Div to hold the charts-->'>>$OUT

echo ' <div id="chart_div_jobs"></div><p>'$(echo "[avg, min, max]: " $stats_jobs)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobrate"></div><p>'$(echo "[avg, min, max]: " $stats_jobrate)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobcores"></div><p>'$(echo "[avg, min, max]: " $stats_jobcores)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_clusters"></div><p>'$(echo "[avg, min, max]: " $stats_clusters)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_dutycycle"></div><p>'$(echo "[avg, min, max]: " $stats_dutycycle)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_resrequest"></div><p>'$(echo "[avg, min, max]: " $stats_resrequest)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_owners"></div><p>'$(echo "[avg, min, max]: " $stats_owners)'</p><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
