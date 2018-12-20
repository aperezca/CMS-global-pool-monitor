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

OUT="$OUTDIR/HTML/JobInfo/"$long"jobs_resizable_"$int"h.html"
echo '<html>
<head>
<title>CMS global pool monitor on resizable jobs</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

#----------------------
#Resizable 1 to 4 cores:
for i in jobs jobcores; do
	echo "var data_$i = new google.visualization.DataTable();	
	data_$i.addColumn('datetime', 'Date');
	data_$i.addColumn('number', '${i}_1');
	data_$i.addColumn('number', '${i}_2');
	data_$i.addColumn('number', '${i}_3');
	data_$i.addColumn('number', '${i}_4');
        data_$i.addColumn('number', '${i}_5');
        data_$i.addColumn('number', '${i}_6');
        data_$i.addColumn('number', '${i}_7');
        data_$i.addColumn('number', '${i}_8');
        data_$i.addColumn('number', '${i}_9');
        data_$i.addColumn('number', '${i}_10');

	data_$i.addRows([">>$OUT
	tail -n $n_lines $OUTDIR/out/resizable_3_10_$i >$WORKDIR/status/input_resizable_${i}_$int
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time
		content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10", "$11}')
		echo "[new Date($timemil), $content], " >>$OUT
	done <$WORKDIR/status/input_resizable_${i}_$int
	stats=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_resizable_${i}_$int)
	declare "stats_$i=$(echo $stats)"
	rm $WORKDIR/status/input_resizable_${i}_$int

	echo "      ]);
	var options_$i = {
		isStacked: 'true',
		explorer: {},
		'height':500,
		hAxis: {title: 'Time'},
                colors: ['#FF0000', '#FF8000', '#FFBF00', '#FFFF00', '#80FF00', '#00FF00', '#00BFFF', '#0000FF', '#FF0000', '#FF8000'],">>$OUT
		if [[ $i == 'jobs' ]]; then echo " 
		title: 'Number of jobs as a function of cores for resizable jobs',
		vAxis: {title: 'Number of jobs'}">>$OUT
		fi
		if [[ $i == 'jobcores' ]]; then echo "
                title: 'Number of cores used by resizable jobs',
                vAxis: {title: 'Number of cores'}">>$OUT
                fi
	echo "	};

	var chart_$i = new google.visualization.AreaChart(document.getElementById('chart_div_$i'));
	chart_$i.draw(data_$i, options_$i);">>$OUT
done
#----------------------

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
        <h2>CMS Global pool running resizable jobs by core size for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobs_resizable_24h.html">24h</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobs_resizable_168h.html">1week</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/longjobs_resizable_720h.html">1month</a>

	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
for i in jobs jobcores; do
	var="stats_$i"
	echo ' <div id="chart_div_'$i'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT
echo "
</body>
</html>" >>$OUT

