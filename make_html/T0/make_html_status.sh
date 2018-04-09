site=$1
now=$(date -u)
OUT="/crabprod/CSstoragePath/aperez/HTML/T0/status_mcore_"$site".html"
echo '<html>
<head>
<title>CMS multicore pilot status</title>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT
echo "	google.load('visualization', '1', {packages: ['corechart']});
	google.setOnLoadCallback(drawChart);
	function drawChart() {">>$OUT
#-------------
echo "var data_age = google.visualization.arrayToDataTable([
	['number', 'age'],">>$OUT
j=1
while read -r line; do
	ivalue=$(echo $line |awk '{print int($1/3600)}')
	echo "	['$j', $ivalue], " >>$OUT
	let j+=1	
done</home/aperez/status/partglideins_now_$site
let index+=1
echo "]);
var options_age = {
	title: 'Pilot age (h)',
	legend: { position: 'none' },
	colors: ['blue'],
	histogram: { hideBucketItems: 'True', bucketSize: 1 }
  };
var chart_age = new google.visualization.Histogram(document.getElementById('chart_div_age'));
chart_age.draw(data_age, options_age);">>$OUT
#-------------
echo "var data_cpus = google.visualization.arrayToDataTable([
        ['number', 'cpus'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print $2}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_$site
let index+=1
echo "]);
var options_cpus = {
        title: 'Pilot unused CPU cores',
        legend: { position: 'none' },
        colors: ['green'],
        histogram: { hideBucketItems: 'True', bucketSize: 1 }
  };
var chart_cpus = new google.visualization.Histogram(document.getElementById('chart_div_cpus'));
chart_cpus.draw(data_cpus, options_cpus);">>$OUT
#-------------
echo "var data_mem = google.visualization.arrayToDataTable([
        ['number', 'mem'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($3/1000)}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_$site
let index+=1
echo "]);
var options_mem = {
        title: 'Pilot remaining unused memory (GB)',
        legend: { position: 'none' },
        colors: ['red'],
        histogram: { hideBucketItems: 'True', bucketSize: 1 }
  };
var chart_mem = new google.visualization.Histogram(document.getElementById('chart_div_mem'));
chart_mem.draw(data_mem, options_mem);">>$OUT
#-------------
echo "var data_disk = google.visualization.arrayToDataTable([
        ['number', 'disk'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($4/1000000)}')
        echo "  ['$j', $ivalue], " >>$OUT
	let j+=1
done</home/aperez/status/partglideins_now_$site
let index+=1
echo "]);
var options_disk = {
        title: 'Pilot remaining unused disk (GB)',
        legend: { position: 'none' },
        colors: ['yellow'],
        histogram: { hideBucketItems: 'True', bucketSize: 1 }
  };
var chart_disk = new google.visualization.Histogram(document.getElementById('chart_div_disk'));
chart_disk.draw(data_disk, options_disk);">>$OUT
#--------------------------
echo "var data_jobs = google.visualization.arrayToDataTable([
        ['number', 'jobs'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($5)}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_$site
let index+=1
echo "]);
var options_jobs = {
        title: 'Number of jobs executed by the pilot',
        legend: { position: 'none' },
        colors: ['blue'],
        histogram: { hideBucketItems: 'True', bucketSize: 1 }
  };
var chart_jobs = new google.visualization.Histogram(document.getElementById('chart_div_jobs'));
chart_jobs.draw(data_jobs, options_jobs);">>$OUT
#--------------------------
echo '
    }
    </script>
</head>

<body>
    <div id="header">
        <h2>MULTICORE PILOT current status for '$site' at '$now'</h2><br>
    </div>
 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_age" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_cpus" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_mem" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_disk" style="width: 1400px; height: 600px;"></div>'>>$OUT
echo ' <div id="chart_div_jobs" style="width: 1400px; height: 600px;"></div>'>>$OUT
echo "
</body>
</html>" >>$OUT
