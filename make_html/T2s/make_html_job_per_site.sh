#Interval to plot in mm/dd/yyyy format
mysite=$1
start=$2
end=$3

start_t=$(date -d $start -u +%s)
end_t=$(date -d $end -u +%s)

source /data/srv/aperezca/Monitoring/env.sh
OUT=$HTMLDIR"/T2s/jobstatus_"$mysite"_"$(echo $start |awk -F"/" '{print $1 $2 $3}')"_"$(echo $end |awk -F"/" '{print $1 $2 $3}')".html"

#-------------------
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
	data_$site.addColumn('number', 'tier0');
	data_$site.addRows([">>$OUT
	rm $WORKDIR/status/input_jobsonly_$site
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		if [[ $time -gt $start_t ]] && [[ $time -lt $end_t ]]; then
			let timemil=1000*$time
			if [[ $(echo $line |wc -w) -eq 4 ]]; then
                        	content=$(echo $line |awk '{print $2", "$3", "$4}')
                	else
                        	content=$(echo $line |awk '{print $2", "$3", 0"}')
                	fi
			echo $time $content >> $WORKDIR/status/input_jobsonly_$site
			echo "[new Date($timemil), $content], " >>$OUT
		fi
	done <$OUTDIR/jobs_running_$site
	declare "stats_$site=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobsonly_$site)"
	rm $WORKDIR/status/input_jobsonly_$site

	echo "      ]);
        var options_$site = {
                title: '$site',
                isStacked: 'true',
        	explorer: {},
                'height':500,
		colors: ['#1569C7', '#52D017', '#ff8553'],
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
<a href="'$WEBPATH'JobInfo/jobstatus_'$list'_24h.html">24h</a>
<a href="'$WEBPATH'JobInfo/jobstatus_'$list'_168h.html">1week</a>
<a href="'$WEBPATH'JobInfo/longjobstatus_'$list'_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in $(echo $mysite); do
	var="stats_$site"
        echo ' <div id="chart_div_'$site'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT

echo "
</body>
</html>" >>$OUT

