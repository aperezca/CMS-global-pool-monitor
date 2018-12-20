#Interval to plot in mm/dd/yyyy format
mysite=$1
start=$2
end=$3

start_t=$(date -d $start -u +%s)
end_t=$(date -d $end -u +%s)

OUT="/crabprod/CSstoragePath/aperez/HTML/T2s/jobstatus_"$mysite"_"$(echo $start |awk -F"/" '{print $1 $2 $3}')"_"$(echo $end |awk -F"/" '{print $1 $2 $3}')".html"
echo '<html>
<head>
<title>CMS global pool running jobs per site monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for site in $(echo $mysite); do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
      	data_$site.addColumn('number', 'production'); 
	data_$site.addColumn('number', 'analysis');
	data_$site.addRows([">>$OUT
	rm /home/aperez/status/input_jobs_$site
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		if [[ $time -gt $start_t ]] && [[ $time -lt $end_t ]]; then
			echo $line>> /home/aperez/status/input_jobs_$site
			let timemil=1000*$time
			content=$(echo $line |awk '{print $2", "$3}')
			echo "[new Date($timemil), $content], " >>$OUT
		fi
	done </crabprod/CSstoragePath/aperez/out/jobs_running_$site
	declare "stats_$site=$(python /home/aperez/get_averages.py /home/aperez/status/input_jobs_$site)"
	rm /home/aperez/status/input_jobs_$site

	echo "      ]);

        var options_$site = {
                title: '$site',
                isStacked: 'true',
        	explorer: {},
                'height':500,
		colors: ['#1569C7', '#52D017'],
                hAxis: {title: 'Time'},
                vAxis: {title: 'Number of cores in running jobs'}
        };

      	var chart_$site = new google.visualization.AreaChart(document.getElementById('chart_div_$site'));
      	chart_$site.draw(data_$site, options_$site);">>$OUT
done

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
        <h2>GLOBAL POOL RUNNING JOBS AT CMS '$mysite' from '$start' until '$end', updated at '$(date -u)'<br>
	</h2>
    </div>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobstatus_'$list'_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobstatus_'$list'_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/longjobstatus_'$list'_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in $(echo $mysite); do
	var="stats_$site"
        echo ' <div id="chart_div_'$site'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT
