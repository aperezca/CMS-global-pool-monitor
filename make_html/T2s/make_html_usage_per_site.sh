#Interval to plot in yyyy/mm/dd format, e.g. 2019/01/01
mysite=$1
dstart=$2
dend=$3

start_t=$(date -d $dstart -u +%s)
end_t=$(date -d $dend -u +%s)

source /data/srv/aperezca/Monitoring/env.sh
OUT=$HTMLDIR"/T2s/multicore_usage_"$mysite"_"$(echo $dstart |awk -F"/" '{print $1 $2 $3}')"_"$(echo $dend |awk -F"/" '{print $1 $2 $3}')".html"

#--------------------
echo '<html>
<head>
<title>CMS multicore pilots core usage monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

echo $dstart $dend
echo $start_t $end_t

for site in $(echo $mysite); do
	#echo $site
	echo "var data_$site = new google.visualization.DataTable();	
	data_$site.addColumn('datetime', 'Date');
      	data_$site.addColumn('number', 'Busy cores'); 
	data_$site.addColumn('number', 'Idle cores');
	data_$site.addRows([">>$OUT
	rm $WORKDIR/status/single_site/input_file_use_$site
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		if [[ $time -gt $start_t ]] && [[ $time -lt $end_t ]]; then
			echo $line>> $WORKDIR/status/single_site/input_file_use_$site
			let timemil=1000*$time
			content=$(echo $line |awk '{print $5", "$6}')
			echo "[new Date($timemil), $content], " >>$OUT
		fi
	done <$OUTDIR/count_$site
	#done <$OUTDIRT0/count_$site
        list=$(python $WORKDIR/get_averages.py $WORKDIR/status/single_site/input_file_use_$site)
        list_2=$(echo $list |awk -F"] " '{print $4"]", $5"]"}')
        declare "stats_$site=$(echo $list_2)"
	rm $WORKDIR/status/single_site/input_file_use_$site

	echo "      ]);

        var options_$site = {
                title: '$site',
                isStacked: 'true',
		explorer: {},
                'height':500,
		colors: ['#0040FF', '#FF0000'],
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
        <h2>MULTICORE PILOT USAGE OF CPU CORES AT CMS '$mysite' from '$dstart' until '$dend', updated at '$(date -u)'<br>
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

