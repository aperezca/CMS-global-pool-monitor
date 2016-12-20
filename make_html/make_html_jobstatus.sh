#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

OUT="/crabprod/CSstoragePath/aperez/HTML/"$long"jobstatus_"$int"h.html"
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
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobs_size >/home/aperez/status/input_jobs_size$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobs_size$int
stats_jobs=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobs_size$int)
rm /home/aperez/status/input_jobs_size$int

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
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobcores_size >/home/aperez/status/input_jobcores_size$int
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

#--------------------------
# Autoclusters in pool
echo "var data_clusters = new google.visualization.DataTable();
data_clusters.addColumn('datetime', 'Date');
data_clusters.addColumn('number', 'Autoclusters prod');
data_clusters.addColumn('number', 'Autoclusters crab');
data_clusters.addColumn('number', 'Autoclusters other');

data_clusters.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/autoclusters >/home/aperez/status/input_autoclusters$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_autoclusters$int
stats_clusters=$(python /home/aperez/get_averages.py /home/aperez/status/input_autoclusters$int)
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
# Autoclusters in queued jobs in pool
echo "var data_clusters_q = new google.visualization.DataTable();
data_clusters_q.addColumn('datetime', 'Date');
data_clusters_q.addColumn('number', 'Autoclusters prod');
data_clusters_q.addColumn('number', 'Autoclusters crab');

data_clusters_q.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/autoclusters_queued >/home/aperez/status/input_autoclusters_q$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_autoclusters_q$int
stats_clusters_q=$(python /home/aperez/get_averages.py /home/aperez/status/input_autoclusters_q$int)
rm /home/aperez/status/input_autoclusters_q$int

echo "      ]);
var options_clusters_q = {
        title: 'Global pool idle job autoclusters',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0000FF', '#0060FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of job clusters in pool schedds'}
        };

var chart_clusters_q = new google.visualization.AreaChart(document.getElementById('chart_div_clusters_q'));
chart_clusters_q.draw(data_clusters_q, options_clusters_q);">>$OUT

#---------------------
# Prod jobs in pool:
echo "var data_jobs_prod = new google.visualization.DataTable();
data_jobs_prod.addColumn('datetime', 'Date');
data_jobs_prod.addColumn('number', 'Running jobs');
data_jobs_prod.addColumn('number', 'Queued jobs');

data_jobs_prod.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobs_size_prod >/home/aperez/status/input_jobs_size_prod$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobs_size_prod$int
stats_jobs_prod=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobs_size_prod$int)
rm /home/aperez/status/input_jobs_size_prod$int

echo "      ]);
var options_jobs_prod = {
        title: 'Global pool production job numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of jobs'}
        };

var chart_jobs_prod = new google.visualization.AreaChart(document.getElementById('chart_div_jobs_prod'));
chart_jobs_prod.draw(data_jobs_prod, options_jobs_prod);">>$OUT

#----------
# Prod job coress in pool:
echo "var data_jobcores_prod = new google.visualization.DataTable();
data_jobcores_prod.addColumn('datetime', 'Date');
data_jobcores_prod.addColumn('number', 'Cores running jobs');
data_jobcores_prod.addColumn('number', 'Cores queued jobs');

data_jobcores_prod.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobcores_size_prod >/home/aperez/status/input_jobcores_size_prod$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobcores_size_prod$int
stats_jobcores_prod=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobcores_size_prod$int)
rm /home/aperez/status/input_jobcores_size_prod$int

echo "      ]);
var options_jobcores_prod = {
        title: 'Global pool cores in production job numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_jobcores_prod = new google.visualization.AreaChart(document.getElementById('chart_div_jobcores_prod'));
chart_jobcores_prod.draw(data_jobcores_prod, options_jobcores_prod);">>$OUT

#---------------

# Crab jobs in pool:
echo "var data_jobs_crab = new google.visualization.DataTable();
data_jobs_crab.addColumn('datetime', 'Date');
data_jobs_crab.addColumn('number', 'Running jobs');
data_jobs_crab.addColumn('number', 'Queued jobs');

data_jobs_crab.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobs_size_crab >/home/aperez/status/input_jobs_size_crab$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobs_size_crab$int
stats_jobs_crab=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobs_size_crab$int)
rm /home/aperez/status/input_jobs_size_crab$int

echo "      ]);
var options_jobs_crab = {
        title: 'Global pool analysis (crab3) job numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of jobs'}
        };

var chart_jobs_crab = new google.visualization.AreaChart(document.getElementById('chart_div_jobs_crab'));
chart_jobs_crab.draw(data_jobs_crab, options_jobs_crab);">>$OUT

#---------------

# Crab jobs cores in pool:
echo "var data_jobcores_crab = new google.visualization.DataTable();
data_jobcores_crab.addColumn('datetime', 'Date');
data_jobcores_crab.addColumn('number', 'Cores running jobs');
data_jobcores_crab.addColumn('number', 'Cores queued jobs');

data_jobcores_crab.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobcores_size_crab >/home/aperez/status/input_jobcores_size_crab$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobcores_size_crab$int
stats_jobcores_crab=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobcores_size_crab$int)
rm /home/aperez/status/input_jobcores_size_crab$int

echo "      ]);
var options_jobcores_crab = {
        title: 'Global pool cores in analysis (crab3) job numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_jobcores_crab = new google.visualization.AreaChart(document.getElementById('chart_div_jobcores_crab'));
chart_jobcores_crab.draw(data_jobcores_crab, options_jobcores_crab);">>$OUT


#---------------

# Other jobs in pool:
echo "var data_jobs_other = new google.visualization.DataTable();
data_jobs_other.addColumn('datetime', 'Date');
data_jobs_other.addColumn('number', 'Running jobs');
data_jobs_other.addColumn('number', 'Queued jobs');

data_jobs_other.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/jobs_size_other >/home/aperez/status/input_jobs_size_other$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3}')
        echo "[new Date($timemil), $content], " >>$OUT
done </home/aperez/status/input_jobs_size_other$int
stats_jobs_other=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobs_size_other$int)
rm /home/aperez/status/input_jobs_size_other$int

echo "      ]);
var options_jobs_other = {
        title: 'Global pool other (not prod or crab 3) job numbers',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF', '#FFBF00'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of jobs'}
        };

var chart_jobs_other = new google.visualization.AreaChart(document.getElementById('chart_div_jobs_other'));
chart_jobs_other.draw(data_jobs_other, options_jobs_other);">>$OUT

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
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/jobstatus_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/jobstatus_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longjobstatus_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

echo ' <div id="chart_div_jobs"></div><p>'$(echo "[avg, min, max]: " $stats_jobs)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobcores"></div><p>'$(echo "[avg, min, max]: " $stats_jobcores)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_clusters"></div><p>'$(echo "[avg, min, max]: " $stats_clusters)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_clusters_q"></div><p>'$(echo "[avg, min, max]: " $stats_clusters_q)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobs_prod"></div><p>'$(echo "[avg, min, max]: " $stats_jobs_prod)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobcores_prod"></div><p>'$(echo "[avg, min, max]: " $stats_jobcores_prod)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobs_crab"></div><p>'$(echo "[avg, min, max]: " $stats_jobs_crab)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobcores_crab"></div><p>'$(echo "[avg, min, max]: " $stats_jobcores_crab)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobs_other"></div><p>'$(echo "[avg, min, max]: " $stats_jobs_other)'</p><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
