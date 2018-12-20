#Interval to plot in mm/dd/yyyy format
mysite=$1
start=$2
end=$3

start_t=$(date -d $start -u +%s)
end_t=$(date -d $end -u +%s)

OUT="/crabprod/CSstoragePath/aperez/HTML/T2s/multicore_usage_allocated_"$mysite"_"$(echo $start |awk -F"/" '{print $1 $2 $3}')"_"$(echo $end |awk -F"/" '{print $1 $2 $3}')".html"
echo '<html>
<head>
<title>CMS multicore pilots core usage monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

echo $start $end

for site in $(echo $mysite); do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
      	data_$site.addColumn('number', 'CPU cores'); 
	data_$site.addRows([">>$OUT
	rm /home/aperez/status/input_file_use_$site
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		if [[ $time -gt $start_t ]] && [[ $time -lt $end_t ]]; then
			echo $line>> /home/aperez/status/input_file_use_$site
			let timemil=1000*$time
			content=$(echo $line |awk '{print $5+$6}')
			echo "[new Date($timemil), $content], " >>$OUT
		fi
	done </crabprod/CSstoragePath/aperez/out/count_$site
        list=$(python /home/aperez/get_averages.py /home/aperez/status/input_file_use_$site)
        list_2=$(echo $list |awk -F"] " '{print $4"]", $5"]"}')
        declare "stats_$site=$(echo $list_2)"
	rm /home/aperez/status/input_file_use_$site

	echo "      ]);

        var options_$site = {
                title: '$site',
                isStacked: 'true',
		explorer: {},
                'height':500,
		colors: ['#0040FF'],
                hAxis: {title: 'Time'},
                vAxis: {title: 'Number of cores'}
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
        <h2>MULTICORE PILOT USAGE OF CPU CORES AT CMS '$mysite' from '$start' until '$end', updated at '$(date -u)'<br>
        </h2>

	</h2>
    </div>
<br>
 <!--Div to hold the charts-->'>>$OUT

for site in $(echo $mysite); do
        var="stats_$site"
        echo ' <div id="chart_div_'$site'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'	
done>>$OUT

echo "
</body>
</html>" >>$OUT
