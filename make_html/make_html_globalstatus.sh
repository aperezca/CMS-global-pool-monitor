now=$(date -u)
OUT="/crabprod/CSstoragePath/aperez/HTML/status_mcore_global.html"
echo '<html>
<head>
<title>CMS multicore pilot status for global pool</title>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT
echo "	google.load('visualization', '1', {packages: ['corechart']});
	google.setOnLoadCallback(drawChart);
	function drawChart() {">>$OUT
#-------------
# SITE
#echo "var data_site = google.visualization.arrayToDataTable([
#        ['number', 'site'],">>$OUT
#j=1
#while read -r line; do
#        ivalue=$(echo $line |awk '{print $1}')
#        echo "  ['$j', $ivalue], " >>$OUT
#        let j+=1
#done</home/aperez/status/partglideins_now_global
#echo "]);
#var options_site = {
#        title: 'Pilot running at site',
#        legend: { position: 'none' },
#        colors: ['blue'],
#        histogram: { hideBucketItems: 'True', bucketSize: 1 }
#  };
#var chart_site = new google.visualization.Histogram(document.getElementById('chart_div_site'));
#chart_site.draw(data_site, options_site);">>$OUT

#-------------
# Age:
echo "var data_age = google.visualization.arrayToDataTable([
	['number', 'age'],">>$OUT
j=1
while read -r line; do
	ivalue=$(echo $line |awk '{print int($2/3600)}')
	echo "  ['$j', $ivalue], " >>$OUT
	#echo "	[$ivalue], " >>$OUT
	let j+=1	
done</home/aperez/status/partglideins_now_global
echo "]);
var options_age = {
	title: 'Pilot age (h)',
	legend: { position: 'none' },
	colors: ['blue'],
	histogram: { hideBucketItems: 'True', 
		     minValue: 0,
      		     maxValue: 80,
		     bucketSize: 2 
	}
  };
var chart_age = new google.visualization.Histogram(document.getElementById('chart_div_age'));
chart_age.draw(data_age, options_age);">>$OUT

#-------------
# Time to retire:
echo "var data_retire = google.visualization.arrayToDataTable([
        ['number', 'time_to_retire'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($3/3600)}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_global
echo "]);
var options_retire = {
        title: 'Pilot time to retire (h)',
        legend: { position: 'none' },
        colors: ['blue'],
        histogram: { hideBucketItems: 'True', 
		     bucketSize: 2. 
	}
  };
var chart_retire = new google.visualization.Histogram(document.getElementById('chart_div_retire'));
chart_retire.draw(data_retire, options_retire);">>$OUT

#-------------
# Free CPUs:

echo "var data_cpus = google.visualization.arrayToDataTable([
        ['number', 'cpus'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print $4}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_global
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
# Free Memory:
echo "var data_mem = google.visualization.arrayToDataTable([
        ['number', 'mem'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($5/1000)}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_global
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
# Free Disk:
echo "var data_disk = google.visualization.arrayToDataTable([
        ['number', 'disk'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($6/1000000)}')
        echo "  ['$j', $ivalue], " >>$OUT
	let j+=1
done</home/aperez/status/partglideins_now_global
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
# Executed Jobs:

echo "var data_jobs = google.visualization.arrayToDataTable([
        ['number', 'jobs'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($7)}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/partglideins_now_global
echo "]);
var options_jobs = {
        title: 'Number of jobs executed by the pilot',
        legend: { position: 'none' },
        colors: ['blue'],
        histogram: { hideBucketItems: 'True', bucketSize: 20 }
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
        <h2>MULTICORE PILOT current status for CMS global pool at '$now'<br>
	See also <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/Monitor/latest-new.txt" target="blank">summary tables for the global pool</a><br> 
	<a href="http://hcc-ganglia.unl.edu/graph_all_periods.php?c=crab-infrastructure&h=vocms032.cern.ch&r=hour&z=small&jr=&js=&st=1461321500&event=hide&ts=0&v=239&m=LastNegotiationCycleDuration0&vl=seconds&z=large" target="blank">negotiation time</a>
	<a href="http://hcc-ganglia.unl.edu/graph_all_periods.php?c=crab-infrastructure&h=vocms032.cern.ch&r=hour&z=small&jr=&js=&st=1461321500&event=hide&ts=0&v=8806&m=AutoClusters%20in%20Pool&vl=autoclusters&z=large" target="blank">autoclusters</a>
	<br></h2>
    </div>
 <!--Div to hold the charts-->'>>$OUT
#echo ' <div id="chart_div_site" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_age" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_retire" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_cpus" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_mem" style="width: 1400px; height: 600px;"></div><br>'>>$OUT
echo ' <div id="chart_div_disk" style="width: 1400px; height: 600px;"></div>'>>$OUT
echo ' <div id="chart_div_jobs" style="width: 1400px; height: 600px;"></div>'>>$OUT
echo "
</body>
</html>" >>$OUT
